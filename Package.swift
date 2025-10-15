// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "claude-agents-cli",
  platforms: [.macOS(.v13)],
  products: [
    // CLI tool for managing and installing agent markdown files
    .executable(name: "claude-agents", targets: ["claude-agents-cli"]),
    // Library for programmatic access to agent markdown files
    .library(name: "ClaudeAgents", targets: ["ClaudeAgents"])
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
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [
        .copy("Resources/agents")
      ]
    )
  ]
)
