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
}
