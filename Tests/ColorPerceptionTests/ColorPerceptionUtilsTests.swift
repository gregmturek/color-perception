//
//  ColorPerceptionUtilsTests.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import Testing
import UIKit
@testable import ColorPerception

@Suite("ColorPerceptionUtils Tests")
struct ColorPerceptionUtilsTests {
    
    @Test("Returns correct linear sRGB values below and above threshold", arguments: [
        (0.04, 0.003093),
        (0.05, 0.003936)
    ])
    func convertToLinearSRGB(value: CGFloat, expected: CGFloat) {
        let result = ColorPerceptionUtils.convertToLinearSRGB(value)
        #expect(result.isApproximatelyEqual(to: expected))
    }
    
    @Test("Correctly calculates relative luminance from RGB components", arguments: [
        (red: 1.0, green: 0.0, blue: 0.0, expected: 0.2126),
        (red: 0.0, green: 1.0, blue: 0.0, expected: 0.7152),
        (red: 0.0, green: 0.0, blue: 1.0, expected: 0.0722),
        (red: 1.0, green: 1.0, blue: 1.0, expected: 1.0),
        (red: 0.0, green: 0.0, blue: 0.0, expected: 0.0)
    ])
    func relativeLuminanceFromComponents(red: CGFloat, green: CGFloat, blue: CGFloat, expected: CGFloat) {
        let result = ColorPerceptionUtils.calculateRelativeLuminance(red: red, green: green, blue: blue)
        #expect(result.isApproximatelyEqual(to: expected, tolerance: 0.001))
    }
    
    @Test("Correctly calculates relative luminance from CGColor", arguments: [
        (TestUIColors.red, 0.2126),
        (TestUIColors.green, 0.7152),
        (TestUIColors.blue, 0.0722),
        (TestUIColors.black, 0.0),
        (TestUIColors.white, 1.0),
        (TestUIColors.middleGray, 0.2140),
        (TestUIColors.justBelowPerceptualMiddleGray, 0.18418651),
        (TestUIColors.justAbovePerceptualMiddleGray, 0.18418656)
    ])
    func relativeLuminanceFromCGColor(color: UIColor, expected: CGFloat) {
        let result = ColorPerceptionUtils.calculateRelativeLuminance(from: color.cgColor)
        #expect(result.isApproximatelyEqual(to: expected, tolerance: 0.001))
    }
    
    @Test("Correctly calculates perceived lightness from luminance", arguments: [
        (luminance: 0.0, expected: 0.0),
        (luminance: 1.0, expected: 100.0),
        (luminance: 0.5, expected: 76.0693),
        (luminance: 0.18, expected: 49.4969),
        (luminance: 0.008856, expected: 8.0)
    ])
    func perceivedLightnessCalculation(luminance: CGFloat, expected: CGFloat) {
        let result = ColorPerceptionUtils.calculatePerceivedLightness(from: luminance)
        #expect(result.isApproximatelyEqual(to: expected, tolerance: 0.01))
    }
    
    @Test("Correctly extracts sRGB components from CGColor", arguments: [
        (TestUIColors.red, (1.0, 0.0, 0.0)),
        (TestUIColors.green, (0.0, 1.0, 0.0)),
        (TestUIColors.blue, (0.0, 0.0, 1.0)),
        (TestUIColors.black, (0.0, 0.0, 0.0)),
        (TestUIColors.white, (1.0, 1.0, 1.0))
    ])
    func sRGBComponentExtraction(color: UIColor, expected: (red: CGFloat, green: CGFloat, blue: CGFloat)) {
        let result = ColorPerceptionUtils.extractSRGBComponents(from: color.cgColor)
        #expect(result != nil)
        #expect(result!.red.isApproximatelyEqual(to: expected.red))
        #expect(result!.green.isApproximatelyEqual(to: expected.green))
        #expect(result!.blue.isApproximatelyEqual(to: expected.blue))
    }
    
    @Test("Correctly calculates perceived contrast between lightness values", arguments: [
        (lhs: 100.0, rhs: 0.0, expected: 100.0),
        (lhs: 0.0, rhs: 100.0, expected: -100.0),
        (lhs: 50.0, rhs: 50.0, expected: 0.0),
        (lhs: 75.0, rhs: 25.0, expected: 50.0)
    ])
    func perceivedContrastCalculation(lhs: CGFloat, rhs: CGFloat, expected: CGFloat) {
        let result = ColorPerceptionUtils.calculatePerceivedContrast(lhsLightness: lhs, rhsLightness: rhs)
        #expect(result == expected)
    }
    
    @Test("Correctly identifies perceptually light colors", arguments: [
        (lightness: 0.0, expected: false),
        (lightness: 50.0, expected: false),
        (lightness: 50.000001, expected: true),
        (lightness: 100.0, expected: true)
    ])
    func perceptuallyLightCheck(lightness: CGFloat, expected: Bool) {
        let result = ColorPerceptionUtils.checkIfPerceptuallyLight(perceivedLightness: lightness)
        #expect(result == expected)
    }
    
    @Test("Correctly identifies perceptually dark colors", arguments: [
        (lightness: 0.0, expected: true),
        (lightness: 49.999999, expected: true),
        (lightness: 50.0, expected: false),
        (lightness: 100.0, expected: false)
    ])
    func perceptuallyDarkCheck(lightness: CGFloat, expected: Bool) {
        let result = ColorPerceptionUtils.checkIfPerceptuallyDark(perceivedLightness: lightness)
        #expect(result == expected)
    }
    
    @Test(
        "Returns correct contrasting color",
        arguments: [
            (base: TestUIColors.red, colors: [], expected: TestUIColors.black),
            (base: TestUIColors.green, colors: [], expected: TestUIColors.black),
            (base: TestUIColors.blue, colors: [], expected: TestUIColors.white),
            (base: TestUIColors.black, colors: [], expected: TestUIColors.white),
            (base: TestUIColors.white, colors: [], expected: TestUIColors.black),
            (base: TestUIColors.middleGray, colors: [], expected: TestUIColors.black),
            (base: TestUIColors.justBelowPerceptualMiddleGray, colors: [], expected: TestUIColors.white),
            (base: TestUIColors.justAbovePerceptualMiddleGray, colors: [], expected: TestUIColors.black),
            (
                base: TestUIColors.white,
                colors: [TestUIColors.white, TestUIColors.black, TestUIColors.red],
                expected: TestUIColors.black
            ),
            (
                base: TestUIColors.white,
                colors: [TestUIColors.red, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.blue
            ),
            (
                base: TestUIColors.black,
                colors: [TestUIColors.black, TestUIColors.white, TestUIColors.red],
                expected: TestUIColors.white
            ),
            (
                base: TestUIColors.black,
                colors: [TestUIColors.red, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.green
            ),
            (
                base: TestUIColors.red,
                colors: [TestUIColors.red, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.green
            ),
            (
                base: TestUIColors.red,
                colors: [TestUIColors.gray, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.green
            ),
            (
                base: TestUIColors.red,
                colors: [TestUIColors.black, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.black
            ),
            (
                base: TestUIColors.red,
                colors: [TestUIColors.white, TestUIColors.green, TestUIColors.blue],
                expected: TestUIColors.white
            )
        ]
    )
    func optimalContrastingColor(base: UIColor, colors: [UIColor], expected: UIColor) {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        let luminance = ColorPerceptionUtils.calculateRelativeLuminance(from: base.cgColor)
        let lightness = ColorPerceptionUtils.calculatePerceivedLightness(from: luminance)
        let result = ColorPerceptionUtils.findOptimalContrastingColor(
            baseColor: base,
            from: colors,
            using: cache,
            perceivedLightness: lightness
        )
        #expect(result == expected)
    }
        
    @Test("Sets specific perceived lightness value", arguments: [
        (color: TestUIColors.black, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.black, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.black, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.black, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.black, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.black, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.black, targetLightness: 100, expectedLightness: 100),
        (color: TestUIColors.white, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.white, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.white, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.white, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.white, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.white, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.middleGray, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.middleGray, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.middleGray, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.middleGray, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.middleGray, targetLightness: 53.3890, expectedLightness: 53.3890),
        (color: TestUIColors.middleGray, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.middleGray, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.middleGray, targetLightness: 100, expectedLightness: 100),
        (color: TestUIColors.black, targetLightness: 150, expectedLightness: 100),
        (color: TestUIColors.white, targetLightness: -50, expectedLightness: 0),
        (color: TestUIColors.red, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.red, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.red, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.red, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.red, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.red, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.red, targetLightness: 100, expectedLightness: 100),
        (color: TestUIColors.green, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.green, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.green, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.green, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.green, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.green, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.green, targetLightness: 100, expectedLightness: 100),
        (color: TestUIColors.blue, targetLightness: 0, expectedLightness: 0),
        (color: TestUIColors.blue, targetLightness: 1, expectedLightness: 1),
        (color: TestUIColors.blue, targetLightness: 25, expectedLightness: 25),
        (color: TestUIColors.blue, targetLightness: 50, expectedLightness: 50),
        (color: TestUIColors.blue, targetLightness: 75, expectedLightness: 75),
        (color: TestUIColors.blue, targetLightness: 99, expectedLightness: 99),
        (color: TestUIColors.blue, targetLightness: 100, expectedLightness: 100)
    ])
    func setPerceivedLightness(color: UIColor, targetLightness: CGFloat, expectedLightness: CGFloat) {
        let adjusted = ColorPerceptionUtils.withPerceivedLightness(color, lightness: targetLightness)
        #expect(adjusted.perceivedLightness.isApproximatelyEqual(to: expectedLightness, tolerance: 0.1))
    }

    @Test("Adjusts perceived lightness by amount", arguments: [
        (color: TestUIColors.black, amount: 0, expectedLightness: 0),
        (color: TestUIColors.black, amount: 1, expectedLightness: 1),
        (color: TestUIColors.black, amount: 50, expectedLightness: 50),
        (color: TestUIColors.black, amount: 99, expectedLightness: 99),
        (color: TestUIColors.black, amount: 100, expectedLightness: 100),
        (color: TestUIColors.white, amount: -100, expectedLightness: 0),
        (color: TestUIColors.white, amount: -99, expectedLightness: 1),
        (color: TestUIColors.white, amount: -50, expectedLightness: 50),
        (color: TestUIColors.white, amount: -1, expectedLightness: 99),
        (color: TestUIColors.white, amount: 0, expectedLightness: 100),
        (color: TestUIColors.middleGray, amount: 1, expectedLightness: 54.3890),
        (color: TestUIColors.middleGray, amount: -1, expectedLightness: 52.3890),
        (color: TestUIColors.middleGray, amount: 25, expectedLightness: 78.3890),
        (color: TestUIColors.middleGray, amount: -25, expectedLightness: 28.3890),
        (color: TestUIColors.middleGray, amount: 45, expectedLightness: 98.3890),
        (color: TestUIColors.middleGray, amount: -45, expectedLightness: 8.3890),
        (color: TestUIColors.middleGray, amount: 46.5, expectedLightness: 99.8890),
        (color: TestUIColors.middleGray, amount: -53, expectedLightness: 0.3890),
        (color: TestUIColors.black, amount: 150, expectedLightness: 100),
        (color: TestUIColors.white, amount: -150, expectedLightness: 0)
    ])
    func adjustPerceivedLightness(color: UIColor, amount: CGFloat, expectedLightness: CGFloat) {
        let adjusted = ColorPerceptionUtils.adjustPerceivedLightness(of: color, by: amount)
        #expect(adjusted.perceivedLightness.isApproximatelyEqual(to: expectedLightness, tolerance: 0.1))
    }
    
    @Test("Maintains color hue when adjusting lightness", arguments: [
        (color: TestUIColors.red, amount: 25),
        (color: TestUIColors.red, amount: -25),
        (color: TestUIColors.red, amount: 100),
        (color: TestUIColors.red, amount: -100),
        (color: TestUIColors.green, amount: 25),
        (color: TestUIColors.green, amount: -25),
        (color: TestUIColors.green, amount: 100),
        (color: TestUIColors.green, amount: -100),
        (color: TestUIColors.blue, amount: 25),
        (color: TestUIColors.blue, amount: -25),
        (color: TestUIColors.blue, amount: 100),
        (color: TestUIColors.blue, amount: -100)
    ])
    func maintainsHueWhenAdjustingLightness(color: UIColor, amount: CGFloat) {
        var originalHue: CGFloat = 0
        var originalSaturation: CGFloat = 0
        var originalBrightness: CGFloat = 0
        var originalAlpha: CGFloat = 0
        color
            .getHue(
                &originalHue,
                saturation: &originalSaturation,
                brightness: &originalBrightness,
                alpha: &originalAlpha
            )
        
        let adjusted = ColorPerceptionUtils.adjustPerceivedLightness(of: color, by: amount)
        
        var newHue: CGFloat = 0
        var newSaturation: CGFloat = 0
        var newBrightness: CGFloat = 0
        var newAlpha: CGFloat = 0
        adjusted.getHue(&newHue, saturation: &newSaturation, brightness: &newBrightness, alpha: &newAlpha)
        
        #expect(newHue.isApproximatelyEqual(to: originalHue, tolerance: 0.01))
    }
    
    @Test("Preserves alpha when adjusting lightness", arguments: [
        (color: TestUIColors.halfAlphaRed, amount: 25),
        (color: TestUIColors.eightyPercentAlphaGreen, amount: -25)
    ])
    func preservesAlphaWhenAdjustingLightness(color: UIColor, amount: CGFloat) {
        var originalAlpha: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: nil, alpha: &originalAlpha)
        
        let adjusted = ColorPerceptionUtils.adjustPerceivedLightness(of: color, by: amount)
        
        var newAlpha: CGFloat = 0
        adjusted.getHue(nil, saturation: nil, brightness: nil, alpha: &newAlpha)
        
        #expect(newAlpha.isApproximatelyEqual(to: originalAlpha))
    }
}
