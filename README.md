ease.mail
=========

Supposed to provide:

a) a Ruby client for Zimbra's SOAP API
b) a RESTful API service for clients to interact with Zimbra

Sporting a Rack/Grape service, you can now read email from your shell of choice:

    curl -X POST http://your.rack.server.org/0.1/authenticate.json -d'username=...' -d'password=****'

This will give you an auth token which you need to pass as parameter to all subsequent requests, e.g. conversations:

    curl -X GET http://your.rack.server.org/0.1/conversations.json?limit=5 -d'auth_token=.....'