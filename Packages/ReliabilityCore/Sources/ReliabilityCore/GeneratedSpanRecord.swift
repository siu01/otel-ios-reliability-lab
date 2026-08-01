import Foundation

public struct GeneratedSpanRecord: Codable, Equatable, Sendable {
    public let experimentID: ExperimentID
    public let runID: UUID
    public let sequence: Int
    public let endedAtUnixNanoseconds: Int64

    public init(
        experimentID: ExperimentID,
        runID: UUID,
        sequence: Int,
        endedAtUnixNanoseconds: Int64
    ) {
        precondition(sequence > 0, "Sequence numbers are one-based")
        self.experimentID = experimentID
        self.runID = runID
        self.sequence = sequence
        self.endedAtUnixNanoseconds = endedAtUnixNanoseconds
    }
}
