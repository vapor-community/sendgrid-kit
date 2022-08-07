// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "sendgrid-kit",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .library(name: "SendGridKit", targets: ["SendGridKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
    ],
    targets: [
        .target(name: "SendGridKit", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
        ]),
        .testTarget(name: "SendGridKitTests", dependencies: [
            .target(name: "SendGridKit"),
        ])
    ]
)
