import XCTest
@testable import SendGridKit
// Test inbox: https://www.mailinator.com/inbox2.jsp?public_to=vapor-sendgrid

class SendGridKitTests: XCTestCase {
    
    /**
     Only way we can test if our request is valid is to use an actual APi key.
     Maybe we'll use the testwithvapor@gmail account for these tests if it becomes
     a recurring theme we need api keys to test providers.
     */
    
    func testNothing() {
        XCTAssertTrue(true)
    }
}
