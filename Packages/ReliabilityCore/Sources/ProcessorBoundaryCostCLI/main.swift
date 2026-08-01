import Foundation
import ReliabilityCore

private struct SyntheticElement: Codable, Equatable {
    let sequence: Int
    let payload: String
}

private struct ObjectSnapshot: Codable, Equatable {
    let callOrdinal: Int
    let inputFirstSequence: Int
    let inputLastSequence: Int
    let firstSequence: Int
    let lastSequence: Int
    let elementCount: Int
    let encodedByteCount: Int
}

private struct BoundaryReport: Codable {
    let elementCount: Int
    let payloadBytes: Int
    let totalPayloadBytes: Int
    let byteBudget: Int
    let processorBatchSize: Int
    let exportCallCount: Int
    let objectCount: Int
    let encodedObjectBytes: Int
    let objects: [ObjectSnapshot]
}

private enum ProcessorBoundaryError: LocalizedError {
    case usage
    case rejectedElement
    case strategyMismatch(callOrdinal: Int)

    var errorDescription: String? {
        switch self {
        case .usage:
            "usage: reliability-processor-boundary-cost <count> <payload-bytes> <byte-budget> <processor-batch-size>"
        case .rejectedElement:
            "at least one synthetic element is individually oversized"
        case .strategyMismatch(let callOrdinal):
            "binary and additive decisions differ in call \(callOrdinal)"
        }
    }
}

@main
struct ProcessorBoundaryCostCLI {
    static func main() throws {
        guard CommandLine.arguments.count == 5,
              let elementCount = Int(CommandLine.arguments[1]),
              let payloadBytes = Int(CommandLine.arguments[2]),
              let byteBudget = Int(CommandLine.arguments[3]),
              let processorBatchSize = Int(CommandLine.arguments[4]),
              elementCount > 0,
              payloadBytes >= 0,
              byteBudget > 0,
              processorBatchSize > 0 else {
            throw ProcessorBoundaryError.usage
        }

        let elements = (1...elementCount).map {
            SyntheticElement(
                sequence: $0,
                payload: String(repeating: "x", count: payloadBytes)
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let collectionByteCount: ([SyntheticElement]) throws -> Int = { values in
            var data = try encoder.encode(values)
            data.append(0x2C)
            return data.count
        }

        var objects: [ObjectSnapshot] = []
        var callOrdinal = 0
        for batchStart in stride(from: 0, to: elements.count, by: processorBatchSize) {
            callOrdinal += 1
            let batchEnd = min(batchStart + processorBatchSize, elements.count)
            let batch = Array(elements[batchStart..<batchEnd])
            let binary = try ByteBudgetPartitioner(
                byteBudget: byteBudget,
                strategy: .binarySearchEncoding
            ).partition(batch, encodedByteCount: collectionByteCount)
            let additive = try ByteBudgetPartitioner(
                byteBudget: byteBudget,
                strategy: .incrementalJSONElementEncoding
            ).partition(
                batch,
                encodedByteCount: collectionByteCount,
                encodedElementByteCount: { try encoder.encode($0).count }
            )
            let binaryObjects = try snapshots(
                binary,
                callOrdinal: callOrdinal,
                input: batch
            )
            let additiveObjects = try snapshots(
                additive,
                callOrdinal: callOrdinal,
                input: batch
            )
            guard binaryObjects == additiveObjects else {
                throw ProcessorBoundaryError.strategyMismatch(callOrdinal: callOrdinal)
            }
            objects.append(contentsOf: additiveObjects)
        }

        let report = BoundaryReport(
            elementCount: elementCount,
            payloadBytes: payloadBytes,
            totalPayloadBytes: elementCount * payloadBytes,
            byteBudget: byteBudget,
            processorBatchSize: processorBatchSize,
            exportCallCount: callOrdinal,
            objectCount: objects.count,
            encodedObjectBytes: objects.map(\.encodedByteCount).reduce(0, +),
            objects: objects
        )
        let outputEncoder = JSONEncoder()
        outputEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        print(String(decoding: try outputEncoder.encode(report), as: UTF8.self))
    }

    private static func snapshots(
        _ decisions: [ByteBudgetDecision<SyntheticElement>],
        callOrdinal: Int,
        input: [SyntheticElement]
    ) throws -> [ObjectSnapshot] {
        try decisions.map { decision in
            guard case .accepted(let chunk) = decision else {
                throw ProcessorBoundaryError.rejectedElement
            }
            return ObjectSnapshot(
                callOrdinal: callOrdinal,
                inputFirstSequence: input.first!.sequence,
                inputLastSequence: input.last!.sequence,
                firstSequence: chunk.elements.first!.sequence,
                lastSequence: chunk.elements.last!.sequence,
                elementCount: chunk.elements.count,
                encodedByteCount: chunk.encodedByteCount
            )
        }
    }
}
