<div align="center">
    <img src="https://avatars.githubusercontent.com/u/26165732?s=200&v=4" width="100" height="100" alt="avatar" />
    <h1>SendGridKit</h1>
    <a href="https://swiftpackageindex.com/vapor-community/sendgrid-kit/documentation">
        <img src="https://design.vapor.codes/images/readthedocs.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor"><img src="https://design.vapor.codes/images/discordchat.svg" alt="Team Chat"></a>
    <a href="LICENSE"><img src="https://design.vapor.codes/images/mitlicense.svg" alt="MIT License"></a>
    <a href="https://github.com/vapor-community/sendgrid-kit/actions/workflows/test.yml">
        <img src="https://img.shields.io/github/actions/workflow/status/vapor-community/sendgrid-kit/test.yml?event=push&style=plastic&logo=github&label=tests&logoColor=%23ccc" alt="Continuous Integration">
    </a>
    <a href="https://codecov.io/github/vapor-community/sendgrid-kit">
        <img src="https://img.shields.io/codecov/c/github/vapor-community/sendgrid-kit?style=plastic&logo=codecov&label=codecov">
    </a>
    <a href="https://swift.org">
        <img src="https://design.vapor.codes/images/swift60up.svg" alt="Swift 6.0+">
    </a>
</div>
<br>

📧 SendGridKit is a Swift package that helps you communicate with the SendGrid API in your Server Side Swift applications.

Send simple emails or leverage the full capabilities of [SendGrid's V3 API](https://www.twilio.com/docs/sendgrid/api-reference/mail-send/mail-send).

### Getting Started

Use the SPM string to easily include the dependendency in your `Package.swift` file

```swift
.package(url: "https://github.com/vapor-community/sendgrid-kit.git", from: "3.1.0"),
```

and add it to your target's dependencies:

```swift
.product(name: "SendGridKit", package: "sendgrid-kit"),
```

## Overview

Register the config and the provider.

```swift
import AsyncHTTPClient
import SendGridKit

let httpClient = HTTPClient(...)
let sendGridClient = SendGridClient(httpClient: httpClient, apiKey: "YOUR_API_KEY")
```

### Using the API

You can use all of the available parameters here to build your `SendGridEmail`.

Usage in a route closure would be as followed:

```swift
import SendGridKit

let email = SendGridEmail(...)
try await sendGridClient.send(email: email)
```

### Error handling

If the request to the API failed for any reason a `SendGridError` is thrown, which has an `errors` property that contains an array of errors returned by the API.

Simply ensure you catch errors thrown like any other throwing function.

```swift
import SendGridKit

do {
    try await sendGridClient.send(email: email)
} catch let error as SendGridError {
    print(error)
}
```

### Email Validation API

SendGridKit supports SendGrid's [Email Address Validation API](https://www.twilio.com/docs/sendgrid/ui/managing-contacts/email-address-validation), which provides detailed information on the validity of email addresses.

```swift
import SendGridKit

let sendGridClient = SendGridEmailValidationClient(httpClient: .shared, apiKey: "YOUR_API_KEY")

// Create a validation request
let validationRequest = EmailValidationRequest(email: "example@email.com")

// Validate the email
do {
    let validationResponse = try await sendGridClient.validateEmail(validationRequest)
    
    // Check if the email is valid
    if validationResponse.result?.verdict == .valid {
        print("Email is valid with score: \(validationResponse.result?.score)")
    } else {
        print("Email is invalid")
    }
    
    // Access detailed validation information
    if validationResponse.result?.checks?.domain?.isSuspectedDisposableAddress ?? true {
        print("Warning: This is probably a disposable email address")
    }
    
    if validationResponse.result?.checks?.localPart?.isSuspectedRoleAddress {
        print("Note: This is a role-based email address")
    }
} catch {
    print("Validation failed: \(error)")
}
```

#### Bulk Email Validation API

For validating multiple email addresses at once, SendGridKit provides access to SendGrid's Bulk Email Address Validation API. This requires uploading a CSV file with email addresses:

```swift
import SendGridKit
import Foundation

let sendGridClient = SendGridEmailValidationClient(httpClient: .shared, apiKey: "YOUR_API_KEY")

do {
    // Step 1: Create a CSV file with email addresses
    let csvContent = """
        emails
        user1@example.com
        user2@example.com
        user3@example.com
        """
    guard let csvData = csvContent.data(using: .utf8) else {
        throw SomeError.invalidCSV
    }

    // Step 2: Upload the CSV file
    let fileUpload = try await sendGridClient.uploadBulkEmailValidationFile(
        fileData: csvData,
        fileType: .csv
    )
    
    guard fileUpload.succeeded, let jobID = fileUpload.jobID else {
        throw SomeError.uploadError
    }
    
    // Step 4: Check job status (poll until completed)
    var jobStatus = try await sendGridClient.checkBulkEmailValidationJob(by: jobID)
    
    while jobStatus.status != .done {
        print("Job \(jobStatus.id) status: \(jobStatus.status) - \(jobStatus.segmentsProcessed)/\(jobStatus.segments) segments processed")
        
        // Wait before checking again (implement your own backoff strategy)
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        jobStatus = try await sendGridClient.checkBulkEmailValidationJob(by: jobID)
    }
} catch {
    print("Bulk validation failed: \(error)")
}
```
