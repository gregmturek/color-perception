//
//  UIColorExtension.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import UIKit

extension UIColor: ColorConvertible {
    public typealias ColorRepresentation = UIColor
    
    public static func from(cgColor: CGColor) -> ColorRepresentation? {
        UIColor(cgColor: cgColor)
    }
}

extension UIColor: PerceptualColor {
    /// Returns the best contrasting color from a set of provided colors.
    ///
    /// - Parameters:
    ///   - colors: Colors to choose from, or none to use cache defaults
    ///   - cache: Cache to use for contrast decisions (defaults to shared UIColor cache)
    /// - Returns: The color with the highest absolute contrast to this color
    /// - Note: Uses ``ColorPerceptionUtils/findOptimalContrastingColor(baseColor:from:using:perceivedLightness:)`` internally
    public func perceptualContrastingColor<Cache: ContrastPairCache>(
        from colors: ColorRepresentation...,
        using cache: Cache = ContrastPairCaches.uiColorCache
    ) -> ColorRepresentation where Cache.PerceptualColor == ColorRepresentation {
        ColorPerceptionUtils.findOptimalContrastingColor(
            baseColor: self,
            from: colors,
            using: cache,
            perceivedLightness: perceivedLightness
        )
    }
    
    /// Sets the color's perceived lightness to the specified value.
    ///
    /// - Parameter lightness: Target value between 0 (black) and 100 (white)
    /// - Returns: New color with specified lightness (within ±0.1 of target)
    /// - Note: Uses ``ColorPerceptionUtils/withPerceivedLightness(_:lightness:)`` internally
    public func withPerceivedLightness(_ lightness: CGFloat) -> ColorRepresentation {
        ColorPerceptionUtils.withPerceivedLightness(self, lightness: lightness)
    }
    
    /// Adjusts the color's perceived lightness by the specified amount.
    ///
    /// - Parameter amount: The amount to adjust (-100 to +100)
    /// - Returns: New color with adjusted lightness (within ±0.1 of target)
    /// - Note: Uses ``ColorPerceptionUtils/adjustPerceivedLightness(of:by:)`` internally
    public func adjustingPerceivedLightness(by amount: CGFloat) -> ColorRepresentation {
        ColorPerceptionUtils.adjustPerceivedLightness(of: self, by: amount)
    }
}
