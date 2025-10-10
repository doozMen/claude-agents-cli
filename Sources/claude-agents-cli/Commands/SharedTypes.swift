import ArgumentParser
import Foundation

/// Command-line option for specifying installation target
public enum TargetOption: String, ExpressibleByArgument, Sendable {
  case global
  case local

  public func toInstallTarget() -> InstallTarget {
    switch self {
    case .global:
      return .global
    case .local:
      return .local
    }
  }
}
