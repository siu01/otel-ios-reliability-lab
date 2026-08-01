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

    @Test("represents a background event without a flush duration")
    func backgroundEvent() throws {
        let event = RunLifecycleEvent(
            phase: .backgroundObserved,
            timestampUnixNanoseconds: 1_785_582_400_456_000_000,
            flushMode: .disabled
        )

        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(RunLifecycleEvent.self, from: data)

        #expect(decoded.phase == .backgroundObserved)
        #expect(decoded.durationNanoseconds == nil)
    }
}
