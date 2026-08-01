import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Generated span record")
struct GeneratedSpanRecordTests {
    @Test("preserves the exact sequence identity in JSON")
    func roundTrip() throws {
        let experimentID = try #require(ExperimentID(rawValue: "E000"))
        let original = GeneratedSpanRecord(
            experimentID: experimentID,
            runID: UUID(uuidString: "A0A0A0A0-0000-0000-0000-000000000001")!,
            sequence: 42,
            endedAtUnixNanoseconds: 1_785_582_400_125_000_000
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(GeneratedSpanRecord.self, from: encoded)

        #expect(decoded == original)
    }
}
