//
//  DefaultContrastPairCache.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/9/25.
//

import SwiftUI

/// A thread-safe cache implementation using NSCache for automatic memory management.
///
/// This implementation:
/// - Provides thread-safe access for concurrent usage
/// - Uses NSCache for automatic cache eviction under memory pressure
/// - Stores choices as single bits for memory efficiency
/// - Maintains a configurable size limit
/// - Guarantees unique keys for colors by using a high-precision string representation
///   of the color components (6 decimal places for red, green, blue, and alpha)
///
/// While custom instances can be created, shared thread-safe instances are available
/// through `ContrastPairCaches` for common use cases.
public final class DefaultContrastPairCache<T: PerceptualColor>: @unchecked Sendable, ContrastPairCache {
    public typealias PerceptualColor = T
    
    public let darkColor: T
    public let lightColor: T
    private let cache = NSCache<NSString, NSNumber>()
    
    private func hashColor(_ color: T) -> String {
        guard let components = ColorPerceptionUtils.extractSRGBComponents(from: color.cgColor) else {
            return "0,0,0,0"
        }
        return String(format: "%.6f,%.6f,%.6f,%.6f",
                      components.red, components.green, components.blue, components.alpha)
    }
    
    public init(darkColor: T, lightColor: T, cacheSize: Int = 100) {
        self.darkColor = darkColor
        self.lightColor = lightColor
        cache.countLimit = max(1, cacheSize)
    }
    
    public func getCachedChoice(for color: T) -> ContrastChoice? {
        let key = hashColor(color) as NSString
        guard let value = cache.object(forKey: key) else {
            return nil
        }
        return value.boolValue ? .dark : .light
    }
    
    public func cache(choice: ContrastChoice, for color: T) {
        let key = hashColor(color) as NSString
        cache.setObject(NSNumber(value: choice == .dark), forKey: key)
    }
    
    public func clearCache() {
        cache.removeAllObjects()
    }
}

/// Thread-safe shared cache instances for common color types.
///
/// These caches are safe to use from any thread, making them suitable for
/// concurrent UI updates and background processing.
public enum ContrastPairCaches {
    /// Shared cache for UIColor contrasts
    public static let uiColorCache = DefaultContrastPairCache<UIColor>(
        darkColor: .black,
        lightColor: .white
    )
    
    /// Shared cache for Color contrasts
    public static let colorCache = DefaultContrastPairCache<Color>(
        darkColor: .black,
        lightColor: .white
    )
} 
