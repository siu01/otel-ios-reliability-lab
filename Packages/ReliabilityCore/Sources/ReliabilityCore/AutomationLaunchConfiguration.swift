import Foundation

public struct AutomationLaunchConfiguration: Equatable, Sendable {
    public let shouldAutorun: Bool
    public let experimentID: ExperimentID?
    public let runID: UUID?
    public let spanCount: Int?
    public let transport: Transport?
    public let persistence: PersistenceMode?

    public init(arguments: [String]) {
        shouldAutorun = arguments.contains("--lab-autorun")
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
    }

    private static func value(for key: String, in arguments: [String]) -> String? {
        let prefix = key + "="
        return arguments.first { $0.hasPrefix(prefix) }.map { String($0.dropFirst(prefix.count)) }
    }
}
