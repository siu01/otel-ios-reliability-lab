import Testing
@testable import ReliabilityCore

@Suite("Delivery reconciliation")
struct ReconciliationReportTests {
    @Test("reports complete delivery")
    func completeDelivery() {
        let report = DeliveryReconciler.reconcile(
            plannedSpanCount: 4,
            generatedSequences: [1, 2, 3, 4],
            receivedSequences: [1, 2, 3, 4]
        )

        #expect(report.eventualDeliveryRate == 1)
        #expect(report.missingReceiptSequences.isEmpty)
        #expect(report.duplicateReceiptRecordCount == 0)
    }

    @Test("separates loss, duplication, and unexpected receipts")
    func classifiesReceiptProblems() {
        let report = DeliveryReconciler.reconcile(
            plannedSpanCount: 5,
            generatedSequences: [1, 2, 3, 4, 5],
            receivedSequences: [1, 1, 2, 4, 7]
        )

        #expect(report.uniqueReceivedCount == 3)
        #expect(report.eventualDeliveryRate == 0.6)
        #expect(report.duplicateReceiptRecordCount == 1)
        #expect(report.missingReceiptSequences == [3, 5])
        #expect(report.unexpectedReceiptSequences == [7])
    }

    @Test("does not misclassify spans that were never generated as delivery loss")
    func distinguishesGenerationFailure() {
        let report = DeliveryReconciler.reconcile(
            plannedSpanCount: 5,
            generatedSequences: [1, 2, 2, 4],
            receivedSequences: [1, 2, 4, 5]
        )

        #expect(report.duplicateGenerationRecordCount == 1)
        #expect(report.generationGapSequences == [3, 5])
        #expect(report.missingReceiptSequences.isEmpty)
        #expect(report.unexpectedReceiptSequences == [5])
        #expect(report.eventualDeliveryRate == 1)
    }
}

