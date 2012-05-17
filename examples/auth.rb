require 'zimbra/client'

# Set these constants accordingly
USERNAME = 'test'
PASSWORD = 'test'
MAILSERVER = 'https://your.mailserver.com'

# Set up a client for given mailserver
client = Zimbra::Client.new MAILSERVER

# Authenticate with given username & password
client.authorize(USERNAME, PASSWORD)

# Search for mails (returning default response here)
response = client.request :search

# Print returned mails
puts response.inspect
