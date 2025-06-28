# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ziply is an iOS image compression app designed to reduce photo sizes while preserving album organization and metadata. The app integrates directly with iOS Photos library to provide a seamless compression experience.

## Development Status

**Current Phase**: Initial Development
- Xcode project created with name "Ziply"
- Bundle ID: `com.theopendiaries.Ziply`
- Default SwiftUI template with Core Data (to be removed)
- Project specifications completed in `description.md`
- Technical exploration documented in `brainstorm.md`

## Key Technical Decisions

### Architecture
- **Pattern**: MVVM with Combine for reactive data flow
- **UI Framework**: SwiftUI with UIKit integration for photo picker
- **Target**: iOS 15.0+, Swift 5.9+
- **Core Frameworks**: Photos, PhotosUI, Core Image, ImageIO, Core Graphics

### Compression Strategy
- **Max Dimension**: 1500px (maintaining aspect ratio)
- **Quality**: 75-80% JPEG compression
- **Metadata**: Preserved using ImageIO framework
- **Album Organization**: Creates "Compressed - [Album Name]" using PHAssetCollection

### Performance Requirements
- Process 1-2 photos per second
- Handle 100-photo batches efficiently
- Support background processing via Background Tasks framework

## Development Commands

Once the Xcode project is created, typical commands will include:

```bash
# Build project
xcodebuild -scheme ImageCompressor -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests
xcodebuild test -scheme ImageCompressor -destination 'platform=iOS Simulator,name=iPhone 16'

# If using Swift Package Manager
swift build
swift test

# If using CocoaPods (after setup)
pod install
pod update

# If using Fastlane (after setup)
fastlane scan  # Run tests
fastlane gym   # Build app
```

## Current Project Structure

```
Ziply/
├── Ziply/
│   ├── ZiplyApp.swift (main app entry - needs cleanup)
│   ├── ContentView.swift (to be replaced)
│   ├── Persistence.swift (to be removed)
│   ├── Assets.xcassets/
│   ├── Preview Content/
│   └── Ziply.xcdatamodeld (to be removed)
├── ZiplyTests/
└── ZiplyUITests/
```

## Target Project Structure

```
Ziply/
├── App/
│   ├── ZiplyApp.swift
│   └── Info.plist
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── PhotoSelection/
│   │   ├── PhotoSelectionView.swift
│   │   └── PreviewResultsView.swift
│   ├── Compression/
│   │   ├── CompressionProgressView.swift
│   │   └── CompressionResultsView.swift
│   └── Settings/
│       └── SettingsView.swift
├── ViewModels/
│   ├── PhotoSelectionViewModel.swift
│   └── CompressionViewModel.swift
├── Models/
│   ├── CompressionSettings.swift
│   └── PhotoAsset.swift
├── Services/
│   ├── PhotoLibraryService.swift
│   ├── CompressionService.swift
│   └── MetadataService.swift
├── Utilities/
│   └── ImageProcessor.swift
└── Resources/
    └── Assets.xcassets
```

## Critical Implementation Notes

### Photo Library Permissions
Always request photo library access with clear usage descriptions:
```swift
// Info.plist keys required:
// NSPhotoLibraryUsageDescription
// NSPhotoLibraryAddUsageDescription
```

### Album Preservation Logic
When implementing album organization:
1. Use `PHAssetCollection` to read existing albums
2. Create new collections with "Compressed - " prefix
3. Maintain album relationships when saving compressed photos

### Metadata Preservation
Use ImageIO framework to preserve EXIF data:
```swift
// Read metadata with CGImageSourceCopyPropertiesAtIndex
// Write metadata with CGImageDestinationAddImage
```

### Background Processing
Implement `BGProcessingTask` for large batch operations to prevent app suspension.

## Testing Approach

1. Dont worry about tests for now. 

## Security & Privacy
- Use PHPickerViewController for privacy-preserving photo selection
- Store only photo identifiers, not actual photo data
- Implement proper error handling for permission denials


## Things to remember
- Update @todo.md when you complete tasks that were listed there
- If you add new features or make significant changes to the original plan, update todo.md accordingly

## Git Commit Guidelines
- Create commits after each bug fix or major change
- Use descriptive commit messages with emojis
- Do NOT mention Claude or Anthropic in commit messages
- Example commit format: "🐛 Fix date filter selection state update"
