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
│   ├── Dashboard/      # Main dashboard view
│   ├── Timeline/       # History timeline
│   └── Settings/       # App settings
├── Core/               # Shared utilities
│   ├── Data/           # SwiftData models
│   ├── Services/       # HealthKit, Claude API, Obsidian
│   ├── Extensions/     # Swift extensions
│   └── Components/     # Reusable SwiftUI components
├── Resources/          # Assets, Localizations
└── Tests/
    ├── VibeCheckTests/
    └── VibeCheckUITests/
```

## Coding Standards

### Swift Style
- Use Swift 6 strict concurrency
- Prefer `@Observable` over `ObservableObject`
- Use `async/await` for all async operations
- Use `guard` for early exits
- Prefer structs over classes for models

### SwiftUI Patterns
- Extract subviews when a view exceeds 150 lines
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

## Testing Requirements
- All ViewModels and Services must have unit tests
- Use Swift Testing framework (`@Test`, `#expect`)
- Aim for 80% code coverage for business logic

## DO NOT
- Use deprecated APIs (`NavigationView`, `ObservableObject`)
- Create massive, monolithic SwiftUI views
- Use force unwrapping without justification
- Ignore Swift 6 concurrency warnings
- Hardcode API keys

## Key Services to Implement

### 1. HealthKitService
- Request authorization for: steps, sleep, weight, heart rate
- Fetch daily summaries
- Do NOT send HealthKit data to external APIs

### 2. ObsidianService
- Use UIDocumentPicker for folder selection
- Store access with Security-Scoped Bookmark
- Parse Daily Notes from vault

### 3. ClaudeAPIService
- Use Claude Haiku 4.5 for text parsing
- Store API key in Keychain
- Parse Daily Notes into categories: workout, reading, insight, work, food, health

## Development Workflow

### Starting a new feature:
1. Read docs/PRD.md and docs/ROADMAP.md
2. Use Plan Mode to create implementation strategy
3. Write failing tests first (TDD)
4. Implement the code
5. Run tests and fix issues
6. Commit with descriptive message

### Commands
- Build: `xcodebuild -scheme VibeCheck -destination 'platform=iOS Simulator,name=iPhone 15 Pro'`
- Test: `xcodebuild test -scheme VibeCheck -destination 'platform=iOS Simulator,name=iPhone 15 Pro'`

## Current Sprint: Week 1

### Goals
- [ ] HealthKit integration (steps, sleep, weight)
- [ ] Basic dashboard UI with cards
- [ ] SwiftData models for DailySummary

### Priority
1. HealthKitService implementation
2. DailySummary SwiftData model
3. DashboardView with health cards
