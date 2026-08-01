import Foundation

public struct RunDescriptor: Codable, Equatable, Sendable {
    public let experimentID: ExperimentID
    public let runID: UUID
    public let plannedSpanCount: Int
    public let startedAt: Date
    public let transport: Transport
    public let persistence: PersistenceMode
    public let flushMode: FlushMode

    public init(
        experimentID: ExperimentID,
        runID: UUID = UUID(),
        plannedSpanCount: Int,
        startedAt: Date = Date(),
        transport: Transport,
        persistence: PersistenceMode,
        flushMode: FlushMode = .explicit
    ) {
        precondition(plannedSpanCount > 0, "A run must plan at least one span")
        self.experimentID = experimentID
        self.runID = runID
        self.plannedSpanCount = plannedSpanCount
        self.startedAt = startedAt
        self.transport = transport
        self.persistence = persistence
        self.flushMode = flushMode
    }

    private enum CodingKeys: String, CodingKey {
        case experimentID
        case runID
        case plannedSpanCount
        case startedAt
        case transport
        case persistence
        case flushMode
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        experimentID = try container.decode(ExperimentID.self, forKey: .experimentID)
        runID = try container.decode(UUID.self, forKey: .runID)
        plannedSpanCount = try container.decode(Int.self, forKey: .plannedSpanCount)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        transport = try container.decode(Transport.self, forKey: .transport)
        persistence = try container.decode(PersistenceMode.self, forKey: .persistence)
        flushMode = try container.decodeIfPresent(FlushMode.self, forKey: .flushMode) ?? .explicit
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(experimentID, forKey: .experimentID)
        try container.encode(runID, forKey: .runID)
        try container.encode(plannedSpanCount, forKey: .plannedSpanCount)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encode(transport, forKey: .transport)
        try container.encode(persistence, forKey: .persistence)
        try container.encode(flushMode, forKey: .flushMode)
    }
}

public enum Transport: String, Codable, CaseIterable, Sendable {
    case grpc
    case http
}

public enum PersistenceMode: String, Codable, CaseIterable, Sendable {
    case disabled
    case officialDefault
    case officialInstant
}

public enum FlushMode: String, Codable, CaseIterable, Sendable {
    case disabled
    case explicit
}
