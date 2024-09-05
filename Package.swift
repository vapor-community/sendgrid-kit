// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "sendgrid-kit",
    platforms: [
       .macOS(.v13),
    ],
    products: [
        .library(name: "SendGridKit", targets: ["SendGridKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.22.0"),
    ],
    targets: [
        .target(
            name: "SendGridKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SendGridKitTests",
            dependencies: [
                .target(name: "SendGridKit"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("StrictConcurrency"),
    .enableExperimentalFeature("StrictConcurrency=complete"),
] }
