//
//  Constants.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import Foundation
import CoreGraphics

enum Constants {
    
    // MARK: - Compression Settings
    
    enum Compression {
        /// Maximum dimension (width or height) for compressed images in pixels
        /// The image will be resized proportionally if either dimension exceeds this value
        /// Default: 1500 pixels
        static let maxDimension: CGFloat = 1500
        
        /// JPEG compression quality (0.0 to 1.0)
        /// Higher values mean better quality but larger file sizes
        /// Default: 0.75 (75% quality)
        static let compressionQuality: CGFloat = 0.75
    }
    
    // MARK: - Album Names
    
    enum Albums {
        /// Name of the album where original photos that can be deleted are stored
        static let canDeleteAlbumName = "Can Delete - Ziply"
    }
    
    // MARK: - Photo Selection
    
    enum PhotoSelection {
        /// Default minimum photo size for filtering (in MB)
        static let defaultMinimumPhotoSizeMB: Float = 2.5
        
        /// Minimum size slider range (in MB)
        static let minimumSizeRangeMB: ClosedRange<Float> = 0.1...5.0
    }
    
    // MARK: - Performance
    
    enum Performance {
        /// Delay between processing photos to show progress (in nanoseconds)
        static let progressUpdateDelay: UInt64 = 10_000_000 // 10ms
    }
}