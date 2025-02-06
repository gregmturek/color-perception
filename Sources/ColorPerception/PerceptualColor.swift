//
//  PerceptualColor.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import SwiftUI

/// A type that can be converted to and from CGColor.
///
/// This protocol enables color types to participate in perceptual calculations
/// by providing conversion to a common color format (CGColor).
///
/// Example usage:
///
///     let color: ColorConvertible = ...
///     let cgColor = color.cgColor
///     if let converted = Color.from(cgColor: cgColor) {
///         // Use converted color
///     }
public protocol ColorConvertible {
    associatedtype ColorRepresentation: ColorConvertible

    var cgColor: CGColor { get }
    
    static func from(cgColor: CGColor) -> ColorRepresentation?
}

/// A color type that supports perceptual analysis and manipulation.
///
/// This protocol defines the interface for colors that can be analyzed and
/// manipulated based on human visual perception. It extends `ColorConvertible`
/// to add core perceptual measurements.
///
/// Required capabilities:
/// - Measure relative luminance (physical light)
/// - Calculate perceived lightness (human perception)
///
/// Example usage:
///
///     let color: PerceptualColor = ...
///     
///     // Core measurements
///     let luminance = color.relativeLuminance  // Physical light
///     let lightness = color.perceivedLightness // Human perception
public protocol PerceptualColor: ColorConvertible {
    /// The relative luminance in the linear sRGB color space.
    var relativeLuminance: CGFloat { get }
    
    /// The perceived lightness on the L\* scale.
    var perceivedLightness: CGFloat { get }
}

public extension PerceptualColor {
    /// The relative luminance of the color in the sRGB color space, ranging from 0.0 to 1.0.
    ///
    /// - Attention: For human visual perception, prefer using `perceivedLightness` instead, as luminance represents
    /// the physical amount of light rather than how it's perceived by humans.
    /// - Note: Uses ``ColorPerceptionUtils/calculateRelativeLuminance(from:)`` internally
    var relativeLuminance: CGFloat {
        ColorPerceptionUtils.calculateRelativeLuminance(from: cgColor)
    }
    
    /// The perceived lightness of the color, ranging from 0 (black) to 100 (white), with 50 representing perceptual "middle gray."
    ///
    /// - Attention: For the physical amount of light emitted or sensed, use `relativeLuminance` instead. This property is
    /// specifically designed to match human visual perception rather than physical light measurements.
    /// - Note: Uses ``ColorPerceptionUtils/calculatePerceivedLightness(from:)`` internally
    var perceivedLightness: CGFloat {
        ColorPerceptionUtils.calculatePerceivedLightness(from: relativeLuminance)
    }
    
    /// Returns whether the color is perceived as light by the human eye.
    ///
    /// A color is considered perceptually light if its perceived lightness is greater than 50.
    ///
    /// - Warning: A color with exactly 50 perceived lightness (middle gray) will return `false`.
    /// - Note: Uses ``ColorPerceptionUtils/checkIfPerceptuallyLight(perceivedLightness:)`` internally
    var isPerceptuallyLight: Bool {
        ColorPerceptionUtils.checkIfPerceptuallyLight(perceivedLightness: perceivedLightness)
    }
    
    /// Returns whether the color is perceived as dark by the human eye.
    ///
    /// A color is considered perceptually dark if its perceived lightness is less than 50.
    ///
    /// - Warning: A color with exactly 50 perceived lightness ( middle gray) will return `false`.
    /// - Note: Uses ``ColorPerceptionUtils/checkIfPerceptuallyDark(perceivedLightness:)`` internally
    var isPerceptuallyDark: Bool {
        ColorPerceptionUtils.checkIfPerceptuallyDark(perceivedLightness: perceivedLightness)
    }
    
    /// Returns the perceived contrast between this color and another color.
    ///
    /// Positive values indicate this color is lighter than the comparison color.
    ///
    /// - Parameter color: The color to compare against
    /// - Returns: The difference in perceived lightness (this color - comparison color)
    /// - Note: Uses ``ColorPerceptionUtils/calculatePerceivedContrast(lhsLightness:rhsLightness:)`` internally
    func perceivedContrast(against color: Self) -> CGFloat {
        ColorPerceptionUtils.calculatePerceivedContrast(
            lhsLightness: perceivedLightness,
            rhsLightness: color.perceivedLightness
        )
    }
}
