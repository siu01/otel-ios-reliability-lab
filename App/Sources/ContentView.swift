import ReliabilityCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: ExperimentController

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    configurationCard
                    metrics
                    actionCard
                    evidenceNote
                }
                .padding(20)
            }
            .background(background.ignoresSafeArea())
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SPAN SURVIVAL LAB")
                .font(.caption.weight(.bold))
                .tracking(2.4)
                .foregroundStyle(.mint)

            Text("How much telemetry survives?")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            HStack(spacing: 8) {
                Label(controller.experimentID.rawValue, systemImage: "testtube.2")
                Text("•")
                Text(controller.status)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private var configurationCard: some View {
        LabCard(title: "Run configuration", icon: "slider.horizontal.3") {
            VStack(spacing: 16) {
                Picker("Transport", selection: $controller.transport) {
                    Text("HTTP").tag(Transport.http)
                    Text("gRPC").tag(Transport.grpc)
                }
                .pickerStyle(.segmented)

                Picker("Persistence", selection: $controller.persistence) {
                    Text("None").tag(PersistenceMode.disabled)
                    Text("Default").tag(PersistenceMode.officialDefault)
                    Text("Instant").tag(PersistenceMode.officialInstant)
                }
                .pickerStyle(.segmented)

                Stepper(value: $controller.plannedSpanCount, in: 10...1_000, step: 10) {
                    HStack {
                        Text("Planned spans")
                        Spacer()
                        Text(controller.plannedSpanCount.formatted())
                            .font(.body.monospacedDigit().weight(.semibold))
                    }
                }
            }
        }
    }

    private var metrics: some View {
        HStack(spacing: 12) {
            MetricCard(label: "GENERATED", value: controller.generatedCount.formatted())
            MetricCard(label: "RECEIVED", value: controller.receivedCount.formatted())
            MetricCard(label: "DELIVERY", value: controller.deliveryText)
        }
    }

    private var actionCard: some View {
        LabCard(title: "Baseline control", icon: "waveform.path.ecg") {
            VStack(spacing: 12) {
                Button(action: controller.runBaselineBurst) {
                    Label(
                        controller.isRunning ? "Running…" : "Run baseline burst",
                        systemImage: "bolt.fill"
                    )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
                .foregroundStyle(.black)
                .disabled(controller.isRunning || controller.transport == .grpc)

                if let runID = controller.latestRunID {
                    Text("Run \(runID.uuidString.lowercased())")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Button("Reset", action: controller.reset)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var evidenceNote: some View {
        Label(
            "Host reconciliation decides delivery; the app never assumes receipt.",
            systemImage: "checkmark.shield"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.035, green: 0.055, blue: 0.08), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct LabCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.headline)
            content
        }
        .padding(18)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct MetricCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.monospacedDigit().weight(.bold))
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
        .environmentObject(ExperimentController())
}
