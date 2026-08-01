import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Byte budget partitioner")
struct ByteBudgetPartitionerTests {
    @Test("returns no decisions for empty input")
    func emptyInput() throws {
        let decisions = try ByteBudgetPartitioner(byteBudget: 10).partition(
            [Int](),
            encodedByteCount: { $0.reduce(0, +) }
        )

        #expect(decisions.isEmpty)
    }

    @Test("keeps an exact-boundary candidate in one chunk")
    func exactBoundary() throws {
        let decisions = try ByteBudgetPartitioner(byteBudget: 10).partition(
            [2, 3, 5],
            encodedByteCount: { $0.reduce(0, +) }
        )

        let chunk = try #require(acceptedChunk(at: 0, in: decisions))
        #expect(chunk.elements == [2, 3, 5])
        #expect(chunk.encodedByteCount == 10)
        #expect(decisions.count == 1)
    }

    @Test("splits immediately before a candidate crosses the budget")
    func splitsCandidate() throws {
        let decisions = try ByteBudgetPartitioner(byteBudget: 10).partition(
            [4, 4, 4],
            encodedByteCount: { $0.reduce(0, +) }
        )

        #expect(acceptedChunk(at: 0, in: decisions)?.elements == [4, 4])
        #expect(acceptedChunk(at: 0, in: decisions)?.encodedByteCount == 8)
        #expect(acceptedChunk(at: 1, in: decisions)?.elements == [4])
        #expect(acceptedChunk(at: 1, in: decisions)?.encodedByteCount == 4)
        #expect(decisions.count == 2)
    }

    @Test("rejects an indivisible element and continues partitioning")
    func rejectsOversizeElement() throws {
        let decisions = try ByteBudgetPartitioner(byteBudget: 10).partition(
            [4, 11, 6, 4],
            encodedByteCount: { $0.reduce(0, +) }
        )

        #expect(acceptedChunk(at: 0, in: decisions)?.elements == [4])
        #expect(rejectedElement(at: 1, in: decisions)?.element == 11)
        #expect(rejectedElement(at: 1, in: decisions)?.encodedByteCount == 11)
        #expect(acceptedChunk(at: 2, in: decisions)?.elements == [6, 4])
        #expect(decisions.count == 3)
    }

    @Test("rejects invalid negative encoder output")
    func rejectsInvalidEncoderOutput() {
        #expect(throws: ByteBudgetPartitionerError.invalidEncodedByteCount(-1)) {
            try ByteBudgetPartitioner(byteBudget: 10).partition(
                [1],
                encodedByteCount: { _ in -1 }
            )
        }
    }

    @Test("binary search preserves linear maximal-prefix decisions")
    func binarySearchMatchesLinearStrategy() throws {
        let elements = [4, 4, 11, 6, 4, 3, 3, 3]
        let linear = try decisionSnapshot(
            ByteBudgetPartitioner(
                byteBudget: 10,
                strategy: .linearPrefixEncoding
            ).partition(elements, encodedByteCount: { $0.reduce(0, +) })
        )
        let binary = try decisionSnapshot(
            ByteBudgetPartitioner(
                byteBudget: 10,
                strategy: .binarySearchEncoding
            ).partition(elements, encodedByteCount: { $0.reduce(0, +) })
        )

        #expect(binary == linear)
    }

    @Test("binary search bounds encoder calls for five hundred elements")
    func binarySearchBoundsEncoderCalls() throws {
        var invocationCount = 0
        let decisions = try ByteBudgetPartitioner(
            byteBudget: 243,
            strategy: .binarySearchEncoding
        ).partition(Array(repeating: 1, count: 500)) { values in
            invocationCount += 1
            return values.count
        }

        #expect(acceptedChunk(at: 0, in: decisions)?.elements.count == 243)
        #expect(acceptedChunk(at: 1, in: decisions)?.elements.count == 243)
        #expect(acceptedChunk(at: 2, in: decisions)?.elements.count == 14)
        #expect(invocationCount < 30)
    }

    @Test("incremental JSON encoding matches exact maximal prefixes")
    func incrementalJSONMatchesExactStrategies() throws {
        let elements = ["a", "bbbb", "🙂", String(repeating: "z", count: 18), "end"]
        let budget = 24
        let exactCount: ([String]) throws -> Int = { values in
            var data = try JSONEncoder().encode(values)
            data.append(0x2C)
            return data.count
        }
        let elementCount: (String) throws -> Int = { value in
            try JSONEncoder().encode(value).count
        }

        let binary = try stringDecisionSnapshot(ByteBudgetPartitioner(
            byteBudget: budget,
            strategy: .binarySearchEncoding
        ).partition(elements, encodedByteCount: exactCount))
        let incremental = try stringDecisionSnapshot(ByteBudgetPartitioner(
            byteBudget: budget,
            strategy: .incrementalJSONElementEncoding
        ).partition(
            elements,
            encodedByteCount: exactCount,
            encodedElementByteCount: elementCount
        ))

        #expect(incremental == binary)
    }

    @Test("incremental JSON strategy requires an element encoder")
    func incrementalJSONRequiresElementEncoder() {
        #expect(throws: ByteBudgetPartitionerError.missingEncodedElementByteCount) {
            try ByteBudgetPartitioner(
                byteBudget: 10,
                strategy: .incrementalJSONElementEncoding
            ).partition([1], encodedByteCount: { $0.reduce(0, +) })
        }
    }

    @Test("incremental JSON fails closed when collection encoding is not additive")
    func incrementalJSONRejectsShapeMismatch() {
        #expect(throws: ByteBudgetPartitionerError.additiveEncodingMismatch(
            estimated: 7,
            actual: 8,
            elementCount: 2
        )) {
            try ByteBudgetPartitioner(
                byteBudget: 10,
                strategy: .incrementalJSONElementEncoding
            ).partition(
                [1, 2],
                encodedByteCount: { values in
                    values.reduce(0, +) + (values.count == 1 ? 3 : 5)
                },
                encodedElementByteCount: { $0 }
            )
        }
    }

    @Test("incremental JSON reports byte-count overflow")
    func incrementalJSONReportsOverflow() {
        #expect(throws: ByteBudgetPartitionerError.encodedByteCountOverflow) {
            try ByteBudgetPartitioner(
                byteBudget: 10,
                strategy: .incrementalJSONElementEncoding
            ).partition(
                [1],
                encodedByteCount: { _ in 1 },
                encodedElementByteCount: { _ in Int.max }
            )
        }
    }

    @Test("incremental JSON matches binary across deterministic heterogeneous cases")
    func incrementalJSONMatchesDeterministicCases() throws {
        var generator = DeterministicGenerator(state: 0xE017_C0DE)
        let tokens = ["a", "\"", "\\", "🙂", "\n"]

        for _ in 0..<200 {
            let elementCount = generator.nextInt(in: 1...80)
            let elements = (0..<elementCount).map { _ in
                let token = tokens[generator.nextInt(in: 0...(tokens.count - 1))]
                return String(repeating: token, count: generator.nextInt(in: 0...64))
            }
            let budget = generator.nextInt(in: 8...250)
            let exactCount: ([String]) throws -> Int = { values in
                var data = try JSONEncoder().encode(values)
                data.append(0x2C)
                return data.count
            }
            let elementByteCount: (String) throws -> Int = {
                try JSONEncoder().encode($0).count
            }

            let binary = try stringDecisionSnapshot(ByteBudgetPartitioner(
                byteBudget: budget,
                strategy: .binarySearchEncoding
            ).partition(elements, encodedByteCount: exactCount))
            let incremental = try stringDecisionSnapshot(ByteBudgetPartitioner(
                byteBudget: budget,
                strategy: .incrementalJSONElementEncoding
            ).partition(
                elements,
                encodedByteCount: exactCount,
                encodedElementByteCount: elementByteCount
            ))

            #expect(incremental == binary)
        }
    }

    private func acceptedChunk<Element>(
        at index: Int,
        in decisions: [ByteBudgetDecision<Element>]
    ) -> ByteBudgetChunk<Element>? {
        guard decisions.indices.contains(index),
              case .accepted(let chunk) = decisions[index] else {
            return nil
        }
        return chunk
    }

    private func rejectedElement<Element>(
        at index: Int,
        in decisions: [ByteBudgetDecision<Element>]
    ) -> ByteBudgetRejection<Element>? {
        guard decisions.indices.contains(index),
              case .rejected(let rejection) = decisions[index] else {
            return nil
        }
        return rejection
    }

    private func decisionSnapshot(
        _ decisions: [ByteBudgetDecision<Int>]
    ) throws -> [String] {
        decisions.map { decision in
            switch decision {
            case .accepted(let chunk):
                "accepted:\(chunk.elements):\(chunk.encodedByteCount)"
            case .rejected(let rejection):
                "rejected:\(rejection.element):\(rejection.encodedByteCount)"
            }
        }
    }

    private func stringDecisionSnapshot(
        _ decisions: [ByteBudgetDecision<String>]
    ) throws -> [String] {
        decisions.map { decision in
            switch decision {
            case .accepted(let chunk):
                "accepted:\(chunk.elements):\(chunk.encodedByteCount)"
            case .rejected(let rejection):
                "rejected:\(rejection.element):\(rejection.encodedByteCount)"
            }
        }
    }
}

private struct DeterministicGenerator {
    var state: UInt64

    mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let width = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(state % width)
    }
}
