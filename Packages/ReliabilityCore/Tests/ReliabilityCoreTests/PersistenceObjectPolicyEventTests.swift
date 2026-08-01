import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Persistence object policy event")
struct PersistenceObjectPolicyEventTests {
    @Test("round-trips an accepted chunk with exact identities")
    func acceptedChunkRoundTrip() throws {
        let event = PersistenceObjectPolicyEvent(
            callOrdinal: 2,
            decisionOrdinal: 3,
            outcome: .acceptedChunk,
            inputSpanCount: 100,
            spanCount: 42,
            encodedByteCount: 240_001,
            byteBudget: 262_144,
            sequences: Array(1...42),
            spanIDs: ["0000000000000001", "0000000000000002"]
        )

        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(
            PersistenceObjectPolicyEvent.self,
            from: encoded
        )

        #expect(decoded == event)
    }

    @Test("represents an encoding failure without a byte count")
    func encodingFailure() {
        let event = PersistenceObjectPolicyEvent(
            callOrdinal: 1,
            decisionOrdinal: 1,
            outcome: .encodingFailed,
            inputSpanCount: 1,
            spanCount: 1,
            encodedByteCount: nil,
            byteBudget: 262_144,
            sequences: [1],
            spanIDs: ["0000000000000042"]
        )

        #expect(event.encodedByteCount == nil)
        #expect(event.outcome == .encodingFailed)
    }
}
