import Foundation

public struct RunDescriptor: Codable, Equatable, Sendable {
    public let experimentID: ExperimentID
    public let runID: UUID
    public let plannedSpanCount: Int
    public let startedAt: Date
    public let transport: Transport
    public let persistence: PersistenceMode
    public let flushMode: FlushMode
    public let flushTrigger: FlushTrigger
    public let processorScheduleDelayMilliseconds: Int
    public let httpClientMode: HTTPClientMode
    public let exporterMode: ExporterMode

    public init(
        experimentID: ExperimentID,
        runID: UUID = UUID(),
        plannedSpanCount: Int,
        startedAt: Date = Date(),
        transport: Transport,
        persistence: PersistenceMode,
        flushMode: FlushMode = .explicit,
        flushTrigger: FlushTrigger = .afterBurst,
        processorScheduleDelayMilliseconds: Int = 250,
        httpClientMode: HTTPClientMode = .officialBase,
        exporterMode: ExporterMode = .officialStateful
    ) {
        precondition(plannedSpanCount > 0, "A run must plan at least one span")
        precondition(
            processorScheduleDelayMilliseconds > 0,
            "A processor schedule delay must be positive"
        )
        self.experimentID = experimentID
        self.runID = runID
        self.plannedSpanCount = plannedSpanCount
        self.startedAt = startedAt
        self.transport = transport
        self.persistence = persistence
        self.flushMode = flushMode
        self.flushTrigger = flushTrigger
        self.processorScheduleDelayMilliseconds = processorScheduleDelayMilliseconds
        self.httpClientMode = httpClientMode
        self.exporterMode = exporterMode
    }

    private enum CodingKeys: String, CodingKey {
        case experimentID
        case runID
        case plannedSpanCount
        case startedAt
        case transport
        case persistence
        case flushMode
        case flushTrigger
        case processorScheduleDelayMilliseconds
        case httpClientMode
        case exporterMode
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
        flushTrigger = try container.decodeIfPresent(
            FlushTrigger.self,
            forKey: .flushTrigger
        ) ?? .afterBurst
        let decodedScheduleDelay = try container.decodeIfPresent(
            Int.self,
            forKey: .processorScheduleDelayMilliseconds
        ) ?? 250
        guard decodedScheduleDelay > 0 else {
            throw DecodingError.dataCorruptedError(
                forKey: .processorScheduleDelayMilliseconds,
                in: container,
                debugDescription: "Processor schedule delay must be positive"
            )
        }
        processorScheduleDelayMilliseconds = decodedScheduleDelay
        httpClientMode = try container.decodeIfPresent(
            HTTPClientMode.self,
            forKey: .httpClientMode
        ) ?? .officialBase
        exporterMode = try container.decodeIfPresent(
            ExporterMode.self,
            forKey: .exporterMode
        ) ?? .officialStateful
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
        try container.encode(flushTrigger, forKey: .flushTrigger)
        try container.encode(
            processorScheduleDelayMilliseconds,
            forKey: .processorScheduleDelayMilliseconds
        )
        try container.encode(httpClientMode, forKey: .httpClientMode)
        try container.encode(exporterMode, forKey: .exporterMode)
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
    case durabilityBarrier
}

public enum FlushTrigger: String, Codable, CaseIterable, Sendable {
    case afterBurst
    case background
}

public enum HTTPClientMode: String, Codable, CaseIterable, Sendable {
    case officialBase
    case instrumentedBase
}

public enum ExporterMode: String, Codable, CaseIterable, Sendable {
    case officialStateful
    case statelessHTTP
}
