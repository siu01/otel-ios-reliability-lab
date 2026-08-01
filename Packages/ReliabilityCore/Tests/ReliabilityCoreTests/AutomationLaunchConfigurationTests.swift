import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Automation launch configuration")
struct AutomationLaunchConfigurationTests {
    @Test("parses a fully pinned automated run")
    func parsesPinnedRun() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-autorun",
            "--lab-experiment-id=E001",
            "--lab-run-id=00000000-0000-0000-0000-000000000042",
            "--lab-span-count=250",
            "--lab-transport=http",
            "--lab-persistence=officialInstant",
            "--lab-flush=explicit",
            "--lab-flush-trigger=background",
            "--lab-schedule-delay-ms=5000",
            "--lab-max-export-batch-size=100",
            "--lab-payload-bytes=1536",
            "--lab-secondary-payload-bytes=512",
            "--lab-payload-pattern=alternatingPrimarySecondary",
            "--lab-persistence-object-policy=encodedByteBudget",
            "--lab-persistence-object-byte-budget=240000",
            "--lab-persistence-object-partition-strategy=binarySearchEncoding",
            "--lab-main-queue-probe=enabled",
            "--lab-http-client=instrumentedBase",
            "--lab-exporter=statelessHTTP",
        ])

        #expect(config.shouldAutorun)
        #expect(!config.shouldResume)
        #expect(config.experimentID == ExperimentID(rawValue: "E001"))
        #expect(config.runID == UUID(uuidString: "00000000-0000-0000-0000-000000000042"))
        #expect(config.spanCount == 250)
        #expect(config.transport == .http)
        #expect(config.persistence == .officialInstant)
        #expect(config.flushMode == .explicit)
        #expect(config.flushTrigger == .background)
        #expect(config.processorScheduleDelayMilliseconds == 5_000)
        #expect(config.maxExportBatchSize == 100)
        #expect(config.payloadAttributeBytes == 1_536)
        #expect(config.payloadAttributeSecondaryBytes == 512)
        #expect(config.payloadAttributePattern == .alternatingPrimarySecondary)
        #expect(config.persistenceObjectPolicy == .encodedByteBudget)
        #expect(config.persistenceObjectByteBudget == 240_000)
        #expect(config.persistenceObjectPartitionStrategy == .binarySearchEncoding)
        #expect(config.mainQueueProbeEnabled == true)
        #expect(config.httpClientMode == .instrumentedBase)
        #expect(config.exporterMode == .statelessHTTP)
    }

    @Test("invalid values do not silently become valid defaults")
    func rejectsInvalidValues() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-experiment-id=experiment-one",
            "--lab-span-count=0",
            "--lab-transport=udp",
            "--lab-persistence=yes",
            "--lab-flush=maybe",
            "--lab-flush-trigger=whenever",
            "--lab-schedule-delay-ms=0",
            "--lab-max-export-batch-size=0",
            "--lab-payload-bytes=-1",
            "--lab-secondary-payload-bytes=-1",
            "--lab-payload-pattern=random",
            "--lab-persistence-object-policy=guessByCount",
            "--lab-persistence-object-byte-budget=0",
            "--lab-persistence-object-partition-strategy=randomGuess",
            "--lab-main-queue-probe=sometimes",
            "--lab-http-client=magic",
            "--lab-exporter=rememberEverything",
        ])

        #expect(!config.shouldAutorun)
        #expect(!config.shouldResume)
        #expect(config.experimentID == nil)
        #expect(config.spanCount == nil)
        #expect(config.transport == nil)
        #expect(config.persistence == nil)
        #expect(config.flushMode == nil)
        #expect(config.flushTrigger == nil)
        #expect(config.processorScheduleDelayMilliseconds == nil)
        #expect(config.maxExportBatchSize == nil)
        #expect(config.payloadAttributeBytes == nil)
        #expect(config.payloadAttributeSecondaryBytes == nil)
        #expect(config.payloadAttributePattern == nil)
        #expect(config.persistenceObjectPolicy == nil)
        #expect(config.persistenceObjectByteBudget == nil)
        #expect(config.persistenceObjectPartitionStrategy == nil)
        #expect(config.mainQueueProbeEnabled == nil)
        #expect(config.httpClientMode == nil)
        #expect(config.exporterMode == nil)
    }

    @Test("parses a resume-only persistence launch")
    func parsesResumeLaunch() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-resume",
            "--lab-experiment-id=E005",
            "--lab-run-id=00000000-0000-0000-0005-000000000001",
            "--lab-persistence=officialInstant",
            "--lab-http-client=instrumentedBase",
            "--lab-exporter=statelessHTTP",
        ])

        #expect(!config.shouldAutorun)
        #expect(config.shouldResume)
        #expect(config.experimentID == ExperimentID(rawValue: "E005"))
        #expect(config.persistence == .officialInstant)
        #expect(config.httpClientMode == .instrumentedBase)
        #expect(config.exporterMode == .statelessHTTP)
    }

    @Test("parses a durability barrier flush")
    func parsesDurabilityBarrier() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-flush=durabilityBarrier",
        ])

        #expect(config.flushMode == .durabilityBarrier)
    }

    @Test("parses an explicitly disabled main-queue probe")
    func parsesDisabledMainQueueProbe() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-main-queue-probe=disabled",
        ])

        #expect(config.mainQueueProbeEnabled == false)
    }

    @Test("parses the additive JSON element strategy")
    func parsesAdditiveJSONStrategy() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-persistence-object-partition-strategy=incrementalJSONElementEncoding",
        ])

        #expect(
            config.persistenceObjectPartitionStrategy == .incrementalJSONElementEncoding
        )
    }
}
