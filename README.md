# ColorPerception

A Swift package for analyzing and manipulating colors based on human visual perception. This library provides a scientifically accurate way to work with colors as they are perceived by the human eye, rather than just their raw RGB values.

## Why Perceived Lightness Matters

Human vision is non-linear - we don't perceive changes in light intensity in a linear way. For example, a gray color with 50% RGB intensity (127,127,127) appears much darker to our eyes than "halfway" between black and white. This is because our eyes are more sensitive to changes in darker colors than in lighter ones.

This package uses the CIELAB color space's L* (lightness) component, which was specifically designed to match human perception. This provides a perceptually uniform scale where:
- 0 represents black
- 50 represents perceptual middle gray
- 100 represents white

Some key benefits:

- **Accurate Contrast**: Better accessibility by ensuring text remains readable against any background
- **Perceptual Uniformity**: Changes in lightness appear consistent across the entire range
- **Scientific Accuracy**: Based on the CIE 1931 color space and ITU-R BT.709 standards
- **Color Fidelity**: Maintains original hue and, when possible, preserves saturation during lightness adjustments by using sophisticated HSB transformations

For example, these two grays have the same mathematical difference in RGB values, but appear very different to our eyes:
- Dark grays: (10,10,10) → (20,20,20) = small perceived difference
- Light grays: (200,200,200) → (210,210,210) = barely noticeable difference

This library handles these perceptual differences automatically, ensuring your color adjustments and contrast calculations match what users actually see.

## Features

* Calculate perceived lightness and relative luminance
* Find optimal contrasting colors
* Adjust colors based on perceived lightness
* Thread-safe caching of contrast decisions
* Support for both SwiftUI and UIKit
* Precise color adjustments (±0.1 perceived lightness)

## Requirements

* iOS 15.0+
* tvOS 15.0+
* watchOS 8.0+
* visionOS 1.0+
* Swift 6.0+

## Installation

### Swift Package Manager

Add ColorPerception to your project through Xcode:
1. File > Add Packages...
2. Enter package URL: `https://github.com/gregmturek/color-perception`
3. Select "Up to Next Major Version"

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/gregmturek/color-perception", from: "1.0.0")
]
```

## Usage

### SwiftUI

```swift
import SwiftUI
import ColorPerception

// Core perceptual properties
let sunset = Color.orange
let luminance = sunset.relativeLuminance  // Physical light measurement (0-1)
let lightness = sunset.perceivedLightness  // Human perception (0-100)
let isDark = sunset.isPerceptuallyDark  // true if lightness < 50
let isLight = sunset.isPerceptuallyLight  // true if lightness > 50

// Contrast calculations
let skyContrast = sunset.perceivedContrast(against: .cyan)  // Positive if sunset is lighter

// Finding contrasting colors
let bestContrast = sunset.perceptualContrastingColor()  // Uses cached black/white decision
let bestFromOptions = sunset.perceptualContrastingColor(from: .purple, .indigo)  // Finds highest contrast

// Adjusting lightness
let dusk = sunset.adjustingPerceivedLightness(by: -30)  // Darker sunset
let noon = sunset.adjustingPerceivedLightness(by: 30)  // Brighter sunset
let sunrise = sunset.withPerceivedLightness(85)  // Early morning glow
```

### UIKit

```swift
import UIKit
import ColorPerception

// Core perceptual properties
let ocean = UIColor.blue
let luminance = ocean.relativeLuminance  // Physical light measurement (0-1)
let lightness = ocean.perceivedLightness  // Human perception (0-100)
let isDark = ocean.isPerceptuallyDark  // true if lightness < 50
let isLight = ocean.isPerceptuallyLight  // true if lightness > 50

// Contrast calculations
let sandContrast = ocean.perceivedContrast(against: .orange)  // Positive if ocean is lighter

// Finding contrasting colors
let bestContrast = ocean.perceptualContrastingColor()  // Uses cached black/white decision
let bestFromOptions = ocean.perceptualContrastingColor(from: .orange, .brown)  // Finds highest contrast

// Adjusting lightness
let deepOcean = ocean.adjustingPerceivedLightness(by: -40)  // Deep waters
let shallows = ocean.adjustingPerceivedLightness(by: 25)  // Tropical waters
let seafoam = ocean.withPerceivedLightness(90)  // Breaking waves
```

### Advanced Usage

#### Custom Contrast Cache

For specialized use cases, you can create a custom cache with your own dark/light color pair:

```swift
// Create a custom cache
let cache = DefaultContrastPairCache<UIColor>(
    darkColor: UIColor(red: 0.0, green: 0.05, blue: 0.2, alpha: 1.0),  // Deep ocean abyss
    lightColor: UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0),  // Ocean surface
    cacheSize: 200  // Optional, defaults to 100
)

// Use custom cache for contrast decisions
let contrast = color.perceptualContrastingColor(using: cache)
```

By default, contrast calculations are automatically cached using an efficient thread-safe implementation. The cache uses black and white as the default contrast pair and automatically manages memory usage. Custom caches are only needed for special cases where different contrast colors or cache sizes are required.

#### Direct Color Calculations

For more control, you can use ColorPerceptionUtils directly to perform calculations:

```swift
// Extract and convert color components
let components = ColorPerceptionUtils.extractSRGBComponents(from: color.cgColor)
let rLinear = ColorPerceptionUtils.convertToLinearSRGB(components.red)
let gLinear = ColorPerceptionUtils.convertToLinearSRGB(components.green)
let bLinear = ColorPerceptionUtils.convertToLinearSRGB(components.blue)

// Calculate physical measurements
let luminance = ColorPerceptionUtils.calculateRelativeLuminance(
    red: components.red,
    green: components.green,
    blue: components.blue
)

// Convert to human perception
let lightness = ColorPerceptionUtils.calculatePerceivedLightness(from: luminance)

// Compare colors
let contrast = ColorPerceptionUtils.calculatePerceivedContrast(
    lhsLightness: color1.perceivedLightness,
    rhsLightness: color2.perceivedLightness
)

// Make perceptual decisions
let isLight = ColorPerceptionUtils.checkIfPerceptuallyLight(perceivedLightness: lightness)
let isDark = ColorPerceptionUtils.checkIfPerceptuallyDark(perceivedLightness: lightness)

// Change colors
let adjusted = ColorPerceptionUtils.withPerceivedLightness(color, lightness: 75)  // Set absolute lightness
let brighter = ColorPerceptionUtils.adjustPerceivedLightness(of: color, by: 20)   // Relative adjustment

// Find optimal contrast
let bestContrast = ColorPerceptionUtils.findOptimalContrastingColor(
    baseColor: color,
    from: [option1, option2, option3],
    using: cache,
    perceivedLightness: lightness
)
```

These lower-level utilities give you direct access to the color science calculations when you need more control or want to implement custom color manipulation algorithms.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License (see the LICENSE file for details).
