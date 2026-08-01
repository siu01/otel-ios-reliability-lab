import Foundation

public struct ReconciliationReport: Codable, Equatable, Sendable {
    public let plannedSpanCount: Int
    public let uniqueGeneratedCount: Int
    public let uniqueReceivedCount: Int
    public let duplicateGenerationRecordCount: Int
    public let duplicateReceiptRecordCount: Int
    public let generationGapSequences: [Int]
    public let missingReceiptSequences: [Int]
    public let unexpectedReceiptSequences: [Int]

    public var eventualDeliveryRate: Double {
        guard uniqueGeneratedCount > 0 else { return 0 }
        return Double(uniqueReceivedCount) / Double(uniqueGeneratedCount)
    }
}

public enum DeliveryReconciler {
    public static func reconcile(
        plannedSpanCount: Int,
        generatedSequences: [Int],
        receivedSequences: [Int]
    ) -> ReconciliationReport {
        precondition(plannedSpanCount > 0, "Planned span count must be positive")

        let planned = Set(1...plannedSpanCount)
        let generated = Set(generatedSequences).intersection(planned)
        let receiptsForGenerated = receivedSequences.filter(generated.contains)
        let uniqueReceipts = Set(receiptsForGenerated)

        return ReconciliationReport(
            plannedSpanCount: plannedSpanCount,
            uniqueGeneratedCount: generated.count,
            uniqueReceivedCount: uniqueReceipts.count,
            duplicateGenerationRecordCount:
                generatedSequences.filter(planned.contains).count - generated.count,
            duplicateReceiptRecordCount: receiptsForGenerated.count - uniqueReceipts.count,
            generationGapSequences: planned.subtracting(generated).sorted(),
            missingReceiptSequences: generated.subtracting(uniqueReceipts).sorted(),
            unexpectedReceiptSequences: Set(receivedSequences)
                .subtracting(generated)
                .sorted()
        )
    }
}

