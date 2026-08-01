public enum PayloadAttributePattern: String, Codable, CaseIterable, Sendable {
    case constant
    case alternatingPrimarySecondary
    case groupedPrimaryFirst
    case groupedSecondaryFirst

    public func byteCount(
        forSequence sequence: Int,
        plannedSpanCount: Int,
        primaryBytes: Int,
        secondaryBytes: Int
    ) -> Int {
        precondition(plannedSpanCount > 0, "A pattern requires at least one span")
        precondition(
            (1...plannedSpanCount).contains(sequence),
            "Sequence must be inside the planned run"
        )
        precondition(primaryBytes >= 0, "Primary payload bytes cannot be negative")
        precondition(secondaryBytes >= 0, "Secondary payload bytes cannot be negative")

        switch self {
        case .constant:
            return primaryBytes
        case .alternatingPrimarySecondary:
            return sequence.isMultiple(of: 2) ? secondaryBytes : primaryBytes
        case .groupedPrimaryFirst:
            return sequence <= (plannedSpanCount + 1) / 2 ? primaryBytes : secondaryBytes
        case .groupedSecondaryFirst:
            return sequence <= plannedSpanCount / 2 ? secondaryBytes : primaryBytes
        }
    }
}
