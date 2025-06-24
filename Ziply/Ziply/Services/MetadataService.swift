import Foundation
import ImageIO
import CoreLocation
import Photos

class MetadataService {
    static let shared = MetadataService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Extract all metadata from image data
    func extractMetadata(from imageData: Data) -> ImageMetadata? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return nil
        }
        
        return ImageMetadata(from: properties)
    }
    
    /// Extract metadata from a PHAsset
    func extractMetadata(from asset: PHAsset) -> AssetMetadata {
        return AssetMetadata(
            creationDate: asset.creationDate,
            modificationDate: asset.modificationDate,
            location: asset.location,
            isFavorite: asset.isFavorite,
            mediaType: asset.mediaType,
            mediaSubtypes: asset.mediaSubtypes,
            pixelWidth: asset.pixelWidth,
            pixelHeight: asset.pixelHeight,
            duration: asset.duration
        )
    }
    
    /// Prepare metadata dictionary for embedding in compressed image
    func prepareMetadataForEmbedding(_ metadata: ImageMetadata) -> CFDictionary {
        var metadataDict: [String: Any] = [:]
        
        // EXIF data
        if let exif = metadata.exifData {
            metadataDict[kCGImagePropertyExifDictionary as String] = exif
        }
        
        // GPS data
        if let gps = metadata.gpsData {
            metadataDict[kCGImagePropertyGPSDictionary as String] = gps
        }
        
        // TIFF data
        if let tiff = metadata.tiffData {
            metadataDict[kCGImagePropertyTIFFDictionary as String] = tiff
        }
        
        // IPTC data
        if let iptc = metadata.iptcData {
            metadataDict[kCGImagePropertyIPTCDictionary as String] = iptc
        }
        
        // Orientation
        if let orientation = metadata.orientation {
            metadataDict[kCGImagePropertyOrientation as String] = orientation
        }
        
        // Color model
        if let colorModel = metadata.colorModel {
            metadataDict[kCGImagePropertyColorModel as String] = colorModel
        }
        
        // DPI
        if let dpiWidth = metadata.dpiWidth {
            metadataDict[kCGImagePropertyDPIWidth as String] = dpiWidth
        }
        if let dpiHeight = metadata.dpiHeight {
            metadataDict[kCGImagePropertyDPIHeight as String] = dpiHeight
        }
        
        return metadataDict as CFDictionary
    }
    
    /// Create GPS metadata dictionary from CLLocation
    func createGPSMetadata(from location: CLLocation) -> [String: Any] {
        var gpsData: [String: Any] = [:]
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Latitude
        gpsData[kCGImagePropertyGPSLatitude as String] = abs(latitude)
        gpsData[kCGImagePropertyGPSLatitudeRef as String] = latitude >= 0 ? "N" : "S"
        
        // Longitude
        gpsData[kCGImagePropertyGPSLongitude as String] = abs(longitude)
        gpsData[kCGImagePropertyGPSLongitudeRef as String] = longitude >= 0 ? "E" : "W"
        
        // Altitude
        if location.verticalAccuracy >= 0 {
            gpsData[kCGImagePropertyGPSAltitude as String] = abs(location.altitude)
            gpsData[kCGImagePropertyGPSAltitudeRef as String] = location.altitude >= 0 ? 0 : 1
        }
        
        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd"
        gpsData[kCGImagePropertyGPSDateStamp as String] = formatter.string(from: location.timestamp)
        
        formatter.dateFormat = "HH:mm:ss"
        gpsData[kCGImagePropertyGPSTimeStamp as String] = formatter.string(from: location.timestamp)
        
        // Speed
        if location.speed >= 0 {
            gpsData[kCGImagePropertyGPSSpeed as String] = location.speed * 3.6 // Convert m/s to km/h
            gpsData[kCGImagePropertyGPSSpeedRef as String] = "K" // Kilometers per hour
        }
        
        // Course
        if location.course >= 0 {
            gpsData[kCGImagePropertyGPSTrack as String] = location.course
            gpsData[kCGImagePropertyGPSTrackRef as String] = "T" // True direction
        }
        
        return gpsData
    }
    
    /// Sanitize metadata by removing sensitive information if needed
    func sanitizeMetadata(_ metadata: ImageMetadata, removeSensitive: Bool = false) -> ImageMetadata {
        guard removeSensitive else { return metadata }
        
        var sanitized = metadata
        
        // Remove GPS data if sensitive
        sanitized.gpsData = nil
        
        // Remove specific EXIF fields that might contain sensitive info
        if var exif = sanitized.exifData {
            // Remove fields like UserComment, MakerNote, etc.
            exif.removeValue(forKey: kCGImagePropertyExifUserComment as String)
            exif.removeValue(forKey: kCGImagePropertyExifMakerNote as String)
            sanitized.exifData = exif
        }
        
        return sanitized
    }
}

// MARK: - Supporting Types

struct ImageMetadata {
    var exifData: [String: Any]?
    var gpsData: [String: Any]?
    var tiffData: [String: Any]?
    var iptcData: [String: Any]?
    var orientation: Int?
    var colorModel: String?
    var dpiWidth: Double?
    var dpiHeight: Double?
    var profileName: String?
    
    init(from properties: [String: Any]) {
        self.exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        self.gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        self.tiffData = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
        self.iptcData = properties[kCGImagePropertyIPTCDictionary as String] as? [String: Any]
        self.orientation = properties[kCGImagePropertyOrientation as String] as? Int
        self.colorModel = properties[kCGImagePropertyColorModel as String] as? String
        self.dpiWidth = properties[kCGImagePropertyDPIWidth as String] as? Double
        self.dpiHeight = properties[kCGImagePropertyDPIHeight as String] as? Double
        self.profileName = properties[kCGImagePropertyProfileName as String] as? String
    }
    
    init() {}
    
    /// Get human-readable camera info
    var cameraInfo: String? {
        guard let exif = exifData else { return nil }
        
        var info: [String] = []
        
        // Camera make and model
        if let make = tiffData?[kCGImagePropertyTIFFMake as String] as? String {
            info.append(make)
        }
        if let model = tiffData?[kCGImagePropertyTIFFModel as String] as? String {
            info.append(model)
        }
        
        // Lens info
        if let lensModel = exif[kCGImagePropertyExifLensModel as String] as? String {
            info.append("Lens: \(lensModel)")
        }
        
        return info.isEmpty ? nil : info.joined(separator: ", ")
    }
    
    /// Get human-readable shooting settings
    var shootingSettings: String? {
        guard let exif = exifData else { return nil }
        
        var settings: [String] = []
        
        // Focal length
        if let focalLength = exif[kCGImagePropertyExifFocalLength as String] as? Double {
            settings.append("\(Int(focalLength))mm")
        }
        
        // F-number (aperture)
        if let fNumber = exif[kCGImagePropertyExifFNumber as String] as? Double {
            settings.append("f/\(fNumber)")
        }
        
        // Exposure time
        if let exposureTime = exif[kCGImagePropertyExifExposureTime as String] as? Double {
            if exposureTime < 1 {
                settings.append("1/\(Int(1/exposureTime))s")
            } else {
                settings.append("\(exposureTime)s")
            }
        }
        
        // ISO
        if let isoArray = exif[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
           let iso = isoArray.first {
            settings.append("ISO \(iso)")
        }
        
        return settings.isEmpty ? nil : settings.joined(separator: " • ")
    }
}

struct AssetMetadata {
    let creationDate: Date?
    let modificationDate: Date?
    let location: CLLocation?
    let isFavorite: Bool
    let mediaType: PHAssetMediaType
    let mediaSubtypes: PHAssetMediaSubtype
    let pixelWidth: Int
    let pixelHeight: Int
    let duration: TimeInterval
    
    var hasLocation: Bool {
        location != nil
    }
    
    var dimensions: String {
        "\(pixelWidth) × \(pixelHeight)"
    }
}