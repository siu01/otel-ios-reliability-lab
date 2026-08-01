import Testing
@testable import ReliabilityCore

@Suite("Payload attribute pattern")
struct PayloadAttributePatternTests {
    @Test("constant always selects the primary payload")
    func constantPattern() {
        let observedSizes = (1...5).map {
            PayloadAttributePattern.constant.byteCount(
                forSequence: $0,
                plannedSpanCount: 5,
                primaryBytes: 10,
                secondaryBytes: 4
            )
        }

        #expect(observedSizes == [10, 10, 10, 10, 10])
    }

    @Test("alternating starts with primary and preserves odd-run counts")
    func alternatingPattern() {
        let observedSizes = sizes(for: .alternatingPrimarySecondary, count: 5)

        #expect(observedSizes == [10, 4, 10, 4, 10])
    }

    @Test("primary-first grouping keeps the same multiset as alternating")
    func primaryFirstPattern() {
        let observedSizes = sizes(for: .groupedPrimaryFirst, count: 5)

        #expect(observedSizes == [10, 10, 10, 4, 4])
        #expect(
            observedSizes.sorted() == sizes(
                for: .alternatingPrimarySecondary,
                count: 5
            ).sorted()
        )
    }

    @Test("secondary-first grouping keeps the same multiset as alternating")
    func secondaryFirstPattern() {
        let observedSizes = sizes(for: .groupedSecondaryFirst, count: 5)

        #expect(observedSizes == [4, 4, 10, 10, 10])
        #expect(
            observedSizes.sorted() == sizes(
                for: .alternatingPrimarySecondary,
                count: 5
            ).sorted()
        )
    }

    private func sizes(for pattern: PayloadAttributePattern, count: Int) -> [Int] {
        (1...count).map {
            pattern.byteCount(
                forSequence: $0,
                plannedSpanCount: count,
                primaryBytes: 10,
                secondaryBytes: 4
            )
        }
    }
}
