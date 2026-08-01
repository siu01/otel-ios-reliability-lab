import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Run descriptor")
struct RunDescriptorTests {
    @Test("round-trips through JSON without losing comparison dimensions")
    func jsonRoundTrip() throws {
        let experimentID = try #require(ExperimentID(rawValue: "E001"))
        let original = RunDescriptor(
            experimentID: experimentID,
            runID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            plannedSpanCount: 1_000,
            startedAt: Date(timeIntervalSince1970: 1_785_582_400),
            transport: .http,
            persistence: .officialInstant
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RunDescriptor.self, from: encoded)

        #expect(decoded == original)
    }
}
