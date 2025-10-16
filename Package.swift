// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-agents-plugin",
  platforms: [.macOS(.v13)],
  products: [
    // CLI tool for managing and installing agent markdown files
    .executable(name: "claude-agents", targets: ["claude-agents-cli"]),
    // Library for programmatic access to agent markdown files
    .library(name: "ClaudeAgents", targets: ["ClaudeAgents"]),
    // Example executable for testing Installation API
    .executable(name: "test-installation-api", targets: ["TestInstallationAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
  ],
  targets: [
    // Library target - public API for accessing agent markdown files
    .target(
      name: "ClaudeAgents",
      dependencies: [],
      resources: [
        .copy("Resources/agents")
      ]
    ),
    // CLI executable - uses the library
    .executableTarget(
      name: "claude-agents-cli",
      dependencies: [
        "ClaudeAgents",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    // Test target for ClaudeAgents library
    .testTarget(
      name: "ClaudeAgentsTests",
      dependencies: ["ClaudeAgents"]
    ),
    // Example executable for testing Installation API
    .executableTarget(
      name: "TestInstallationAPI",
      dependencies: ["ClaudeAgents"],
      path: "Examples"
    ),
  ]
)
