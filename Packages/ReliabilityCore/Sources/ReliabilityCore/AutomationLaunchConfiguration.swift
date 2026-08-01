import Foundation

public struct AutomationLaunchConfiguration: Equatable, Sendable {
    public let shouldAutorun: Bool
    public let shouldResume: Bool
    public let experimentID: ExperimentID?
    public let runID: UUID?
    public let spanCount: Int?
    public let transport: Transport?
    public let persistence: PersistenceMode?
    public let flushMode: FlushMode?
    public let flushTrigger: FlushTrigger?
    public let processorScheduleDelayMilliseconds: Int?
    public let httpClientMode: HTTPClientMode?
    public let exporterMode: ExporterMode?

    public init(arguments: [String]) {
        shouldAutorun = arguments.contains("--lab-autorun")
        shouldResume = arguments.contains("--lab-resume")
        experimentID = Self.value(for: "--lab-experiment-id", in: arguments)
            .flatMap(ExperimentID.init(rawValue:))
        runID = Self.value(for: "--lab-run-id", in: arguments).flatMap(UUID.init)
        spanCount = Self.value(for: "--lab-span-count", in: arguments)
            .flatMap(Int.init)
            .flatMap { $0 > 0 ? $0 : nil }
        transport = Self.value(for: "--lab-transport", in: arguments)
            .flatMap(Transport.init(rawValue:))
        persistence = Self.value(for: "--lab-persistence", in: arguments)
            .flatMap(PersistenceMode.init(rawValue:))
        flushMode = Self.value(for: "--lab-flush", in: arguments)
            .flatMap(FlushMode.init(rawValue:))
        flushTrigger = Self.value(for: "--lab-flush-trigger", in: arguments)
            .flatMap(FlushTrigger.init(rawValue:))
        processorScheduleDelayMilliseconds = Self.value(
            for: "--lab-schedule-delay-ms",
            in: arguments
        )
            .flatMap(Int.init)
            .flatMap { $0 > 0 ? $0 : nil }
        httpClientMode = Self.value(for: "--lab-http-client", in: arguments)
            .flatMap(HTTPClientMode.init(rawValue:))
        exporterMode = Self.value(for: "--lab-exporter", in: arguments)
            .flatMap(ExporterMode.init(rawValue:))
    }

    private static func value(for key: String, in arguments: [String]) -> String? {
        let prefix = key + "="
        return arguments.first { $0.hasPrefix(prefix) }.map { String($0.dropFirst(prefix.count)) }
    }
}
