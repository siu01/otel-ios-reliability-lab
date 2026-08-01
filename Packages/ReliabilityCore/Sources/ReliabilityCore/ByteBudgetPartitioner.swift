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
    case missingEncodedElementByteCount
    case encodedByteCountOverflow
    case additiveEncodingMismatch(estimated: Int, actual: Int, elementCount: Int)
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
        encodedByteCount: ([Element]) throws -> Int,
        encodedElementByteCount: ((Element) throws -> Int)? = nil
    ) throws -> [ByteBudgetDecision<Element>] {
        switch strategy {
        case .linearPrefixEncoding:
            return try partitionLinearly(elements, encodedByteCount: encodedByteCount)
        case .binarySearchEncoding:
            return try partitionWithBinarySearch(elements, encodedByteCount: encodedByteCount)
        case .incrementalJSONElementEncoding:
            guard let encodedElementByteCount else {
                throw ByteBudgetPartitionerError.missingEncodedElementByteCount
            }
            return try partitionIncrementally(
                elements,
                encodedByteCount: encodedByteCount,
                encodedElementByteCount: encodedElementByteCount
            )
        }
    }

    private func partitionIncrementally<Element>(
        _ elements: [Element],
        encodedByteCount: ([Element]) throws -> Int,
        encodedElementByteCount: (Element) throws -> Int
    ) throws -> [ByteBudgetDecision<Element>] {
        var decisions: [ByteBudgetDecision<Element>] = []
        var currentElements: [Element] = []
        var currentEstimatedByteCount = 0

        for element in elements {
            let elementByteCount = try validatedByteCount(
                encodedElementByteCount(element)
            )
            let candidateByteCount: Int
            if currentElements.isEmpty {
                candidateByteCount = try checkedSum(elementByteCount, 3)
            } else {
                candidateByteCount = try checkedSum(
                    currentEstimatedByteCount,
                    1,
                    elementByteCount
                )
            }

            if candidateByteCount <= byteBudget {
                currentElements.append(element)
                currentEstimatedByteCount = candidateByteCount
                continue
            }

            if !currentElements.isEmpty {
                decisions.append(.accepted(try validatedAdditiveChunk(
                    currentElements,
                    estimatedByteCount: currentEstimatedByteCount,
                    encodedByteCount: encodedByteCount
                )))
            }

            let singleElements = [element]
            let singleEstimatedByteCount = try checkedSum(elementByteCount, 3)
            let singleActualByteCount = try validatedByteCount(
                encodedByteCount(singleElements)
            )
            try validateAdditiveEstimate(
                singleEstimatedByteCount,
                actualByteCount: singleActualByteCount,
                elementCount: 1
            )

            if singleActualByteCount <= byteBudget {
                currentElements = singleElements
                currentEstimatedByteCount = singleActualByteCount
            } else {
                decisions.append(.rejected(ByteBudgetRejection(
                    element: element,
                    encodedByteCount: singleActualByteCount
                )))
                currentElements = []
                currentEstimatedByteCount = 0
            }
        }

        if !currentElements.isEmpty {
            decisions.append(.accepted(try validatedAdditiveChunk(
                currentElements,
                estimatedByteCount: currentEstimatedByteCount,
                encodedByteCount: encodedByteCount
            )))
        }

        return decisions
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

    private func validatedAdditiveChunk<Element>(
        _ elements: [Element],
        estimatedByteCount: Int,
        encodedByteCount: ([Element]) throws -> Int
    ) throws -> ByteBudgetChunk<Element> {
        let actualByteCount = try validatedByteCount(encodedByteCount(elements))
        try validateAdditiveEstimate(
            estimatedByteCount,
            actualByteCount: actualByteCount,
            elementCount: elements.count
        )
        return ByteBudgetChunk(elements: elements, encodedByteCount: actualByteCount)
    }

    private func validateAdditiveEstimate(
        _ estimatedByteCount: Int,
        actualByteCount: Int,
        elementCount: Int
    ) throws {
        guard estimatedByteCount == actualByteCount else {
            throw ByteBudgetPartitionerError.additiveEncodingMismatch(
                estimated: estimatedByteCount,
                actual: actualByteCount,
                elementCount: elementCount
            )
        }
    }

    private func checkedSum(_ values: Int...) throws -> Int {
        try values.reduce(0) { partialResult, value in
            let (sum, overflow) = partialResult.addingReportingOverflow(value)
            guard !overflow else {
                throw ByteBudgetPartitionerError.encodedByteCountOverflow
            }
            return sum
        }
    }
}
public enum ByteBudgetPartitionStrategy: String, Codable, Sendable {
    case linearPrefixEncoding
    case binarySearchEncoding
    case incrementalJSONElementEncoding
}
