import Foundation

public struct RunDescriptor: Codable, Equatable, Sendable {
    public let experimentID: ExperimentID
    public let runID: UUID
    public let plannedSpanCount: Int
    public let startedAt: Date
    public let transport: Transport
    public let persistence: PersistenceMode

    public init(
        experimentID: ExperimentID,
        runID: UUID = UUID(),
        plannedSpanCount: Int,
        startedAt: Date = Date(),
        transport: Transport,
        persistence: PersistenceMode
    ) {
        precondition(plannedSpanCount > 0, "A run must plan at least one span")
        self.experimentID = experimentID
        self.runID = runID
        self.plannedSpanCount = plannedSpanCount
        self.startedAt = startedAt
        self.transport = transport
        self.persistence = persistence
    }
}

public enum Transport: String, Codable, CaseIterable, Sendable {
    case grpc
    case http
}

public enum PersistenceMode: String, Codable, CaseIterable, Sendable {
    case disabled
    case officialDecorator
}

