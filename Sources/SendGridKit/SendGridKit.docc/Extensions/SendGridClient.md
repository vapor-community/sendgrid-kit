# ``SendGridKit/SendGridClient``

## Overview

Register the config and the provider.

```swift
import AsyncHTTPClient
import SendGridKit

let httpClient = HTTPClient(...)
let sendGridClient = SendGridClient(httpClient: httpClient, apiKey: "YOUR_API_KEY")
```

### Using the API

You can use all of the available parameters here to build your ``SendGridEmail``.

Usage in a route closure would be as followed:

```swift
import SendGridKit

let email = SendGridEmail(...)
try await sendGridClient.send(email: email)
```

### Error handling

If the request to the API failed for any reason a ``SendGridError`` is thrown, which has an ``SendGridError/errors`` property that contains an array of errors returned by the API.

Simply ensure you catch errors thrown like any other throwing function.

```swift
import SendGridKit

do {
    try await sendGridClient.send(email: email)
} catch let error as SendGridError {
    print(error)
}
```
