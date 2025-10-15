import ClaudeAgents
import Foundation

/// Actor responsible for installing and managing agent files
public actor InstallService {
  private let fileManager = FileManager.default

  public init() {}

  /// Install agents to the specified target location
  public func install(
    agents: [Agent],
    target: InstallTarget,
    overwrite: Bool = false,
    interactive: Bool = false
  ) async -> [InstallResult] {
    let targetPath = target.path()

    // Create target directory if needed
    do {
      try await createDirectoryIfNeeded(at: targetPath)
    } catch {
      return agents.map { agent in
        InstallResult(
          agent: agent,
          target: target,
          destinationPath: targetPath.appendingPathComponent(agent.fileName),
          status: .failed(error: error)
        )
      }
    }

    var results: [InstallResult] = []

    for agent in agents {
      let destination = targetPath.appendingPathComponent(agent.fileName)
      let exists = fileManager.fileExists(atPath: destination.path)

      // Check if file already exists
      if exists && !overwrite {
        if interactive {
          print("Agent '\(agent.name)' already exists. Overwrite? (y/n): ", terminator: "")
          guard let response = readLine()?.lowercased(),
            response == "y" || response == "yes"
          else {
            results.append(
              InstallResult(
                agent: agent,
                target: target,
                destinationPath: destination,
                status: .skipped(reason: "already exists")
              ))
            continue
          }
        } else {
          results.append(
            InstallResult(
              agent: agent,
              target: target,
              destinationPath: destination,
              status: .skipped(reason: "already exists, use --force to overwrite")
            ))
          continue
        }
      }

      // Write agent content to file
      do {
        try agent.content.write(to: destination, atomically: true, encoding: .utf8)
        results.append(
          InstallResult(
            agent: agent,
            target: target,
            destinationPath: destination,
            status: exists ? .overwritten : .installed
          ))
      } catch {
        results.append(
          InstallResult(
            agent: agent,
            target: target,
            destinationPath: destination,
            status: .failed(error: error)
          ))
      }
    }

    return results
  }

  /// Uninstall agents from the specified target location
  public func uninstall(agentNames: [String], target: InstallTarget) async -> [String: Bool] {
    let targetPath = target.path()
    var results: [String: Bool] = [:]

    for name in agentNames {
      let fileName = name.hasSuffix(".md") ? name : "\(name).md"
      let filePath = targetPath.appendingPathComponent(fileName)

      if fileManager.fileExists(atPath: filePath.path) {
        do {
          try fileManager.removeItem(at: filePath)
          results[name] = true
        } catch {
          print("Failed to uninstall '\(name)': \(error.localizedDescription)")
          results[name] = false
        }
      } else {
        print("Agent '\(name)' not found at \(filePath.path)")
        results[name] = false
      }
    }

    return results
  }

  /// List all installed agents at the specified target
  public func listInstalled(at target: InstallTarget) async -> [String] {
    let targetPath = target.path()

    guard fileManager.fileExists(atPath: targetPath.path) else {
      return []
    }

    do {
      let files = try fileManager.contentsOfDirectory(
        at: targetPath,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )

      return
        files
        .filter { $0.pathExtension == "md" }
        .map { $0.deletingPathExtension().lastPathComponent }
        .sorted()
    } catch {
      return []
    }
  }

  /// Create directory at the specified path if it doesn't exist
  private func createDirectoryIfNeeded(at url: URL) async throws {
    guard !fileManager.fileExists(atPath: url.path) else {
      return
    }

    do {
      try fileManager.createDirectory(
        at: url,
        withIntermediateDirectories: true,
        attributes: nil
      )
    } catch {
      throw InstallError.directoryCreationFailed(url, error)
    }
  }
}
