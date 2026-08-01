import Foundation
import OpenTelemetryProtocolExporterCommon
import OpenTelemetryProtocolExporterHttp
import OpenTelemetrySdk
import SwiftProtobuf

final class StatelessOtlpHTTPTraceExporter: SpanExporter, @unchecked Sendable {
    private let endpoint: URL
    private let timeout: TimeInterval
    private let httpClient: any HTTPClient

    init(endpoint: URL, timeout: TimeInterval, httpClient: any HTTPClient) {
        self.endpoint = endpoint
        self.timeout = timeout
        self.httpClient = httpClient
    }

    func export(
        spans: [SpanData],
        explicitTimeout: TimeInterval?
    ) -> SpanExporterResultCode {
        guard !spans.isEmpty else { return .success }

        let body = Opentelemetry_Proto_Collector_Trace_V1_ExportTraceServiceRequest.with {
            $0.resourceSpans = SpanAdapter.toProtoResourceSpans(spanDataList: spans)
        }
        let serializedBody: Data
        do {
            serializedBody = try body.serializedData()
        } catch {
            return .failure
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = serializedBody
        request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("otel-ios-reliability-lab/0.1", forHTTPHeaderField: "User-Agent")

        let effectiveTimeout = min(
            explicitTimeout ?? TimeInterval.greatestFiniteMagnitude,
            timeout
        )
        request.timeoutInterval = effectiveTimeout

        let result = ExportResultBox()
        let semaphore = DispatchSemaphore(value: 0)
        httpClient.send(request: request) { httpResult in
            switch httpResult {
            case .success:
                result.set(.success)
            case .failure:
                result.set(.failure)
            }
            semaphore.signal()
        }

        guard semaphore.wait(timeout: .now() + effectiveTimeout) == .success else {
            return .failure
        }
        return result.get()
    }

    func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        .success
    }

    func shutdown(explicitTimeout: TimeInterval?) {}
}

private final class ExportResultBox: @unchecked Sendable {
    private let lock = NSLock()
    private var value: SpanExporterResultCode = .failure

    func set(_ newValue: SpanExporterResultCode) {
        lock.lock()
        value = newValue
        lock.unlock()
    }

    func get() -> SpanExporterResultCode {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}
