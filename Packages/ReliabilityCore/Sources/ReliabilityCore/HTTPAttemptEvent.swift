import Foundation

public struct HTTPAttemptEvent: Codable, Equatable, Sendable {
    public let attemptID: Int
    public let phase: HTTPAttemptPhase
    public let timestampUnixNanoseconds: Int64
    public let requestBodyBytes: Int?
    public let timeoutMilliseconds: Int?
    public let outcome: HTTPAttemptOutcome?
    public let errorDescription: String?

    public init(
        attemptID: Int,
        phase: HTTPAttemptPhase,
        timestampUnixNanoseconds: Int64,
        requestBodyBytes: Int? = nil,
        timeoutMilliseconds: Int? = nil,
        outcome: HTTPAttemptOutcome? = nil,
        errorDescription: String? = nil
    ) {
        self.attemptID = attemptID
        self.phase = phase
        self.timestampUnixNanoseconds = timestampUnixNanoseconds
        self.requestBodyBytes = requestBodyBytes
        self.timeoutMilliseconds = timeoutMilliseconds
        self.outcome = outcome
        self.errorDescription = errorDescription
    }
}

public enum HTTPAttemptPhase: String, Codable, Sendable {
    case started
    case completed
}

public enum HTTPAttemptOutcome: String, Codable, Sendable {
    case success
    case failure
}
