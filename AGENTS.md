# AGENTS.md

## Project Overview

SSC_Lab (Lab) is a native iOS app built with Swift 6, SwiftUI, and SwiftData for the Apple Swift Student Challenge. It is a single-target Xcode project with no backend services, no external dependencies, and no test targets. All data is stored on-device.

## Cursor Cloud specific instructions

### Platform constraint

This is an iOS-only project (`import AppleProductTypes` in `Package.swift`, targets iOS 18+). It **cannot** be built or run on Linux — `swift build` will fail with `no such module 'AppleProductTypes'`. Full builds and UI testing require **macOS with Xcode 16+** and the iOS Simulator.

### What works on the Linux Cloud VM

| Tool | Command | Notes |
|---|---|---|
| **Swift syntax validation** | `swiftc -parse <file.swift>` | Validates syntax of individual `.swift` files without resolving imports. All 52 source files pass. Run on all files: `find SSC_Lab -name "*.swift" -exec swiftc -parse {} \;` |
| **SwiftLint** | `swiftlint lint` | Runs lint rules on all Swift files in the workspace. Currently reports 259 warnings/40 errors (pre-existing, style-only). |

### What does NOT work on the Linux Cloud VM

- `swift build` / `swift package resolve` — fails due to `AppleProductTypes` (Xcode-only SPM plugin)
- `swift test` — no test targets exist in the project, and SPM can't resolve the manifest anyway
- Running the app — requires iOS Simulator (macOS only)

### Project structure

```
SSC_Lab/
├── Models/          # SwiftData models: Experiment, Win, WinCollection, AppSchema
├── ViewModels/      # MVVM view models
├── Views/           # SwiftUI views (Home, Lab, Wins, Settings, Onboarding, QuickLog)
├── Components/      # Reusable UI components
├── Extensions/      # Color+Theme, Font+Theme, UIImage+Resize, View helpers
├── Essentials/      # Constants, spacing, font registration
└── SSC_LabApp.swift # @main entry point
Resources/           # Custom fonts (.otf, .ttf)
Package.swift        # SPM manifest (Xcode-only iOS app product)
SSC_Lab.xcodeproj/   # Xcode project
```
