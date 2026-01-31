import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ObsidianService.self) private var obsidianService
    @Environment(ClaudeAPIService.self) private var claudeAPIService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        NavigationStack {
            Form {
                if let vm = viewModel {
                    obsidianSection(vm: vm)
                    claudeAPISection(vm: vm)
                }
            }
            .navigationTitle("Settings")
            .task {
                if viewModel == nil {
                    viewModel = SettingsViewModel(
                        obsidianService: obsidianService,
                        claudeAPIService: claudeAPIService
                    )
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

    // MARK: - Obsidian Section

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

    // MARK: - Claude API Section

    @ViewBuilder
    private func claudeAPISection(vm: SettingsViewModel) -> some View {
        Section {
            if vm.isAPIKeyConfigured {
                apiKeyConfiguredView(vm: vm)
            } else {
                apiKeyInputView(vm: vm)
            }
        } header: {
            Text("Claude API")
        } footer: {
            Text("Use Claude AI to parse your Daily Notes into categories. Your API key is stored securely in the Keychain.")
        }
    }

    @ViewBuilder
    private func apiKeyInputView(vm: SettingsViewModel) -> some View {
        SecureField("API Key", text: Binding(
            get: { vm.apiKeyInput },
            set: { vm.apiKeyInput = $0 }
        ))
        .textContentType(.password)
        .autocorrectionDisabled()

        Button("Save API Key") {
            vm.saveAPIKey()
        }
        .disabled(vm.apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @ViewBuilder
    private func apiKeyConfiguredView(vm: SettingsViewModel) -> some View {
        LabeledContent("Status") {
            Text("API Key Configured")
                .foregroundStyle(.green)
        }

        if let status = vm.apiKeyValidationStatus {
            LabeledContent("Validation") {
                Text(status)
                    .foregroundStyle(.secondary)
            }
        }

        Button {
            Task { await vm.validateAPIKey() }
        } label: {
            if vm.isValidatingKey {
                HStack {
                    Text("Validating...")
                    ProgressView()
                }
            } else {
                Text("Validate Key")
            }
        }
        .disabled(vm.isValidatingKey)

        Button {
            Task { await vm.parseTodaysNote(modelContext: modelContext) }
        } label: {
            if vm.isParsing {
                HStack {
                    Text("Parsing...")
                    ProgressView()
                }
            } else {
                Text("Parse Today's Note")
            }
        }
        .disabled(vm.isParsing || vm.lastReadNote == nil)

        if let message = vm.parseResultMessage {
            LabeledContent("Result") {
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }

        Button("Remove API Key", role: .destructive) {
            vm.deleteAPIKey()
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailySummary.self, DailyNote.self, ParsedEntry.self], inMemory: true)
        .environment(ObsidianService())
        .environment(ClaudeAPIService())
}
