// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SendGridKit",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .library(name: "SendGridKit", targets: ["SendGridKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
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
