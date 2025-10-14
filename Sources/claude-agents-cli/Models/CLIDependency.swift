import Foundation

/// Represents a CLI tool dependency needed by agents
public struct CLIDependency: Sendable, Identifiable, Hashable {
  public let id: String
  public let name: String
  public let checkCommand: String
  public let installCommand: String?
  public let homebrewFormula: String?
  public let usedByAgents: [String]
  public let optional: Bool

  public init(
    id: String,
    name: String,
    checkCommand: String,
    installCommand: String?,
    homebrewFormula: String?,
    usedByAgents: [String],
    optional: Bool = false
  ) {
    self.id = id
    self.name = name
    self.checkCommand = checkCommand
    self.installCommand = installCommand
    self.homebrewFormula = homebrewFormula
    self.usedByAgents = usedByAgents
    self.optional = optional
  }

  /// Predefined CLI dependencies for common tools
  public static let predefined: [CLIDependency] = [
    CLIDependency(
      id: "marked",
      name: "marked",
      checkCommand: "npx marked --version",
      installCommand: "npm install -g marked",
      homebrewFormula: "node",
      usedByAgents: ["ghost-publisher", "ghost-blogger"],
      optional: false
    ),
    CLIDependency(
      id: "gh",
      name: "gh",
      checkCommand: "gh --version",
      installCommand: nil,
      homebrewFormula: "gh",
      usedByAgents: ["git-pr-specialist"],
      optional: false
    ),
    CLIDependency(
      id: "glab",
      name: "glab",
      checkCommand: "glab --version",
      installCommand: nil,
      homebrewFormula: "glab",
      usedByAgents: ["git-pr-specialist"],
      optional: false
    ),
    CLIDependency(
      id: "swift-format",
      name: "swift-format",
      checkCommand: "swift format --version",
      installCommand: nil,
      homebrewFormula: nil,
      usedByAgents: ["swift-developer", "swift-modernizer", "testing-specialist"],
      optional: false
    ),
    CLIDependency(
      id: "azure-cli",
      name: "Azure CLI",
      checkCommand: "which az",
      installCommand: nil,
      homebrewFormula: "azure-cli",
      usedByAgents: ["azure-devops-specialist-template"],
      optional: false
    ),
  ]

  /// Get predefined dependency by ID
  public static func find(byId id: String) -> CLIDependency? {
    predefined.first { $0.id == id }
  }
}
