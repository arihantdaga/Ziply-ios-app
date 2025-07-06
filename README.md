# Ziply 🗜️✨

> A sleek iOS app that compresses your photos while preserving memories and organization

<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-3.0-green.svg" />
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow.svg" />
</p>

## 🎯 Mission

Ever run out of iCloud storage? Ziply is here to help! It intelligently compresses your photos while maintaining their quality and organization, giving you back precious storage space without losing your memories.

## ✨ Features

- **Smart Photo Selection**: Find photos by date range and size
- **Batch Compression**: Process hundreds of photos efficiently
- **Album Preservation**: Keeps your photo organization intact
- **Metadata Retention**: Preserves location, date, and camera info
- **Quality Control**: ~75% size reduction with minimal quality loss
- **Beautiful UI**: Clean, intuitive SwiftUI interface

## 📱 Screenshots

<details>
<summary>View App Flow</summary>

1. **Onboarding** - Simple permission setup
2. **Photo Selection** - Smart filters to find large photos
3. **Preview** - See potential space savings
4. **Compression** - Real-time progress tracking
5. **Results** - Celebrate your freed space!

</details>

## 🏗️ Architecture

```
Ziply/
├── 📱 App/              # App entry & configuration
├── 🎨 Views/            # SwiftUI views
├── 🧠 ViewModels/       # Business logic
├── 📊 Models/           # Data models
├── ⚙️ Services/         # Core functionality
└── 🛠️ Utilities/        # Helper functions
```

### Tech Stack
- **UI**: SwiftUI + UIKit (for photo picker)
- **Architecture**: MVVM with Combine
- **Photo Management**: PhotoKit framework
- **Image Processing**: Core Image + ImageIO
- **Concurrency**: Swift async/await

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+ device/simulator
- macOS Ventura or later

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/image_compressor_ios.git
cd image_compressor_ios
```

2. Open in Xcode
```bash
open Ziply.xcodeproj
```

3. Select your development team in project settings

4. Build and run (⌘+R)

## 🔧 Development

### Configuration

#### Compression Settings

You can customize the compression settings by modifying the constants in `Ziply/Utilities/Constants.swift`:

```swift
enum Compression {
    /// Maximum dimension (width or height) for compressed images
    /// Default: 1500 pixels
    static let maxDimension: CGFloat = 1500
    
    /// JPEG compression quality (0.0 to 1.0)
    /// Default: 0.75 (75% quality)
    static let compressionQuality: CGFloat = 0.75
}
```

**Tips for adjusting settings:**
- **Lower `maxDimension`** (e.g., 1200 or 1000) for more aggressive size reduction
- **Higher `compressionQuality`** (e.g., 0.8-0.9) for better quality but larger files
- **Lower `compressionQuality`** (e.g., 0.6-0.7) for smaller files but more compression artifacts

### Key Components

**PhotoLibraryService** - Handles all photo library interactions
- Permission management
- Photo fetching with smart filters
- Album organization

**CompressionService** - The compression engine
- Intelligent resizing (configurable max dimension)
- JPEG optimization (configurable quality)
- Metadata preservation

**Storage Calculator** - Space analytics
- Real-time size calculations
- Compression estimates
- User-friendly formatting

### Performance Goals
- 📸 Process 1-2 photos/second
- 💾 75% average size reduction
- 🎯 90%+ visual quality retention
- 📦 Handle 100+ photo batches

## 🎨 Design Philosophy

Ziply follows iOS design guidelines with a focus on:
- **Clarity**: Clear visual hierarchy and purposeful animations
- **Deference**: Content-first approach with minimal chrome
- **Depth**: Subtle layers and transitions for context

## 🤝 Contributing

This is a hobby project, but contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📝 Development Status

Currently in active development. Check [todo.md](todo.md) for the implementation roadmap.

### Recent Updates
- ✅ Core UI implementation complete
- ✅ Photo selection with smart filters
- ✅ Custom date range picker
- ✅ Space savings estimation
- 🚧 Compression engine in progress

## 🔮 Future Ideas

- **Cloud Integration**: Direct compression for iCloud photos
- **Smart Suggestions**: AI-powered photo selection
- **Batch Presets**: One-tap compression profiles
- **Widget Support**: Storage status at a glance

## 📄 License

This project is a personal hobby project. Feel free to use the code for learning purposes.

## 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Inspired by the need for better storage management
- Special thanks to the iOS development community

---

<p align="center">
Made with ❤️ for the iOS community
</p>