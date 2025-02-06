//
//  ContrastPairCache.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import Foundation

/// Represents a contrast choice between dark and light colors.
public enum ContrastChoice: Sendable {
    case dark
    case light
}

/// A type that caches dark/light contrast decisions.
///
/// This protocol defines the interface for colors that can be analyzed and
/// manipulated based on human visual perception. It extends `ColorConvertible`
/// to add perceptual properties and operations.
///
/// Required capabilities:
/// - Store and retrieve contrast choices
/// - Provide dark and light contrast colors
/// - Manage cache lifecycle
///
/// Example usage:
///
///     let cache: ContrastPairCache = ...
///     cache.cache(choice: .dark, for: color)
///     if let choice = cache.getCachedChoice(for: color) {
///         let contrasting = cache.getContrastingColor(for: choice)
///     }
public protocol ContrastPairCache<PerceptualColor> {
    associatedtype PerceptualColor: ColorConvertible
    
    var darkColor: PerceptualColor { get }
    var lightColor: PerceptualColor { get }
    
    func getCachedChoice(for color: PerceptualColor) -> ContrastChoice?
    func cache(choice: ContrastChoice, for color: PerceptualColor)
    func clearCache()
}

public extension ContrastPairCache {
    /// Gets the contrasting color for a given choice.
    ///
    /// This implementation provides a simple mapping:
    /// - `.dark` returns the cache's dark color
    /// - `.light` returns the cache's light color
    ///
    /// - Parameter choice: The contrast choice to get the color for
    /// - Returns: The corresponding dark or light color
    func getContrastingColor(for choice: ContrastChoice) -> PerceptualColor {
        switch choice {
        case .dark: return darkColor
        case .light: return lightColor
        }
    }
    
    /// Gets the contrasting color for a base color, using cache if available.
    ///
    /// This implementation:
    /// 1. Checks cache for existing choice
    /// 2. If not found, calculates choice based on perceived lightness
    /// 3. Caches the result for future use
    ///
    /// - Parameters:
    ///   - color: The base color to find contrast for
    ///   - perceivedLightness: The perceived lightness of the base color
    /// - Returns: The contrasting color (either dark or light)
    /// - Note: Thread safety depends on implementation of protocol requirements
    func getContrastingColor(for color: PerceptualColor, perceivedLightness: CGFloat) -> PerceptualColor {
        if let choice = getCachedChoice(for: color) {
            return getContrastingColor(for: choice)
        }
        
        let choice = ColorPerceptionUtils.checkIfPerceptuallyLight(perceivedLightness: perceivedLightness) 
        ? ContrastChoice.dark 
        : ContrastChoice.light
        cache(choice: choice, for: color)
        return getContrastingColor(for: choice)
    }
} 
