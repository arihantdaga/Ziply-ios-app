# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS image compression app designed to reduce photo sizes while preserving album organization and metadata. The app integrates directly with iOS Photos library to provide a seamless compression experience.

## Development Status

**Current Phase**: Planning/Documentation
- Project specifications completed in `description.md`
- Technical exploration documented in `brainstorm.md`
- No Xcode project or Swift code exists yet

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
xcodebuild -scheme ImageCompressor -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme ImageCompressor -destination 'platform=iOS Simulator,name=iPhone 15'

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

## Project Structure (Tentative and Flexible) (Future)
### If it changes, remember to update it here as well. 

```
ImageCompressor/
├── App/
│   ├── ImageCompressorApp.swift
│   └── Info.plist
├── Views/
│   ├── PhotoSelectionView.swift
│   ├── CompressionProgressView.swift
│   └── SettingsView.swift
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
