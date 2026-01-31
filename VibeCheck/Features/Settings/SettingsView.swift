import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ObsidianService.self) private var obsidianService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        NavigationStack {
            Form {
                if let vm = viewModel {
                    obsidianSection(vm: vm)
                }
            }
            .navigationTitle("Settings")
            .task {
                if viewModel == nil {
                    viewModel = SettingsViewModel(obsidianService: obsidianService)
                }
            }
            .alert("Error", isPresented: showingError) {
                Button("OK") { viewModel?.errorMessage = nil }
            } message: {
                Text(viewModel?.errorMessage ?? "")
            }
        }
    }

    private var showingError: Binding<Bool> {
        Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )
    }

    @ViewBuilder
    private func obsidianSection(vm: SettingsViewModel) -> some View {
        Section {
            if vm.isVaultConnected {
                connectedView(vm: vm)
            } else {
                disconnectedView(vm: vm)
            }
        } header: {
            Text("Obsidian Vault")
        } footer: {
            Text("Connect your Obsidian vault to import Daily Notes.")
        }
    }

    @ViewBuilder
    private func connectedView(vm: SettingsViewModel) -> some View {
        LabeledContent("Vault") {
            Text(vm.vaultName ?? "Unknown")
        }

        LabeledContent("Daily Notes Folder") {
            Text(vm.dailyNotesFolder)
        }

        Button("Read Today's Note") {
            vm.readTodaysNote(modelContext: modelContext)
        }

        if let note = vm.lastReadNote {
            Section("Preview") {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(10)
            }
        }

        Button("Disconnect Vault", role: .destructive) {
            vm.disconnectVault()
        }
    }

    @ViewBuilder
    private func disconnectedView(vm: SettingsViewModel) -> some View {
        Button("Select Vault Folder") {
            vm.isShowingPicker = true
        }
        .sheet(isPresented: Binding(
            get: { vm.isShowingPicker },
            set: { vm.isShowingPicker = $0 }
        )) {
            VaultPickerRepresentable { url in
                vm.connectVault(url: url)
                vm.isShowingPicker = false
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailySummary.self, DailyNote.self], inMemory: true)
        .environment(ObsidianService())
}
