import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk
import ReliabilityCore

final class ByteBudgetingSpanExporter: SpanExporter, @unchecked Sendable {
    private let wrappedExporter: any SpanExporter
    private let partitioner: ByteBudgetPartitioner
    private let eventStore: PersistenceObjectPolicyEventStore
    private let ordinalLock = NSLock()
    private var nextCallOrdinal = 1

    init(
        wrappedExporter: any SpanExporter,
        byteBudget: Int,
        strategy: ByteBudgetPartitionStrategy,
        eventStore: PersistenceObjectPolicyEventStore
    ) {
        self.wrappedExporter = wrappedExporter
        partitioner = ByteBudgetPartitioner(
            byteBudget: byteBudget,
            strategy: strategy
        )
        self.eventStore = eventStore
    }

    @discardableResult
    func export(
        spans: [SpanData],
        explicitTimeout: TimeInterval?
    ) -> SpanExporterResultCode {
        let callOrdinal = claimCallOrdinal()
        let decisions: [ByteBudgetDecision<SpanData>]
        do {
            decisions = try partitioner.partition(
                spans,
                encodedByteCount: Self.encodedPersistenceObjectByteCount
            )
        } catch {
            try? eventStore.append(makeEvent(
                callOrdinal: callOrdinal,
                decisionOrdinal: 1,
                outcome: .encodingFailed,
                inputSpanCount: spans.count,
                spans: spans,
                encodedByteCount: nil
            ))
            return .failure
        }

        var aggregateResult: SpanExporterResultCode = .success
        var eventOrdinal = 1

        for decision in decisions {
            switch decision {
            case .accepted(let chunk):
                let acceptedEvent = makeEvent(
                    callOrdinal: callOrdinal,
                    decisionOrdinal: eventOrdinal,
                    outcome: .acceptedChunk,
                    inputSpanCount: spans.count,
                    spans: chunk.elements,
                    encodedByteCount: chunk.encodedByteCount
                )
                eventOrdinal += 1

                do {
                    try eventStore.append(acceptedEvent)
                } catch {
                    aggregateResult = .failure
                    continue
                }

                let result = wrappedExporter.export(
                    spans: chunk.elements,
                    explicitTimeout: explicitTimeout
                )
                if case .failure = result {
                    aggregateResult = .failure
                    try? eventStore.append(makeEvent(
                        callOrdinal: callOrdinal,
                        decisionOrdinal: eventOrdinal,
                        outcome: .wrappedExporterFailed,
                        inputSpanCount: spans.count,
                        spans: chunk.elements,
                        encodedByteCount: chunk.encodedByteCount
                    ))
                    eventOrdinal += 1
                }

            case .rejected(let rejection):
                aggregateResult = .failure
                try? eventStore.append(makeEvent(
                    callOrdinal: callOrdinal,
                    decisionOrdinal: eventOrdinal,
                    outcome: .rejectedOversize,
                    inputSpanCount: spans.count,
                    spans: [rejection.element],
                    encodedByteCount: rejection.encodedByteCount
                ))
                eventOrdinal += 1
            }
        }

        return aggregateResult
    }

    func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        wrappedExporter.flush(explicitTimeout: explicitTimeout)
    }

    func shutdown(explicitTimeout: TimeInterval?) {
        wrappedExporter.shutdown(explicitTimeout: explicitTimeout)
    }

    private static func encodedPersistenceObjectByteCount(_ spans: [SpanData]) throws -> Int {
        var data = try JSONEncoder().encode(spans)
        data.append(0x2C)
        return data.count
    }

    private func claimCallOrdinal() -> Int {
        ordinalLock.lock()
        defer { ordinalLock.unlock() }
        let ordinal = nextCallOrdinal
        nextCallOrdinal += 1
        return ordinal
    }

    private func makeEvent(
        callOrdinal: Int,
        decisionOrdinal: Int,
        outcome: PersistenceObjectPolicyOutcome,
        inputSpanCount: Int,
        spans: [SpanData],
        encodedByteCount: Int?
    ) -> PersistenceObjectPolicyEvent {
        PersistenceObjectPolicyEvent(
            callOrdinal: callOrdinal,
            decisionOrdinal: decisionOrdinal,
            outcome: outcome,
            inputSpanCount: inputSpanCount,
            spanCount: spans.count,
            encodedByteCount: encodedByteCount,
            byteBudget: partitioner.byteBudget,
            sequences: spans.compactMap(Self.sequence),
            spanIDs: spans.map { $0.spanId.hexString }
        )
    }

    private static func sequence(from span: SpanData) -> Int? {
        guard case .int(let sequence) = span.attributes["lab.sequence"] else {
            return nil
        }
        return sequence
    }
}
