import Foundation
import ReliabilityCore

private struct ReconciliationArtifact: Codable {
    let run: RunDescriptor
    let generatedRecordCount: Int
    let receivedRecordCount: Int
    let report: ReconciliationReport
    let reconciledAt: Date
}

private enum CLIError: LocalizedError {
    case usage
    case missingFile(String)
    case outputExists(String)

    var errorDescription: String? {
        switch self {
        case .usage:
            "usage: reliability-reconcile <run-directory>"
        case .missingFile(let path):
            "required evidence file is missing: \(path)"
        case .outputExists(let path):
            "refusing to overwrite existing reconciliation: \(path)"
        }
    }
}

@main
struct ReliabilityCLI {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else { throw CLIError.usage }

        let runDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let runURL = runDirectory.appendingPathComponent("run.json")
        let generatedURL = runDirectory.appendingPathComponent("generated.jsonl")
        let receivedURL = runDirectory.appendingPathComponent("received-otlp.jsonl")
        let outputURL = runDirectory.appendingPathComponent("reconciliation.json")

        for requiredURL in [runURL, generatedURL, receivedURL] {
            guard FileManager.default.fileExists(atPath: requiredURL.path) else {
                throw CLIError.missingFile(requiredURL.path)
            }
        }
        guard !FileManager.default.fileExists(atPath: outputURL.path) else {
            throw CLIError.outputExists(outputURL.path)
        }

        let runDecoder = JSONDecoder()
        runDecoder.dateDecodingStrategy = .iso8601
        let run = try runDecoder.decode(RunDescriptor.self, from: Data(contentsOf: runURL))

        let generatedRecords: [GeneratedSpanRecord] = try lines(in: generatedURL).map {
            try JSONDecoder().decode(GeneratedSpanRecord.self, from: $0)
        }
        let receivedSequences = try lines(in: receivedURL).flatMap {
            try OTLPReceiptExtractor.sequences(in: $0, matching: run.runID)
        }
        let report = DeliveryReconciler.reconcile(
            plannedSpanCount: run.plannedSpanCount,
            generatedSequences: generatedRecords.map(\.sequence),
            receivedSequences: receivedSequences
        )
        let artifact = ReconciliationArtifact(
            run: run,
            generatedRecordCount: generatedRecords.count,
            receivedRecordCount: receivedSequences.count,
            report: report,
            reconciledAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(artifact).write(to: outputURL, options: .atomic)

        print("run=\(run.runID.uuidString.lowercased())")
        print("generated=\(report.uniqueGeneratedCount)")
        print("received=\(report.uniqueReceivedCount)")
        print("duplicates=\(report.duplicateReceiptRecordCount)")
        print("missing=\(report.missingReceiptSequences.count)")
        print("delivery=\(report.eventualDeliveryRate)")
    }

    private static func lines(in url: URL) throws -> [Data] {
        let data = try Data(contentsOf: url)
        return [UInt8](data).split(separator: 0x0A).map { Data($0) }
    }
}
