import Foundation

public struct RunLifecycleEvent: Codable, Equatable, Sendable {
    public let phase: RunLifecyclePhase
    public let timestampUnixNanoseconds: Int64
    public let flushMode: FlushMode
    public let durationNanoseconds: Int64?

    public init(
        phase: RunLifecyclePhase,
        timestampUnixNanoseconds: Int64,
        flushMode: FlushMode,
        durationNanoseconds: Int64? = nil
    ) {
        precondition(
            durationNanoseconds == nil || durationNanoseconds! >= 0,
            "Lifecycle durations cannot be negative"
        )
        self.phase = phase
        self.timestampUnixNanoseconds = timestampUnixNanoseconds
        self.flushMode = flushMode
        self.durationNanoseconds = durationNanoseconds
    }
}

public enum RunLifecyclePhase: String, Codable, Sendable {
    case generatedLedgerCommitted
    case backgroundObserved
    case flushStarted
    case flushCompleted
    case burstCompleted
}
