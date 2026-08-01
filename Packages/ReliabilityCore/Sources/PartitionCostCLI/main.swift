import Foundation
import ReliabilityCore

private struct SyntheticElement: Codable, Equatable {
    let sequence: Int
    let payload: String
}

private struct PartitionSnapshot: Codable, Equatable {
    let outcome: String
    let firstSequence: Int
    let lastSequence: Int
    let elementCount: Int
    let encodedByteCount: Int
}

private struct StrategyCost: Codable {
    let collectionEncoderCalls: Int
    let elementEncoderCalls: Int
    let encodedOutputBytes: Int
    let partitions: [PartitionSnapshot]
}

private struct CostReport: Codable {
    let elementCount: Int
    let payloadBytes: Int
    let byteBudget: Int
    let binary: StrategyCost
    let incremental: StrategyCost
    let encodedOutputByteReductionPercent: Double
}

private struct EncoderCounter {
    var collectionCalls = 0
    var elementCalls = 0
    var outputBytes = 0
}

private enum PartitionCostError: LocalizedError {
    case usage
    case decisionsDiffer

    var errorDescription: String? {
        switch self {
        case .usage:
            "usage: reliability-partition-cost <element-count> <payload-bytes> <byte-budget>"
        case .decisionsDiffer:
            "incremental decisions differ from exact binary search"
        }
    }
}

@main
struct PartitionCostCLI {
    static func main() throws {
        guard CommandLine.arguments.count == 4,
              let elementCount = Int(CommandLine.arguments[1]),
              let payloadBytes = Int(CommandLine.arguments[2]),
              let byteBudget = Int(CommandLine.arguments[3]),
              elementCount > 0,
              payloadBytes >= 0,
              byteBudget > 0 else {
            throw PartitionCostError.usage
        }

        let elements = (1...elementCount).map {
            SyntheticElement(
                sequence: $0,
                payload: String(repeating: "x", count: payloadBytes)
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        var binaryCounter = EncoderCounter()
        let binaryDecisions = try ByteBudgetPartitioner(
            byteBudget: byteBudget,
            strategy: .binarySearchEncoding
        ).partition(elements) { values in
            binaryCounter.collectionCalls += 1
            var data = try encoder.encode(values)
            data.append(0x2C)
            binaryCounter.outputBytes += data.count
            return data.count
        }

        var incrementalCounter = EncoderCounter()
        let incrementalDecisions = try ByteBudgetPartitioner(
            byteBudget: byteBudget,
            strategy: .incrementalJSONElementEncoding
        ).partition(
            elements,
            encodedByteCount: { values in
                incrementalCounter.collectionCalls += 1
                var data = try encoder.encode(values)
                data.append(0x2C)
                incrementalCounter.outputBytes += data.count
                return data.count
            },
            encodedElementByteCount: { value in
                incrementalCounter.elementCalls += 1
                let data = try encoder.encode(value)
                incrementalCounter.outputBytes += data.count
                return data.count
            }
        )

        let binarySnapshots = snapshots(binaryDecisions)
        let incrementalSnapshots = snapshots(incrementalDecisions)
        guard binarySnapshots == incrementalSnapshots else {
            throw PartitionCostError.decisionsDiffer
        }

        let reduction = 100 * (
            1 - Double(incrementalCounter.outputBytes) / Double(binaryCounter.outputBytes)
        )
        let report = CostReport(
            elementCount: elementCount,
            payloadBytes: payloadBytes,
            byteBudget: byteBudget,
            binary: StrategyCost(
                collectionEncoderCalls: binaryCounter.collectionCalls,
                elementEncoderCalls: binaryCounter.elementCalls,
                encodedOutputBytes: binaryCounter.outputBytes,
                partitions: binarySnapshots
            ),
            incremental: StrategyCost(
                collectionEncoderCalls: incrementalCounter.collectionCalls,
                elementEncoderCalls: incrementalCounter.elementCalls,
                encodedOutputBytes: incrementalCounter.outputBytes,
                partitions: incrementalSnapshots
            ),
            encodedOutputByteReductionPercent: reduction
        )

        let outputEncoder = JSONEncoder()
        outputEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        print(String(decoding: try outputEncoder.encode(report), as: UTF8.self))
    }

    private static func snapshots(
        _ decisions: [ByteBudgetDecision<SyntheticElement>]
    ) -> [PartitionSnapshot] {
        decisions.map { decision in
            switch decision {
            case .accepted(let chunk):
                PartitionSnapshot(
                    outcome: "accepted",
                    firstSequence: chunk.elements.first!.sequence,
                    lastSequence: chunk.elements.last!.sequence,
                    elementCount: chunk.elements.count,
                    encodedByteCount: chunk.encodedByteCount
                )
            case .rejected(let rejection):
                PartitionSnapshot(
                    outcome: "rejected",
                    firstSequence: rejection.element.sequence,
                    lastSequence: rejection.element.sequence,
                    elementCount: 1,
                    encodedByteCount: rejection.encodedByteCount
                )
            }
        }
    }
}
