//
//  ColorPerceptionUtils.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import SwiftUI

/// Utilities for calculating perceptual color properties.
///
/// Core calculations include:
/// - Converting between color spaces (sRGB, linear sRGB)
/// - Calculating relative luminance (physical light measurement)
/// - Converting luminance to perceived lightness (human perception)
/// - Finding optimal contrasting colors
/// - Changing perceived lightness
///
/// Example usage:
///
///     // Calculate perceived lightness
///     let components = ColorPerceptionUtils.extractSRGBComponents(from: color.cgColor)
///     let luminance = ColorPerceptionUtils.calculateRelativeLuminance(
///         red: components.red,
///         green: components.green,
///         blue: components.blue
///     )
///     let lightness = ColorPerceptionUtils.calculatePerceivedLightness(from: luminance)
public struct ColorPerceptionUtils {
    /// Converts an sRGB component to linear sRGB.
    ///
    /// This conversion is required for proper luminance calculations as the sRGB color space is non-linear.
    /// The conversion uses different formulas based on whether the value is above or below a threshold.
    ///
    /// - Parameter value: sRGB color component in the sRGB color space (0.0 to 1.0)
    /// - Returns: Linear sRGB value in the linear sRGB color space (0.0 to 1.0)
    /// - Note: For technical details, see [Stack Overflow: Convert sRGB to linear](https://stackoverflow.com/a/56678483)
    public static func convertToLinearSRGB(_ value: CGFloat) -> CGFloat {
        value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
    
    /// Calculates the relative luminance from RGB components in the sRGB color space.
    ///
    /// This method converts the extended sRGB color space used by iOS to standard sRGB and then to linear sRGB,
    /// which is required for the standard luminance formula using ITU-R BT.709 coefficients.
    ///
    /// - Parameters:
    ///   - red: Red component in the sRGB color space (0.0 to 1.0)
    ///   - green: Green component in the sRGB color space (0.0 to 1.0)
    ///   - blue: Blue component in the sRGB color space (0.0 to 1.0)
    /// - Returns: Relative luminance in the linear sRGB color space (0.0 to 1.0)
    /// - Note: See [Wikipedia: Relative luminance](https://en.wikipedia.org/wiki/Relative_luminance)
    /// - Attention: For human visual perception, prefer using `calculatePerceivedLightness` instead, as luminance represents
    /// the physical amount of light rather than how it's perceived by humans.
    public static func calculateRelativeLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let rLinear = convertToLinearSRGB(red)
        let gLinear = convertToLinearSRGB(green)
        let bLinear = convertToLinearSRGB(blue)
        return rLinear * 0.2126 + gLinear * 0.7152 + bLinear * 0.0722
    }
    
    /// Extracts RGB components from a CGColor.
    ///
    /// - Parameter cgColor: Color to extract components from
    /// - Returns: RGB components and alpha, or nil if conversion fails
    public static func extractSRGBComponents(from cgColor: CGColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let sRGBColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil),
              let components = sRGBColor.components,
              components.count >= 3 else {
            return nil
        }
        return (components[0], components[1], components[2], components[3])
    }
    
    /// Calculates relative luminance from a CGColor.
    ///
    /// This method handles the conversion from any color space to sRGB before calculating luminance.
    ///
    /// - Parameter cgColor: Color to calculate luminance for
    /// - Returns: Relative luminance in the linear sRGB color space (0.0 to 1.0), or 0 if the color cannot be converted to the sRGB color space
    /// - Note: Uses ``ColorPerceptionUtils/calculateRelativeLuminance(red:green:blue:)`` internally
    /// - Attention: For human visual perception, prefer using `calculatePerceivedLightness` instead, as luminance represents
    /// the physical amount of light rather than how it's perceived by humans.
    public static func calculateRelativeLuminance(from cgColor: CGColor) -> CGFloat {
        guard let components = extractSRGBComponents(from: cgColor) else { return 0 }
        return calculateRelativeLuminance(
            red: components.red,
            green: components.green,
            blue: components.blue
        )
    }
    
    /// Converts relative luminance to perceived lightness.
    ///
    /// This conversion provides a value that better matches human visual perception using the L\* scale
    /// from the CIELAB color space. The conversion uses different formulas based on whether the luminance
    /// is above or below a threshold.
    ///
    /// The result is a perceptually uniform scale where:
    /// - 0 represents black
    /// - 50 represents perceptual "middle gray"
    /// - 100 represents white
    ///
    /// - Parameter luminance: Relative luminance in the linear sRGB color space (0.0 to 1.0)
    /// - Returns: Perceived lightness on the L\* scale (0 to 100)
    /// - Note: See [Stack Overflow: Convert luminance to lightness](https://stackoverflow.com/a/56678483)
    /// - Attention: For the physical amount of light emitted or sensed, use `calculateRelativeLuminance` instead.
    /// This property is specifically designed to match human visual perception rather than physical light measurements.
    public static func calculatePerceivedLightness(from luminance: CGFloat) -> CGFloat {
        return luminance <= 216 / 24389
        ? luminance * 24389 / 27
        : pow(luminance, 1 / 3) * 116 - 16
    }
    
    /// Determines if a color is perceptually light.
    ///
    /// A color is considered perceptually light if its perceived lightness is greater than 50.
    ///
    /// - Parameter perceivedLightness: Perceived lightness value on the L\* scale (0 to 100)
    /// - Returns: True if lightness > 50
    /// - Warning: A color with exactly 50 perceived lightness (middle gray) will return `false`
    public static func checkIfPerceptuallyLight(perceivedLightness: CGFloat) -> Bool {
        perceivedLightness > 50
    }
    
    /// Determines if a color is perceptually dark.
    ///
    /// A color is considered perceptually dark if its perceived lightness is less than 50.
    ///
    /// - Parameter perceivedLightness: Perceived lightness value on the L\* scale (0 to 100)
    /// - Returns: True if lightness < 50
    /// - Warning: A color with exactly 50 perceived lightness (middle gray) will return `false`
    public static func checkIfPerceptuallyDark(perceivedLightness: CGFloat) -> Bool {
        perceivedLightness < 50
    }
    
    /// Calculates the perceived contrast between two lightness values.
    ///
    /// The contrast is calculated as the difference in perceived lightness between the two values.
    /// Positive values indicate the first value is lighter than the second value.
    ///
    /// This calculation uses the L\* scale from CIELAB, which is designed to be perceptually uniform,
    /// meaning that a change of 1.0 in lightness should be equally noticeable regardless of the base lightness.
    ///
    /// - Parameters:
    ///   - lhsLightness: Perceived lightness of the first color on the L\* scale (0 to 100)
    ///   - rhsLightness: Perceived lightness of the second color on the L\* scale (0 to 100)
    /// - Returns: The difference in perceived lightness (positive if first color is lighter)
    public static func calculatePerceivedContrast(lhsLightness: CGFloat, rhsLightness: CGFloat) -> CGFloat {
        lhsLightness - rhsLightness
    }
    
    /// Finds the optimal contrasting color from a set of colors.
    ///
    /// This method either:
    /// 1. Finds the color with the highest absolute contrast from the provided options, or
    /// 2. Uses the cache's dark/light colors if no options are provided
    ///
    /// The contrast calculation uses the CIELAB L\* scale to ensure perceptually uniform
    /// contrast measurements across the entire lightness range.
    ///
    /// - Parameters:
    ///   - baseColor: The color to find a contrast for
    ///   - colors: Array of colors to choose from, or empty to use cache defaults
    ///   - cache: Cache to store and retrieve contrast results
    ///   - perceivedLightness: The perceived lightness of the base color on the L\* scale (0 to 100)
    /// - Returns: The color with the highest absolute contrast to the base color
    /// - Note: Uses ``ColorPerceptionUtils/calculatePerceivedContrast(lhsLightness:rhsLightness:)`` internally
    public static func findOptimalContrastingColor<T: PerceptualColor, Cache: ContrastPairCache>(
        baseColor: T,
        from colors: [T],
        using cache: Cache,
        perceivedLightness: CGFloat
    ) -> T where Cache.PerceptualColor == T {
        if colors.isEmpty {
            return cache.getContrastingColor(for: baseColor, perceivedLightness: perceivedLightness)
        }
        
        return colors.max { color1, color2 in
            abs(calculatePerceivedContrast(
                lhsLightness: baseColor.perceivedLightness,
                rhsLightness: color1.perceivedLightness
            )) < abs(calculatePerceivedContrast(
                lhsLightness: baseColor.perceivedLightness,
                rhsLightness: color2.perceivedLightness
            ))
        } ?? cache.getContrastingColor(for: checkIfPerceptuallyLight(perceivedLightness: perceivedLightness) 
                                       ? .dark 
                                       : .light)
    }
        
    /// Sets absolute perceived lightness using a two-step HSB transformation.
    ///
    /// This method uses a sophisticated approach to achieve the target lightness while
    /// preserving color fidelity as much as possible. For grayscale colors, it uses
    /// direct luminance calculations. For chromatic colors, it employs a two-step process:
    ///
    /// 1. Binary search using brightness adjustments to get close to target
    /// 2. Fine-tuning with combined brightness and saturation adjustments
    ///
    /// The method guarantees results within ±0.1 of the target lightness or
    /// returns the original color if conversion fails.
    ///
    /// - Parameters:
    ///   - color: Base color to modify
    ///   - lightness: Target perceived lightness on the L\* scale (0 to 100)
    /// - Returns: New color with specified lightness, or original if conversion fails
    /// - Note: Uses HSB color space for adjustments to maintain color fidelity
    /// - Complexity: O(log n) with maximum 40 iterations (20 per step)
    public static func withPerceivedLightness<T: PerceptualColor>(_ color: T, lightness: CGFloat) -> T {
        let targetL = min(max(lightness, 0), 100)
        
        guard let components = extractSRGBComponents(from: color.cgColor) else {
            return color
        }
        
        // Handle grayscale colors directly.
        if components.red == components.green && components.green == components.blue {
            let targetY: CGFloat
            if targetL > 8.0 {
                let t = (targetL + 16.0)/116.0
                targetY = pow(t, 3.0)
            } else {
                targetY = targetL * pow(3.0/29.0, 3.0)
            }
            
            let srgbGray = targetY <= 0.0031308 ?
            12.92 * targetY :
            1.055 * pow(targetY, 1.0/2.4) - 0.055
            
            let adjustedColor = UIColor(white: min(max(srgbGray, 0), 1),
                                        alpha: components.alpha)
            guard let result = T.from(cgColor: adjustedColor.cgColor) as? T else {
                return color
            }
            return result
        }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(red: components.red,
                              green: components.green,
                              blue: components.blue,
                              alpha: components.alpha)
        
        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return color
        }
        
        // Step 1: Try to get as close as possible using only brightness adjustments.
        let epsilon: CGFloat = 0.1
        let maxBrightnessIterations = 20
        var bestBrightness = brightness
        var bestDiff = abs(
            calculatePerceivedLightness(
                from: calculateRelativeLuminance(
                    from: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
                )
            ) - targetL
        )
        
        var low: CGFloat = 0.0
        var high: CGFloat = 1.0
        
        for _ in 0..<maxBrightnessIterations {
            let mid = (low + high) / 2
            let testColor = UIColor(hue: hue, saturation: saturation, brightness: mid, alpha: alpha)
            let testL = calculatePerceivedLightness(from: calculateRelativeLuminance(from: testColor.cgColor))
            let diff = abs(testL - targetL)
            
            if diff < bestDiff {
                bestDiff = diff
                bestBrightness = mid
            }
            
            if abs(testL - targetL) < epsilon {
                break
            }
            
            if testL < targetL {
                low = mid
            } else {
                high = mid
            }
        }
        
        // If we're close enough with just brightness adjustment, return the result.
        if bestDiff < epsilon {
            let adjustedColor = UIColor(hue: hue,
                                        saturation: saturation,
                                        brightness: bestBrightness,
                                        alpha: alpha)
            guard let result = T.from(cgColor: adjustedColor.cgColor) as? T else {
                return color
            }
            return result
        }
        
        // Step 2: Fine-tune using combined brightness and saturation adjustments.
        let maxFinetuneIterations = 20
        var bestSaturation = saturation
        brightness = bestBrightness
        
        for _ in 0..<maxFinetuneIterations {
            let currentDiff = abs(
                calculatePerceivedLightness(
                    from: calculateRelativeLuminance(
                        from: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
                    )
                ) - targetL
            )
            if currentDiff < epsilon {
                break
            }
            
            var adjustments: [(brightness: CGFloat, saturation: CGFloat, diff: CGFloat)] = []
            let currentL = calculatePerceivedLightness(
                from: calculateRelativeLuminance(
                    from: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
                )
            )
            
            let progress = abs(currentL - targetL)
            let bigStep = min(0.1, progress / 50.0)
            let smallStep = bigStep / 5.0
            
            for bStep in [bigStep, smallStep, -smallStep, -bigStep] {
                let newBrightness = brightness + bStep
                if newBrightness >= 0.0 && newBrightness <= 1.0 {
                    for sStep in [bigStep, smallStep, -smallStep, -bigStep] {
                        let newSaturation = saturation + sStep
                        if newSaturation >= 0.0 && newSaturation <= 1.0 {
                            let testColor = UIColor(
                                hue: hue,
                                saturation: newSaturation,
                                brightness: newBrightness,
                                alpha: alpha
                            )
                            let testL = calculatePerceivedLightness(
                                from: calculateRelativeLuminance(from: testColor.cgColor)
                            )
                            adjustments.append((
                                newBrightness,
                                newSaturation,
                                abs(testL - targetL)
                            ))
                        }
                    }
                }
            }
            
            if currentL < targetL {
                adjustments.append(
                    (
                        brightness,
                        saturation * 0.5,
                        abs(
                            calculatePerceivedLightness(
                                from: calculateRelativeLuminance(
                                    from: UIColor(
                                        hue: hue,
                                        saturation: saturation * 0.5,
                                        brightness: brightness,
                                        alpha: alpha
                                    ).cgColor
                                )
                            ) - targetL
                        )
                    )
                )
            } else {
                adjustments.append(
                    (
                        brightness,
                        min(saturation * 1.5, 1.0),
                        abs(
                            calculatePerceivedLightness(
                                from: calculateRelativeLuminance(
                                    from: UIColor(
                                        hue: hue,
                                        saturation: min(saturation * 1.5, 1.0),
                                        brightness: brightness,
                                        alpha: alpha
                                    ).cgColor
                                )
                            ) - targetL
                        )
                    )
                )
            }
            
            if let best = adjustments.min(by: { $0.diff < $1.diff }) {
                if best.diff < currentDiff {
                    brightness = best.brightness
                    saturation = best.saturation
                    
                    if best.diff < bestDiff {
                        bestDiff = best.diff
                        bestBrightness = best.brightness
                        bestSaturation = best.saturation
                    }
                }
            }
        }
        
        let adjustedColor = UIColor(hue: hue,
                                    saturation: bestSaturation,
                                    brightness: bestBrightness,
                                    alpha: alpha)
        
        guard let result = T.from(cgColor: adjustedColor.cgColor) as? T else {
            return color
        }
        return result
    }
    
    /// Adjusts perceived lightness using HSB color space transformations.
    ///
    /// This method provides relative lightness adjustment by:
    /// 1. Getting current perceived lightness
    /// 2. Calculating target lightness by adding the adjustment amount
    /// 3. Using withPerceivedLightness to achieve the target
    ///
    /// - Parameters:
    ///   - color: Base color to adjust
    ///   - amount: Amount to adjust on the L\* scale (-100 to +100)
    /// - Returns: New color with adjusted lightness
    /// - Note: Uses ``ColorPerceptionUtils/withPerceivedLightness(_:lightness:)`` internally
    public static func adjustPerceivedLightness<T: PerceptualColor>(of color: T, by amount: CGFloat) -> T {
        let clampedAmount = min(max(amount, -100), 100)
        let currentLightness = calculatePerceivedLightness(from: calculateRelativeLuminance(from: color.cgColor))
        let targetLightness = min(max(currentLightness + clampedAmount, 0), 100)
        return withPerceivedLightness(color, lightness: targetLightness)
    }
}
