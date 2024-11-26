//
//  CodableImage.swift
//
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

struct CodableImage: Codable, Hashable {
    let image: PlatformImage
    
    static let errorDomain = "CodableImageErrorDomain"
    // Encoding the image to Base64
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let data = image.pngData() else {
            throw NSError(
                domain: Self.errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode UIImage to Base64 string"]
            )
        }
        try container.encode(data.base64EncodedString())
    }
    
    // Decoding the Base64 string back to UIImage
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base64String = try container.decode(String.self)
        guard let data = Data(base64Encoded: base64String),
              let image = UIImage(data: data) else {
            throw NSError(
                domain: Self.errorDomain,
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode Base64 string to UIImage"]
            )
        }
        self.image = image
    }
    
#if canImport(UIKit)
    init(image: UIImage) {
        self.image = image
    }
#elseif canImport(AppKit)
    init(image: NSImage) {
        self.image = image
    }
#endif
}
