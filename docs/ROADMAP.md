# VibeCheck Development Roadmap

## Overview

**Goal:** 2週間でMVP、4週間でApp Storeリリース

---

## Week 1: Foundation

### Day 1: Project Setup
- [x] Xcode project creation
- [x] GitHub repository
- [x] CLAUDE.md configuration

### Day 2-3: HealthKit Integration
- [ ] HealthKitService implementation
- [ ] Request permissions
- [ ] Fetch: weight, steps, sleep, heart rate
- [ ] SwiftData model: DailySummary

### Day 4-5: Dashboard UI
- [ ] DashboardView
- [ ] WeightCard, StepsCard, SleepCard
- [ ] Swift Charts mini graphs
- [ ] Dark mode support

### Day 6-7: Integration & Testing
- [ ] Device testing
- [ ] Unit tests
- [ ] Bug fixes

---

## Week 2: Core Features

### Day 1-2: Obsidian Integration
- [ ] ObsidianService
- [ ] UIDocumentPicker
- [ ] Security-Scoped Bookmark
- [ ] File reading & change detection

### Day 3-4: Claude API
- [ ] ClaudeAPIService
- [ ] Prompt design
- [ ] Text parsing & categorization
- [ ] SwiftData storage

### Day 5-6: Timeline UI
- [ ] TimelineView
- [ ] Weekly grouping
- [ ] Filter by category
- [ ] Detail view

### Day 7: TestFlight
- [ ] Final testing
- [ ] App Store Connect setup
- [ ] TestFlight build
- [ ] Beta tester invites

---

## Week 3: Beta Testing

- [ ] Feedback collection
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] UI refinements

---

## Week 4: Release

- [ ] App Store submission materials
- [ ] Screenshots
- [ ] Privacy policy
- [ ] App Store review

---

## Priority Matrix

### Must Have (MVP)
- HealthKit (weight, steps, sleep)
- Obsidian connection
- Claude API parsing
- Dashboard UI
- Timeline UI

### Should Have (v1.1)
- Widgets
- AI summaries
- Paid plans

### Nice to Have (v2.0)
- Apple Watch
- Android
- Notion support