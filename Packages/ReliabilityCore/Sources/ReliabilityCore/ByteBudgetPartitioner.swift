public struct ByteBudgetChunk<Element> {
    public let elements: [Element]
    public let encodedByteCount: Int

    public init(elements: [Element], encodedByteCount: Int) {
        self.elements = elements
        self.encodedByteCount = encodedByteCount
    }
}

public struct ByteBudgetRejection<Element> {
    public let element: Element
    public let encodedByteCount: Int

    public init(element: Element, encodedByteCount: Int) {
        self.element = element
        self.encodedByteCount = encodedByteCount
    }
}

public enum ByteBudgetDecision<Element> {
    case accepted(ByteBudgetChunk<Element>)
    case rejected(ByteBudgetRejection<Element>)
}

public enum ByteBudgetPartitionerError: Error, Equatable {
    case invalidEncodedByteCount(Int)
}

public struct ByteBudgetPartitioner: Sendable {
    public let byteBudget: Int
    public let strategy: ByteBudgetPartitionStrategy

    public init(
        byteBudget: Int,
        strategy: ByteBudgetPartitionStrategy = .linearPrefixEncoding
    ) {
        precondition(byteBudget > 0, "A byte budget must be positive")
        self.byteBudget = byteBudget
        self.strategy = strategy
    }

    public func partition<Element>(
        _ elements: [Element],
        encodedByteCount: ([Element]) throws -> Int
    ) throws -> [ByteBudgetDecision<Element>] {
        switch strategy {
        case .linearPrefixEncoding:
            try partitionLinearly(elements, encodedByteCount: encodedByteCount)
        case .binarySearchEncoding:
            try partitionWithBinarySearch(elements, encodedByteCount: encodedByteCount)
        }
    }

    private func partitionLinearly<Element>(
        _ elements: [Element],
        encodedByteCount: ([Element]) throws -> Int
    ) throws -> [ByteBudgetDecision<Element>] {
        var decisions: [ByteBudgetDecision<Element>] = []
        var currentElements: [Element] = []
        var currentByteCount = 0

        for element in elements {
            let candidateElements = currentElements + [element]
            let candidateByteCount = try validatedByteCount(
                encodedByteCount(candidateElements)
            )

            if candidateByteCount <= byteBudget {
                currentElements = candidateElements
                currentByteCount = candidateByteCount
                continue
            }

            if !currentElements.isEmpty {
                decisions.append(.accepted(ByteBudgetChunk(
                    elements: currentElements,
                    encodedByteCount: currentByteCount
                )))
            }

            let singleByteCount = currentElements.isEmpty
                ? candidateByteCount
                : try validatedByteCount(encodedByteCount([element]))
            if singleByteCount <= byteBudget {
                currentElements = [element]
                currentByteCount = singleByteCount
            } else {
                decisions.append(.rejected(ByteBudgetRejection(
                    element: element,
                    encodedByteCount: singleByteCount
                )))
                currentElements = []
                currentByteCount = 0
            }
        }

        if !currentElements.isEmpty {
            decisions.append(.accepted(ByteBudgetChunk(
                elements: currentElements,
                encodedByteCount: currentByteCount
            )))
        }

        return decisions
    }

    private func partitionWithBinarySearch<Element>(
        _ elements: [Element],
        encodedByteCount: ([Element]) throws -> Int
    ) throws -> [ByteBudgetDecision<Element>] {
        var decisions: [ByteBudgetDecision<Element>] = []
        var startIndex = 0

        while startIndex < elements.count {
            let singleElement = elements[startIndex]
            let singleByteCount = try validatedByteCount(
                encodedByteCount([singleElement])
            )
            guard singleByteCount <= byteBudget else {
                decisions.append(.rejected(ByteBudgetRejection(
                    element: singleElement,
                    encodedByteCount: singleByteCount
                )))
                startIndex += 1
                continue
            }

            var largestFittingEnd = startIndex + 1
            var upperEnd = elements.count
            var largestFittingByteCount = singleByteCount

            while largestFittingEnd < upperEnd {
                let candidateEnd = (largestFittingEnd + upperEnd + 1) / 2
                let candidate = Array(elements[startIndex..<candidateEnd])
                let candidateByteCount = try validatedByteCount(
                    encodedByteCount(candidate)
                )
                if candidateByteCount <= byteBudget {
                    largestFittingEnd = candidateEnd
                    largestFittingByteCount = candidateByteCount
                } else {
                    upperEnd = candidateEnd - 1
                }
            }

            let chunkElements = Array(elements[startIndex..<largestFittingEnd])
            decisions.append(.accepted(ByteBudgetChunk(
                elements: chunkElements,
                encodedByteCount: largestFittingByteCount
            )))
            startIndex = largestFittingEnd
        }

        return decisions
    }

    private func validatedByteCount(_ byteCount: Int) throws -> Int {
        guard byteCount >= 0 else {
            throw ByteBudgetPartitionerError.invalidEncodedByteCount(byteCount)
        }
        return byteCount
    }
}
public enum ByteBudgetPartitionStrategy: String, Codable, Sendable {
    case linearPrefixEncoding
    case binarySearchEncoding
}
