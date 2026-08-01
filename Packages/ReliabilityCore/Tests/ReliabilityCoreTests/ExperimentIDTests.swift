import Testing
@testable import ReliabilityCore

@Suite("Experiment ID")
struct ExperimentIDTests {
    @Test("accepts the canonical E plus three digits format")
    func acceptsCanonicalFormat() {
        #expect(ExperimentID(rawValue: "E000")?.description == "E000")
        #expect(ExperimentID(rawValue: "E999")?.description == "E999")
    }

    @Test(
        "rejects ambiguous IDs",
        arguments: ["e001", "E01", "E0001", "A001", "E0A1", ""]
    )
    func rejectsInvalidFormat(value: String) {
        #expect(ExperimentID(rawValue: value) == nil)
    }
}

