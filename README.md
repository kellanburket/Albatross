# Passenger

[![CI Status](http://img.shields.io/travis/Kellan Cummings/Passenger.svg?style=flat)](https://travis-ci.org/Kellan Cummings/Passenger)
[![Version](https://img.shields.io/cocoapods/v/Passenger.svg?style=flat)](http://cocoapods.org/pods/Passenger)
[![License](https://img.shields.io/cocoapods/l/Passenger.svg?style=flat)](http://cocoapods.org/pods/Passenger)
[![Platform](https://img.shields.io/cocoapods/p/Passenger.svg?style=flat)](http://cocoapods.org/pods/Passenger)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Passenger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Passenger"
```

## Set Up

Passenger is a Swift API Mapper that takes the pain of writing JSON-parsing Methods and HTTP requests out of building apps with API support. Instead, Passenger defines the classes `Model` and `Entity`, which cab be used to consume JSON APIs in much the same way as an ORM relates to a database.

To create a new API. Run the utility `passenger` inside the pod's `bin` folder to autogenerate two new plist templates:

- api.plist
- endpoints.plist

Add them to your project and add API config and endpoints to get started using Passenger.

## API
Set your API settings in a file called 'api.plist' or '<api>.api.plist' if you're using several apis with different namespaces. 

- namespace:	your app's namespace
- version:	the version of the API you're accessing, used to construct the version part of your path
- consumer_key:	your personal consumer key, provided by the authenticating api
- authorization:	a dictionary of authorization credentials

	- OAuth1

		- consumer_secret: consumer_secret provided by authenticating API
		- signature_method:	currently only HMAC-SHA1 is supported
		- request_token_url:	request token url provided by authenticating API
		- access_token_url:	 access token url provided by authenticating API
		- request_token_callback:	your app's personal callback url; this can be set in Targets > [Your_Project] > Info > URL Types; for instance, if you create a new url with the identifier 'com.fkcomp.passenger' and a url scheme 'passenger', you would write 'passenger://com.fkcomp.passenger' here.
		- authorize_url:	authorize url provided by authenticating API

	- BasicAuth

		- personal_key:	personal key provided by authenticating API

- options:	a dictionary of options with boolean values

	- use_file_extensions:	set to YES to use content-type extensions to identify your path; e.g., the path 'posts/:id/comments' will be processed as 'posts/:id/comments.json'
	- use_accept_headers:	set to YES to set the Http Accept header with the desired type
	- show_version_in_path:	set to YES to include the version in the API path

- url:	base API url

### Endpoints
Set your endpoint settings in a file called 'endpoints.plist' or '<api>.endpoints.plist' if you're using several apis with different namespaces.

- <Endpoint>:	a `Model` class

	- path:	the relative path to the route
	- routes:	a dictionary of routes

		- <Route>:	a `Model` class method: the built in routes are list, create, show, find, destroy, save, upload 

			- path:	the relative path to the route
			- method:	the HTTP method, defaults to GET o
			- node:	the relative json node; set if the endpoint name does not match the json node; for the endpoint "ProjectStatus", for instance, Passenger will expect to use either the root json node, or if found the json node "project_status"/"project_statuses" (in case you are fetching an array)
			- auth: the authorization method; OAuth1 and BasicAuth are the only authorization methods currently supported

	- endpoints:	a dictionary of endpoints

		- <Endpoint>

To set path variables in endpoint paths use the following notation

- "posts/:id"	given the endpoint "posts", ":id" will be replaced by the Post's "id" property 
- "users/:user.name/posts/:id"	given the endpoint "posts", which is a child of "users", ":user.name" will replaced by the User's "name" property and ":id" will be replaced by the Post's "id" property
	
The following routes, while having characteristic behavior defined by the base `Model` class, must still be defined in endpoints.plist for all accessible endpoints

- list:	GET
- find:	GET
- search:	GET
- show:	GET
- save:	PUT
- create:	POST
- destroy:	DELETE
- upload:	POST

## About

Passenger is currently looking for collaborators who are interested in expanding API support and generally and improving the codebase.

## Author

Kellan Cummings, kellan.burket@gmail.com

## License

Passenger is available under the MIT license. See the LICENSE file for more info.
