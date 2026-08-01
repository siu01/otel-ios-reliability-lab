import Foundation
import OpenTelemetryProtocolExporterHttp
import ReliabilityCore

final class InstrumentedHTTPClient: HTTPClient, @unchecked Sendable {
    private let baseClient: BaseHTTPClient
    private let evidenceURL: URL
    private let lock = NSLock()
    private var nextAttemptID = 1

    init(evidenceURL: URL, baseClient: BaseHTTPClient = BaseHTTPClient()) throws {
        self.evidenceURL = evidenceURL
        self.baseClient = baseClient
        try Data().write(to: evidenceURL, options: .atomic)
    }

    func send(
        request: URLRequest,
        completion: @escaping (Result<HTTPURLResponse, any Error>) -> Void
    ) {
        let attemptID = reserveAttemptID()
        let bodyBytes = request.httpBody?.count ?? 0
        let timeoutMilliseconds = Int((request.timeoutInterval * 1_000).rounded())
        append(
            HTTPAttemptEvent(
                attemptID: attemptID,
                phase: .started,
                timestampUnixNanoseconds: Self.nowUnixNanoseconds(),
                requestBodyBytes: bodyBytes,
                timeoutMilliseconds: timeoutMilliseconds
            )
        )

        baseClient.send(request: request) { [weak self] result in
            let outcome: HTTPAttemptOutcome
            let errorDescription: String?
            switch result {
            case .success:
                outcome = .success
                errorDescription = nil
            case .failure(let error):
                outcome = .failure
                errorDescription = String(describing: error)
            }
            self?.append(
                HTTPAttemptEvent(
                    attemptID: attemptID,
                    phase: .completed,
                    timestampUnixNanoseconds: Self.nowUnixNanoseconds(),
                    requestBodyBytes: bodyBytes,
                    timeoutMilliseconds: timeoutMilliseconds,
                    outcome: outcome,
                    errorDescription: errorDescription
                )
            )
            completion(result)
        }
    }

    private func reserveAttemptID() -> Int {
        lock.lock()
        defer { lock.unlock() }
        let attemptID = nextAttemptID
        nextAttemptID += 1
        return attemptID
    }

    private func append(_ event: HTTPAttemptEvent) {
        lock.lock()
        defer { lock.unlock() }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            var data = try encoder.encode(event)
            data.append(0x0A)
            let handle = try FileHandle(forWritingTo: evidenceURL)
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            try handle.close()
        } catch {
            // The run still has its generated ledger and host reconciliation.
            // A missing or incomplete attempt log invalidates request-level claims.
        }
    }

    private static func nowUnixNanoseconds() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1_000_000_000)
    }
}
