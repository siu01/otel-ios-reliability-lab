public enum PersistenceObjectPolicyOutcome: String, Codable, Sendable {
    case acceptedChunk
    case rejectedOversize
    case encodingFailed
    case wrappedExporterFailed
}

public struct PersistenceObjectPolicyEvent: Codable, Equatable, Sendable {
    public let callOrdinal: Int
    public let decisionOrdinal: Int
    public let outcome: PersistenceObjectPolicyOutcome
    public let inputSpanCount: Int
    public let spanCount: Int
    public let encodedByteCount: Int?
    public let byteBudget: Int
    public let sequences: [Int]
    public let spanIDs: [String]

    public init(
        callOrdinal: Int,
        decisionOrdinal: Int,
        outcome: PersistenceObjectPolicyOutcome,
        inputSpanCount: Int,
        spanCount: Int,
        encodedByteCount: Int?,
        byteBudget: Int,
        sequences: [Int],
        spanIDs: [String]
    ) {
        precondition(callOrdinal > 0, "Call ordinal must be positive")
        precondition(decisionOrdinal > 0, "Decision ordinal must be positive")
        precondition(inputSpanCount >= 0, "Input span count cannot be negative")
        precondition(spanCount >= 0, "Decision span count cannot be negative")
        precondition(byteBudget > 0, "A byte budget must be positive")
        if let encodedByteCount {
            precondition(encodedByteCount >= 0, "Encoded byte count cannot be negative")
        }
        self.callOrdinal = callOrdinal
        self.decisionOrdinal = decisionOrdinal
        self.outcome = outcome
        self.inputSpanCount = inputSpanCount
        self.spanCount = spanCount
        self.encodedByteCount = encodedByteCount
        self.byteBudget = byteBudget
        self.sequences = sequences
        self.spanIDs = spanIDs
    }
}
