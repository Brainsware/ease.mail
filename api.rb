require 'grape'

dirname = File.dirname(__FILE__)

require File.join(dirname, 'lib/zimbra/client')
require File.join(dirname, 'lib/nil_class')

class ZimbraAPI < Grape::API
	SERVER = 'ENTER YOUR SERVER HERE'
	DEFAULT_LIMIT = 10

	version = '0.1'

	###

	helpers do
		def client
			options = {}
			options[:server] = SERVER
			options[:auth_token] = params[:auth_token] if params.include? :auth_token

			@client ||= Zimbra::Client.new options
		end

		def get_search_options (type)
			options = { :limit => DEFAULT_LIMIT, :type => type }

			options[:limit]  = params[:limit]  if params.include? :limit
			options[:offset] = params[:offset] if params.include? :offset

			options
		end

		def authenticate!
			error! 'You must be logged in! Use /authenticate to do so.', 401 if params[:auth_token].empty?
		end
	end

	###

	post '/authenticate' do
		error! 'Username or password not supplied', 403 if params[:username].empty? || params[:password].empty?

		{ :auth_token => client.authorize(params[:username], params[:password]) }
	end

	###

	resources :conversations do
		before { authenticate! }

		get '/' do
			client.search get_search_options(:conversations)
		end
	end

	resources :messages do
		before { authenticate! }

		get '/' do
			client.search get_search_options(:messages)
		end
	end
end