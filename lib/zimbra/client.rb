require 'savon'

module Zimbra
	ENVELOPE_NAMESPACE = 'urn:zimbra'
	SERVICE_PATH       = '/service/soap/'

	NS = {
		:zimbra  => 'urn:zimbra',
		:mail    => 'urn:zimbraMail',
		:account => 'urn:zimbraAccount',
		:admin   => 'urn:zimbraAdmin'
	}

	REQUESTS = {
		:auth   => 'AuthRequest',
		:search => 'SearchRequest'
	}

	NS_FOR_REQUEST = {
		:auth   => NS[:account],
		:search => NS[:mail]
	}

	class Client
		def initialize (server, verify_certificate = true)
			# Remove trailing '/' from server string if given
			server.gsub!(/\/$/, '')

			@client = Savon::Client.new do |wsdl, http|
				wsdl.namespace = ENVELOPE_NAMESPACE
				wsdl.endpoint  = server + SERVICE_PATH

				http.auth.ssl.verify_mode = :none if verify_certificate == :no_verify
			end
		end

		def authorize (username, password)
			response = request :auth, :xmlns => NS[:account] do |xml|
				xml.account(username, :by => 'name')
				xml.password(password)
			end

			@auth_token = response[:auth_response][:auth_token]

		rescue Savon::SOAP::Fault => e
			e.to_s
		end

		def method_missing (name, *args, &block)
			
		end

		def request (type, options = {}, &block)
			options[:xmlns] = NS_FOR_REQUEST[type] unless options.include?(:xmlns)

			response = @client.request REQUESTS[type], options do |soap|
				unless @auth_token.nil?
					soap.header = {
						:context => {
							:authToken => @auth_token
						},
						:attributes! => { :context => { :xmlns => NS[:zimbra] } }
					}
				end

				soap.body do |xml|
					yield xml if block_given?
				end
			end

			response.to_hash

		rescue Savon::SOAP::Fault => e
			e.to_s
		end
	end
end