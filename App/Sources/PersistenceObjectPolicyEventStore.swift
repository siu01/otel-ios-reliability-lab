import Foundation
import ReliabilityCore

final class PersistenceObjectPolicyEventStore: @unchecked Sendable {
    private let fileURL: URL
    private let lock = NSLock()
    private let encoder: JSONEncoder

    init(fileURL: URL) {
        self.fileURL = fileURL
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        self.encoder = encoder
    }

    func append(_ event: PersistenceObjectPolicyEvent) throws {
        var line = try encoder.encode(event)
        line.append(0x0A)

        lock.lock()
        defer { lock.unlock() }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            try line.write(to: fileURL, options: .atomic)
            return
        }

        let handle = try FileHandle(forWritingTo: fileURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: line)
        try handle.synchronize()
    }
}
