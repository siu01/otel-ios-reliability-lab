import Foundation
import Testing
@testable import ReliabilityCore

@Suite("HTTP attempt event")
struct HTTPAttemptEventTests {
    @Test("round-trips a failed request lifecycle event")
    func jsonRoundTrip() throws {
        let original = HTTPAttemptEvent(
            attemptID: 2,
            phase: .completed,
            timestampUnixNanoseconds: 1_785_582_400_123_000_000,
            requestBodyBytes: 42_000,
            timeoutMilliseconds: 2_000,
            outcome: .failure,
            errorDescription: "timed out"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HTTPAttemptEvent.self, from: encoded)

        #expect(decoded == original)
    }
}
