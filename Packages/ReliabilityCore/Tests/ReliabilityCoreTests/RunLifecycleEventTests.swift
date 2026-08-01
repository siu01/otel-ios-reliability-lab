import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Run lifecycle event")
struct RunLifecycleEventTests {
    @Test("round-trips a completed durability barrier")
    func jsonRoundTrip() throws {
        let original = RunLifecycleEvent(
            phase: .flushCompleted,
            timestampUnixNanoseconds: 1_785_582_400_123_000_000,
            flushMode: .durabilityBarrier,
            durationNanoseconds: 42_000_000
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RunLifecycleEvent.self, from: encoded)

        #expect(decoded == original)
    }
}
