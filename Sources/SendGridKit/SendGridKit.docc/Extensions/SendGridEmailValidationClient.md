# ``SendGridKit/SendGridEmailValidationClient``

## Overview

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
        print("Email is invalid: \(validationResponse.result?.reason ?? "Unknown reason")")
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
        
        jobStatusResponse = try await sendGridClient.checkBulkEmailValidationJob(by: jobID)
        jobStatus = jobStatusResponse.result
    }
} catch {
    print("Bulk validation failed: \(error)")
}
```
