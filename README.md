# SendGridKit

![Swift](http://img.shields.io/badge/swift-5.2-brightgreen.svg)
![Vapor](http://img.shields.io/badge/vapor-4.0-brightgreen.svg)

SendGridKit is a Swift package used to communicate with the SendGrid API for Server Side Swift Apps.

## Setup
Add the dependency to Package.swift:

~~~~swift
dependencies: [
	...
	.package(url: "https://github.com/vapor-community/sendgrit-kit.git", from: "1.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "SendGridKit", package: "sendgrid-kit"),
    ]),
~~~~

Register the config and the provider.

~~~~swift
let httpClient = HTTPClient(...)
let sendgridClient = SendGridClient(httpClient: httpClient, apiKey: "YOUR_API_KEY")
~~~~

## Using the API

You can use all of the available parameters here to build your `SendGridEmail`
Usage in a route closure would be as followed:

~~~~swift
import SendGrid

let email = SendGridEmail(...)
try sendGridClient.send(email, on: eventLoop)
~~~~

## Error handling
If the request to the API failed for any reason a `SendGridError` is `thrown` and has an `errors` property that contains an array of errors returned by the API.
Simply ensure you catch errors thrown like any other throwing function

~~~~swift
do {
    try sendGridClient.send(...)
}
catch let error as SendGridError {
    print(error)
}
~~~~
