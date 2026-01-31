# Project: VibeCheck

## Quick Reference
- **Platform**: iOS 17+
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with @Observable
- **Data Persistence**: SwiftData with iCloud Sync
- **Minimum Deployment**: iOS 17.0
- **Package Manager**: Swift Package Manager

## Project Structure
```
VibeCheck/
├── App/                # App entry point
├── Features/           # Feature modules
│   ├── Dashboard/      # Main dashboard
│   ├── Timeline/       # History view
│   └── Settings/       # Settings
├── Core/               # Shared utilities
│   ├── Data/           # SwiftData models
│   ├── Services/       # HealthKit, Claude API, Obsidian
│   ├── Extensions/     # Swift extensions
│   └── Components/     # Reusable UI
├── Resources/          # Assets
└── Tests/
```

## Coding Standards

### Swift Style
- Use Swift 6 strict concurrency
- Prefer `@Observable` over `ObservableObject`
- Use `async/await` for all async operations
- Use `guard` for early exits
- Prefer structs over classes for models

### SwiftUI Patterns
- Extract subviews when exceeding 150 lines
- Use `@State` for view-local state only
- Use `@Environment` for dependency injection
- Use `NavigationStack` with type-safe routing

### Error Handling
```swift
enum VibeCheckError: LocalizedError {
    case healthKitError(underlying: Error)
    case obsidianError(message: String)
    case claudeAPIError(message: String)
    case swiftDataError(underlying: Error)
}
```

## Core Services

### HealthKitService
- Fetch: weight, steps, sleep, heart rate
- Use HKStatisticsQuery for aggregated data
- Never send HealthKit data to external APIs

### ObsidianService
- Use UIDocumentPicker for folder selection
- Store access with Security-Scoped Bookmark
- Parse Daily Notes from vault

### ClaudeAPIService
- Model: claude-3-haiku
- Use for text parsing and categorization
- Store API key in Keychain

## Testing Requirements
- Unit tests for all ViewModels and Services
- Use Swift Testing framework (@Test, #expect)
- Aim for 80% coverage on business logic

## DO NOT
- Use deprecated APIs (NavigationView, ObservableObject)
- Create massive monolithic views
- Use force unwrapping without justification
- Ignore Swift 6 concurrency warnings
- Hardcode API keys
- Send HealthKit data to external APIs

## Development Workflow

### Starting a feature
1. Read docs/PRD.md and docs/ROADMAP.md
2. Use Plan Mode to create implementation strategy
3. Write failing tests first (TDD)
4. Implement code to pass tests
5. Commit with /commit-push-pr

### Week 1 Tasks
- [ ] HealthKit integration (weight, steps, sleep)
- [ ] Basic dashboard UI with cards
- [ ] SwiftData models for DailySummary

### Week 2 Tasks
- [ ] Obsidian vault connection
- [ ] Claude API integration for parsing
- [ ] Timeline view
- [ ] TestFlight release
