import Foundation
import Testing
@testable import ReliabilityCore

@Suite("OTLP receipt extractor")
struct OTLPReceiptExtractorTests {
    @Test("extracts sequence numbers only for the requested run")
    func filtersByRunID() throws {
        let json = #"{"resourceSpans":[{"scopeSpans":[{"spans":[{"attributes":[{"key":"lab.run.id","value":{"stringValue":"00000000-0000-0000-0000-000000000001"}},{"key":"lab.sequence","value":{"intValue":"7"}}]},{"attributes":[{"key":"lab.run.id","value":{"stringValue":"00000000-0000-0000-0000-000000000002"}},{"key":"lab.sequence","value":{"intValue":"99"}}]}]}]}]}"#
        let runID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        let sequences = try OTLPReceiptExtractor.sequences(
            in: Data(json.utf8),
            matching: runID
        )

        #expect(sequences == [7])
    }

    @Test("ignores spans missing experiment identity attributes")
    func ignoresUnidentifiedSpans() throws {
        let json = #"{"resourceSpans":[{"scopeSpans":[{"spans":[{"attributes":[]}]}]}]}"#
        let runID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        #expect(
            try OTLPReceiptExtractor.sequences(in: Data(json.utf8), matching: runID).isEmpty
        )
    }
}

