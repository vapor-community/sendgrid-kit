#if compiler(>=5.5) && canImport(_Concurrency)

import NIOCore

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension SendGridClient {
    public func send(emails: [SendGridEmail]) async throws {
        let eventLoop = httpClient.eventLoopGroup.next()
        try await send(emails: emails, on: eventLoop).get()
    }

    public func send(email: SendGridEmail) async throws {
        let eventLoop = httpClient.eventLoopGroup.next()
        try await send(email: email, on: eventLoop).get()
    }
}

#endif
