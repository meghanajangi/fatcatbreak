import FamilyControls
import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var isPickerPresented = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.97, green: 0.86, blue: 0.48), Color(red: 0.24, green: 0.74, blue: 0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    settings
                    monitoredApps
                    controls
                    status
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let breakUntil = model.breakUntil {
                CatBreakView(until: breakUntil) {
                    model.refreshBreakState()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .task {
            await model.requestAuthorization()
            model.refreshBreakState()
        }
        .onChange(of: isPickerPresented) { _, isPresented in
            if !isPresented {
                model.saveSelection()
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: model.breakUntil)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fat Cat Break")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(.black)

            Text("Spend too long scrolling? The cat takes over.")
                .font(.headline)
                .foregroundStyle(.black.opacity(0.72))
        }
        .padding(.top, 24)
    }

    private var monitoredApps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target apps")
                .font(.title2.bold())

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 10)], spacing: 10) {
                ForEach(CatConstants.suggestedApps, id: \.self) { app in
                    Label(app, systemImage: "app.badge.checkmark")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 8))
                }
            }

            Text("iOS keeps app identity private, so choose these apps in the Screen Time picker instead of hard-coding bundle IDs.")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.65))
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gatekeeper settings")
                .font(.title2.bold())

            Stepper("Usage limit: \(model.usageLimitMinutes) min", value: $model.usageLimitMinutes, in: 1...180)
            Stepper("Break time: \(model.breakMinutes) min", value: $model.breakMinutes, in: 1...30)
        }
        .font(.headline)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
        .onChange(of: model.usageLimitMinutes) { _, _ in model.saveSettings() }
        .onChange(of: model.breakMinutes) { _, _ in model.saveSettings() }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Button {
                isPickerPresented = true
            } label: {
                Label("Choose apps", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 10) {
                Button {
                    model.startMonitoring()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    model.stopMonitoring()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button {
                model.previewBreak()
            } label: {
                Label("Preview cat break", systemImage: "cat.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
    }

    private var status: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.statusMessage)
                .font(.callout.weight(.medium))
            Text("\(model.selectedCount) Screen Time item\(model.selectedCount == 1 ? "" : "s") selected")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.65))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
    }
}
