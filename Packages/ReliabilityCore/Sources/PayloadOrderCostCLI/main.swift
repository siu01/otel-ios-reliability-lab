import Foundation
import ReliabilityCore

private struct SyntheticElement: Codable, Equatable {
    let sequence: Int
    let payload: String
}

private struct ChunkSnapshot: Codable, Equatable {
    let firstSequence: Int
    let lastSequence: Int
    let elementCount: Int
    let encodedByteCount: Int
}

private struct OrderCostReport: Codable {
    let elementCount: Int
    let primaryPayloadBytes: Int
    let secondaryPayloadBytes: Int
    let primaryElementCount: Int
    let secondaryElementCount: Int
    let totalPayloadBytes: Int
    let payloadPattern: PayloadAttributePattern
    let byteBudget: Int
    let binaryChunks: [ChunkSnapshot]
    let incrementalChunks: [ChunkSnapshot]
}

private enum PayloadOrderCostError: LocalizedError {
    case usage
    case decisionsDiffer
    case rejectedElement

    var errorDescription: String? {
        switch self {
        case .usage:
            "usage: reliability-payload-order-cost <count> <primary-bytes> <secondary-bytes> <byte-budget> <payload-pattern>"
        case .decisionsDiffer:
            "binary and incremental partition decisions differ"
        case .rejectedElement:
            "at least one synthetic element is individually oversized"
        }
    }
}

@main
struct PayloadOrderCostCLI {
    static func main() throws {
        guard CommandLine.arguments.count == 6,
              let elementCount = Int(CommandLine.arguments[1]),
              let primaryBytes = Int(CommandLine.arguments[2]),
              let secondaryBytes = Int(CommandLine.arguments[3]),
              let byteBudget = Int(CommandLine.arguments[4]),
              let pattern = PayloadAttributePattern(rawValue: CommandLine.arguments[5]),
              elementCount > 0,
              primaryBytes >= 0,
              secondaryBytes >= 0,
              byteBudget > 0 else {
            throw PayloadOrderCostError.usage
        }

        let payloadSizes = (1...elementCount).map {
            pattern.byteCount(
                forSequence: $0,
                plannedSpanCount: elementCount,
                primaryBytes: primaryBytes,
                secondaryBytes: secondaryBytes
            )
        }
        let elements = zip(1...elementCount, payloadSizes).map {
            SyntheticElement(
                sequence: $0.0,
                payload: String(repeating: "x", count: $0.1)
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let collectionByteCount: ([SyntheticElement]) throws -> Int = { values in
            var data = try encoder.encode(values)
            data.append(0x2C)
            return data.count
        }

        let binaryDecisions = try ByteBudgetPartitioner(
            byteBudget: byteBudget,
            strategy: .binarySearchEncoding
        ).partition(elements, encodedByteCount: collectionByteCount)
        let incrementalDecisions = try ByteBudgetPartitioner(
            byteBudget: byteBudget,
            strategy: .incrementalJSONElementEncoding
        ).partition(
            elements,
            encodedByteCount: collectionByteCount,
            encodedElementByteCount: { try encoder.encode($0).count }
        )
        let binaryChunks = try chunks(binaryDecisions)
        let incrementalChunks = try chunks(incrementalDecisions)
        guard binaryChunks == incrementalChunks else {
            throw PayloadOrderCostError.decisionsDiffer
        }

        let report = OrderCostReport(
            elementCount: elementCount,
            primaryPayloadBytes: primaryBytes,
            secondaryPayloadBytes: secondaryBytes,
            primaryElementCount: payloadSizes.count { $0 == primaryBytes },
            secondaryElementCount: payloadSizes.count { $0 == secondaryBytes },
            totalPayloadBytes: payloadSizes.reduce(0, +),
            payloadPattern: pattern,
            byteBudget: byteBudget,
            binaryChunks: binaryChunks,
            incrementalChunks: incrementalChunks
        )
        let outputEncoder = JSONEncoder()
        outputEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        print(String(decoding: try outputEncoder.encode(report), as: UTF8.self))
    }

    private static func chunks(
        _ decisions: [ByteBudgetDecision<SyntheticElement>]
    ) throws -> [ChunkSnapshot] {
        try decisions.map { decision in
            guard case .accepted(let chunk) = decision else {
                throw PayloadOrderCostError.rejectedElement
            }
            return ChunkSnapshot(
                firstSequence: chunk.elements.first!.sequence,
                lastSequence: chunk.elements.last!.sequence,
                elementCount: chunk.elements.count,
                encodedByteCount: chunk.encodedByteCount
            )
        }
    }
}
