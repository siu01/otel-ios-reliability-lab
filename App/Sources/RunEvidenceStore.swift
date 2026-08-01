import Foundation
import ReliabilityCore

enum RunEvidenceStoreError: LocalizedError {
    case missingApplicationSupportDirectory

    var errorDescription: String? {
        "Application Support directory is unavailable"
    }
}

@MainActor
struct RunEvidenceStore {
    let runDirectory: URL

    init(run: RunDescriptor) throws {
        runDirectory = try Self.directory(for: run.runID)
        try FileManager.default.createDirectory(
            at: runDirectory,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let manifest = try encoder.encode(run)
        try manifest.write(
            to: runDirectory.appendingPathComponent("run.json"),
            options: .atomic
        )
    }

    init(resumingRunID runID: UUID) throws {
        runDirectory = try Self.directory(for: runID)
        guard FileManager.default.fileExists(
            atPath: runDirectory.appendingPathComponent("run.json").path
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }
    }

    private static func directory(for runID: UUID) throws -> URL {
        guard let root = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw RunEvidenceStoreError.missingApplicationSupportDirectory
        }

        return root
            .appendingPathComponent("OTelReliabilityLab", isDirectory: true)
            .appendingPathComponent("runs", isDirectory: true)
            .appendingPathComponent(runID.uuidString.lowercased(), isDirectory: true)
    }

    func writeGeneratedRecords(_ records: [GeneratedSpanRecord]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var output = Data()

        for record in records {
            output.append(try encoder.encode(record))
            output.append(0x0A)
        }

        try output.write(
            to: runDirectory.appendingPathComponent("generated.jsonl"),
            options: .atomic
        )
    }
}
