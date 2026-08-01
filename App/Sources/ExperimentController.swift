import Foundation
import Dispatch
import ReliabilityCore

@MainActor
final class ExperimentController: ObservableObject {
    @Published var transport: Transport = .http
    @Published var persistence: PersistenceMode = .disabled
    @Published var flushMode: FlushMode = .explicit
    @Published var flushTrigger: FlushTrigger = .afterBurst
    @Published var processorScheduleDelayMilliseconds = 250
    @Published var maxExportBatchSize = 256
    @Published var payloadAttributeBytes = 0
    @Published var persistenceObjectPolicy: PersistenceObjectPolicy = .sdkNative
    @Published var persistenceObjectByteBudget = 262_144
    @Published var persistenceObjectPartitionStrategy: ByteBudgetPartitionStrategy =
        .linearPrefixEncoding
    @Published var mainQueueProbeEnabled = false
    @Published var httpClientMode: HTTPClientMode = .officialBase
    @Published var exporterMode: ExporterMode = .officialStateful
    @Published var plannedSpanCount = 100
    @Published private(set) var generatedCount = 0
    @Published private(set) var receivedCount = 0
    @Published private(set) var status = "Ready for dry run"
    @Published private(set) var latestRunID: UUID?
    @Published private(set) var isRunning = false
    @Published private(set) var isReconciled = false

    let experimentID: ExperimentID
    private let telemetry = TelemetryRuntime()
    private let launchConfiguration: AutomationLaunchConfiguration
    private var didAutorun = false
    private var didResume = false
    private var didObserveBackground = false
    private var activeRun: RunDescriptor?
    private var activeEvidenceStore: RunEvidenceStore?

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        let launchConfiguration = AutomationLaunchConfiguration(arguments: arguments)
        self.launchConfiguration = launchConfiguration
        experimentID = launchConfiguration.experimentID ?? ExperimentID(rawValue: "E000")!

        if let spanCount = launchConfiguration.spanCount {
            plannedSpanCount = spanCount
        }
        if let transport = launchConfiguration.transport {
            self.transport = transport
        }
        if let persistence = launchConfiguration.persistence {
            self.persistence = persistence
        }
        if let flushMode = launchConfiguration.flushMode {
            self.flushMode = flushMode
        }
        if let flushTrigger = launchConfiguration.flushTrigger {
            self.flushTrigger = flushTrigger
        }
        if let scheduleDelay = launchConfiguration.processorScheduleDelayMilliseconds {
            processorScheduleDelayMilliseconds = scheduleDelay
        }
        if let maxExportBatchSize = launchConfiguration.maxExportBatchSize {
            self.maxExportBatchSize = maxExportBatchSize
        }
        if let payloadAttributeBytes = launchConfiguration.payloadAttributeBytes {
            self.payloadAttributeBytes = payloadAttributeBytes
        }
        if let persistenceObjectPolicy = launchConfiguration.persistenceObjectPolicy {
            self.persistenceObjectPolicy = persistenceObjectPolicy
        }
        if let persistenceObjectByteBudget = launchConfiguration.persistenceObjectByteBudget {
            self.persistenceObjectByteBudget = persistenceObjectByteBudget
        }
        if let strategy = launchConfiguration.persistenceObjectPartitionStrategy {
            persistenceObjectPartitionStrategy = strategy
        }
        if let mainQueueProbeEnabled = launchConfiguration.mainQueueProbeEnabled {
            self.mainQueueProbeEnabled = mainQueueProbeEnabled
        }
        if let httpClientMode = launchConfiguration.httpClientMode {
            self.httpClientMode = httpClientMode
        }
        if let exporterMode = launchConfiguration.exporterMode {
            self.exporterMode = exporterMode
        }
        status = launchConfiguration.shouldAutorun
            ? "Automated baseline queued"
            : "Ready for baseline"
    }

    var deliveryText: String {
        guard generatedCount > 0 else { return "—" }
        guard isReconciled else { return "Pending" }
        let rate = Double(receivedCount) / Double(generatedCount)
        return rate.formatted(.percent.precision(.fractionLength(1)))
    }

    func autorunIfRequested() {
        guard launchConfiguration.shouldAutorun, !didAutorun else { return }
        didAutorun = true
        runBaselineBurst(runID: launchConfiguration.runID)
    }

    func resumeIfRequested() {
        guard launchConfiguration.shouldResume, !didResume else { return }
        didResume = true
        guard let runID = launchConfiguration.runID else {
            status = "Failed: resume run ID is missing"
            return
        }

        status = "Reopening persisted telemetry"
        Task { @MainActor in
            do {
                let run = RunDescriptor(
                    experimentID: experimentID,
                    runID: runID,
                    plannedSpanCount: plannedSpanCount,
                    transport: transport,
                    persistence: persistence,
                    flushMode: flushMode,
                    flushTrigger: flushTrigger,
                    processorScheduleDelayMilliseconds: processorScheduleDelayMilliseconds,
                    maxExportBatchSize: maxExportBatchSize,
                    payloadAttributeBytes: payloadAttributeBytes,
                    persistenceObjectPolicy: persistenceObjectPolicy,
                    persistenceObjectByteBudget: persistenceObjectByteBudget,
                    persistenceObjectPartitionStrategy: persistenceObjectPartitionStrategy,
                    mainQueueProbeEnabled: mainQueueProbeEnabled,
                    httpClientMode: httpClientMode,
                    exporterMode: exporterMode
                )
                let evidenceStore = try RunEvidenceStore(resumingRunID: runID)
                try telemetry.configure(
                    for: run,
                    runEvidenceDirectory: evidenceStore.runDirectory
                )
                latestRunID = runID
                status = "Persistence recovery active"
            } catch {
                status = "Failed: \(error.localizedDescription)"
            }
        }
    }

    func runBaselineBurst(runID: UUID? = nil) {
        guard !isRunning else { return }
        isRunning = true
        status = "Configuring exporter"

        Task { @MainActor in
            do {
                let run = RunDescriptor(
                    experimentID: experimentID,
                    runID: runID ?? UUID(),
                    plannedSpanCount: plannedSpanCount,
                    transport: transport,
                    persistence: persistence,
                    flushMode: flushMode,
                    flushTrigger: flushTrigger,
                    processorScheduleDelayMilliseconds: processorScheduleDelayMilliseconds,
                    maxExportBatchSize: maxExportBatchSize,
                    payloadAttributeBytes: payloadAttributeBytes,
                    persistenceObjectPolicy: persistenceObjectPolicy,
                    persistenceObjectByteBudget: persistenceObjectByteBudget,
                    persistenceObjectPartitionStrategy: persistenceObjectPartitionStrategy,
                    mainQueueProbeEnabled: mainQueueProbeEnabled,
                    httpClientMode: httpClientMode,
                    exporterMode: exporterMode
                )
                latestRunID = run.runID
                isReconciled = false
                let evidenceStore = try RunEvidenceStore(run: run)
                activeRun = run
                activeEvidenceStore = evidenceStore
                didObserveBackground = false
                try telemetry.configure(
                    for: run,
                    runEvidenceDirectory: evidenceStore.runDirectory
                )

                status = "Ending \(plannedSpanCount) probe spans"
                var generated: [GeneratedSpanRecord] = []
                generated.reserveCapacity(plannedSpanCount)

                for sequence in 1...plannedSpanCount {
                    let endedAt = Int64(Date().timeIntervalSince1970 * 1_000_000_000)
                    telemetry.emitProbe(
                        sequence: sequence,
                        run: run,
                        endedAtUnixNanoseconds: endedAt
                    )
                    generated.append(
                        GeneratedSpanRecord(
                            experimentID: experimentID,
                            runID: run.runID,
                            sequence: sequence,
                            endedAtUnixNanoseconds: endedAt
                        )
                    )
                }

                try evidenceStore.writeGeneratedRecords(generated)
                try evidenceStore.appendLifecycleEvent(
                    RunLifecycleEvent(
                        phase: .generatedLedgerCommitted,
                        timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                        flushMode: flushMode
                    )
                )
                generatedCount = generated.count
                receivedCount = 0
                if flushMode == .disabled || flushTrigger == .background {
                    status = "Leaving export to scheduled workers"
                } else {
                    try performFlush(
                        mode: flushMode,
                        mainQueueProbeEnabled: run.mainQueueProbeEnabled,
                        evidenceStore: evidenceStore
                    )
                }
                try evidenceStore.appendLifecycleEvent(
                    RunLifecycleEvent(
                        phase: .burstCompleted,
                        timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                        flushMode: flushMode
                    )
                )
                status = "Burst complete — reconcile on host"
            } catch {
                status = "Failed: \(error.localizedDescription)"
            }
            isRunning = false
        }
    }

    func reset() {
        generatedCount = 0
        receivedCount = 0
        latestRunID = nil
        isReconciled = false
        activeRun = nil
        activeEvidenceStore = nil
        didObserveBackground = false
        status = "Ready for baseline"
    }

    func handleBackgroundTransition() {
        guard !didObserveBackground,
              let run = activeRun,
              let evidenceStore = activeEvidenceStore else { return }
        didObserveBackground = true

        do {
            try evidenceStore.appendLifecycleEvent(
                RunLifecycleEvent(
                    phase: .backgroundObserved,
                    timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                    flushMode: run.flushMode
                )
            )
            status = "Background transition observed"
            if run.flushTrigger == .background, run.flushMode != .disabled {
                try performFlush(
                    mode: run.flushMode,
                    mainQueueProbeEnabled: run.mainQueueProbeEnabled,
                    evidenceStore: evidenceStore
                )
                status = "Background flush complete"
            }
        } catch {
            status = "Failed: \(error.localizedDescription)"
        }
    }

    private func performFlush(
        mode: FlushMode,
        mainQueueProbeEnabled: Bool,
        evidenceStore: RunEvidenceStore
    ) throws {
        status = mode == .durabilityBarrier
            ? "Crossing durability barrier"
            : "Flushing provider"
        try evidenceStore.appendLifecycleEvent(
            RunLifecycleEvent(
                phase: .flushStarted,
                timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                flushMode: mode
            )
        )
        if mainQueueProbeEnabled {
            try scheduleMainQueueProbe(mode: mode, evidenceStore: evidenceStore)
        }
        let flushStarted = DispatchTime.now().uptimeNanoseconds
        telemetry.forceFlush(durabilityBarrier: mode == .durabilityBarrier)
        let flushDuration = DispatchTime.now().uptimeNanoseconds - flushStarted
        try evidenceStore.appendLifecycleEvent(
            RunLifecycleEvent(
                phase: .flushCompleted,
                timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                flushMode: mode,
                durationNanoseconds: Int64(flushDuration)
            )
        )
    }

    private func scheduleMainQueueProbe(
        mode: FlushMode,
        evidenceStore: RunEvidenceStore
    ) throws {
        try evidenceStore.appendLifecycleEvent(
            RunLifecycleEvent(
                phase: .mainQueueProbeScheduled,
                timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                flushMode: mode
            )
        )
        let scheduledAt = DispatchTime.now().uptimeNanoseconds
        DispatchQueue.main.async { [weak self] in
            let delay = DispatchTime.now().uptimeNanoseconds - scheduledAt
            do {
                try evidenceStore.appendLifecycleEvent(
                    RunLifecycleEvent(
                        phase: .mainQueueProbeExecuted,
                        timestampUnixNanoseconds: Self.currentUnixNanoseconds(),
                        flushMode: mode,
                        durationNanoseconds: Int64(delay)
                    )
                )
            } catch {
                self?.status = "Failed to record main-queue probe: \(error.localizedDescription)"
            }
        }
    }

    private static func currentUnixNanoseconds() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1_000_000_000)
    }
}
