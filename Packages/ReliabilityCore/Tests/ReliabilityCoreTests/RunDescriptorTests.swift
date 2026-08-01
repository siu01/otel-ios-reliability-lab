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
            persistence: .officialInstant,
            flushMode: .durabilityBarrier,
            httpClientMode: .instrumentedBase,
            exporterMode: .statelessHTTP
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RunDescriptor.self, from: encoded)

        #expect(decoded == original)
    }

    @Test("decodes evidence written before new client and flush dimensions")
    func decodesLegacyEvidence() throws {
        let experimentID = try #require(ExperimentID(rawValue: "E001"))
        let descriptor = RunDescriptor(
            experimentID: experimentID,
            plannedSpanCount: 100,
            transport: .http,
            persistence: .officialDefault
        )
        let encoded = try JSONEncoder().encode(descriptor)
        var object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "flushMode")
        object.removeValue(forKey: "httpClientMode")
        object.removeValue(forKey: "exporterMode")
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(RunDescriptor.self, from: legacyData)

        #expect(decoded.flushMode == .explicit)
        #expect(decoded.httpClientMode == .officialBase)
        #expect(decoded.exporterMode == .officialStateful)
    }
}
