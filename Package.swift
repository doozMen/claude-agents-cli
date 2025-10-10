// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "claude-agents-cli",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "claude-agents", targets: ["claude-agents-cli"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
  ],
  targets: [
    .executableTarget(
      name: "claude-agents-cli",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [
        .copy("Resources/agents")
      ]
    )
  ]
)
