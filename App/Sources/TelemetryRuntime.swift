import Foundation
import OpenTelemetryApi
import OpenTelemetryProtocolExporterCommon
import OpenTelemetryProtocolExporterHttp
import OpenTelemetrySdk
import PersistenceExporter
import ReliabilityCore

enum TelemetryRuntimeError: LocalizedError {
    case unsupportedTransport(Transport)
    case missingPersistenceDirectory
    case bytePolicyRequiresPersistence

    var errorDescription: String? {
        switch self {
        case .unsupportedTransport(let transport):
            "Transport \(transport.rawValue) is not wired yet"
        case .missingPersistenceDirectory:
            "Application Support directory is unavailable"
        case .bytePolicyRequiresPersistence:
            "Encoded-byte policy requires an official persistence mode"
        }
    }
}

@MainActor
final class TelemetryRuntime {
    private var provider: TracerProviderSdk?
    private var tracer: (any Tracer)?
    private var exporter: (any SpanExporter)?
    private var payloadAttributeValue: String?

    func configure(for run: RunDescriptor, runEvidenceDirectory: URL) throws {
        guard run.transport == .http else {
            throw TelemetryRuntimeError.unsupportedTransport(run.transport)
        }

        provider?.shutdown()
        payloadAttributeValue = run.payloadAttributeBytes > 0
            ? String(repeating: "x", count: run.payloadAttributeBytes)
            : nil

        let endpoint = URL(string: "http://127.0.0.1:4318/v1/traces")!
        let httpClient: any HTTPClient
        switch run.httpClientMode {
        case .officialBase:
            httpClient = BaseHTTPClient()
        case .instrumentedBase:
            httpClient = try InstrumentedHTTPClient(
                evidenceURL: runEvidenceDirectory.appendingPathComponent("http-attempts.jsonl")
            )
        }

        let baseExporter: any SpanExporter
        switch run.exporterMode {
        case .officialStateful:
            baseExporter = OtlpHttpTraceExporter(
                endpoint: endpoint,
                config: OtlpConfiguration(
                    timeout: 2,
                    compression: .none,
                    exportAsJson: true
                ),
                httpClient: httpClient
            )
        case .statelessHTTP:
            baseExporter = StatelessOtlpHTTPTraceExporter(
                endpoint: endpoint,
                timeout: 2,
                httpClient: httpClient
            )
        }

        let persistenceExporter: any SpanExporter
        switch run.persistence {
        case .disabled:
            persistenceExporter = baseExporter
        case .officialDefault, .officialInstant:
            let storageURL = try persistenceDirectory(for: run.persistence)
            let preset: PersistencePerformancePreset =
                run.persistence == .officialInstant ? .instantDataDelivery : .default
            persistenceExporter = try PersistenceSpanExporterDecorator(
                spanExporter: baseExporter,
                storageURL: storageURL,
                performancePreset: preset
            )
        }

        let exporter: any SpanExporter
        switch run.persistenceObjectPolicy {
        case .sdkNative:
            exporter = persistenceExporter
        case .encodedByteBudget:
            guard run.persistence != .disabled else {
                throw TelemetryRuntimeError.bytePolicyRequiresPersistence
            }
            let eventStore = PersistenceObjectPolicyEventStore(
                fileURL: runEvidenceDirectory.appendingPathComponent(
                    "object-policy-events.jsonl"
                )
            )
            exporter = ByteBudgetingSpanExporter(
                wrappedExporter: persistenceExporter,
                byteBudget: run.persistenceObjectByteBudget,
                strategy: run.persistenceObjectPartitionStrategy,
                eventStore: eventStore
            )
        }

        let processor = BatchSpanProcessor(
            spanExporter: exporter,
            scheduleDelay: TimeInterval(run.processorScheduleDelayMilliseconds) / 1_000,
            exportTimeout: 2,
            maxQueueSize: 4_096,
            maxExportBatchSize: run.maxExportBatchSize
        )
        let provider = TracerProviderBuilder()
            .add(spanProcessor: processor)
            .build()

        OpenTelemetry.registerTracerProvider(tracerProvider: provider)
        self.provider = provider
        self.exporter = exporter
        tracer = provider.get(
            instrumentationName: "dev.siu01.otel-ios-reliability-lab",
            instrumentationVersion: "0.1.0"
        )
    }

    func emitProbe(sequence: Int, run: RunDescriptor, endedAtUnixNanoseconds: Int64) {
        guard let tracer else { return }

        let span = tracer
            .spanBuilder(spanName: "reliability.probe")
            .setSpanKind(spanKind: .internal)
            .startSpan()
        span.setAttribute(key: "lab.experiment.id", value: run.experimentID.rawValue)
        span.setAttribute(key: "lab.run.id", value: run.runID.uuidString.lowercased())
        span.setAttribute(key: "lab.sequence", value: sequence)
        span.setAttribute(key: "lab.transport", value: run.transport.rawValue)
        span.setAttribute(key: "lab.persistence", value: run.persistence.rawValue)
        span.setAttribute(
            key: "lab.ended_at_unix_nano",
            value: Int(endedAtUnixNanoseconds)
        )
        if let payloadAttributeValue {
            span.setAttribute(key: "lab.payload", value: payloadAttributeValue)
        }
        span.end()
    }

    func forceFlush(timeout: TimeInterval = 10, durabilityBarrier: Bool = false) {
        provider?.forceFlush(timeout: timeout)
        if durabilityBarrier {
            _ = exporter?.flush(explicitTimeout: timeout)
        }
    }

    private func persistenceDirectory(for mode: PersistenceMode) throws -> URL {
        guard let root = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw TelemetryRuntimeError.missingPersistenceDirectory
        }

        let directory = root
            .appendingPathComponent("OTelReliabilityLab", isDirectory: true)
            .appendingPathComponent("persistence", isDirectory: true)
            .appendingPathComponent(mode.rawValue, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        return directory
    }
}
