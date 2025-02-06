//
//  ColorExtensionTests.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import Testing
import SwiftUI
@testable import ColorPerception

@Suite("ColorExtension Tests")
struct ColorExtensionTests {
    @Test("Calculates relative luminance for standard colors", arguments: [
        (TestColors.black, 0.0),
        (TestColors.white, 1.0),
        (TestColors.middleGray, 0.2140),
        (TestColors.justBelowPerceptualMiddleGray, 0.18418651),
        (TestColors.justAbovePerceptualMiddleGray, 0.18418656)
    ])
    func relativeLuminance(color: Color, expected: CGFloat) throws {
        #expect(color.relativeLuminance.isApproximatelyEqual(to: expected, tolerance: 0.001))
    }
    
    @Test("Calculates perceived lightness correctly", arguments: [
        (TestColors.black, 0.0),
        (TestColors.white, 100.0),
        (TestColors.middleGray, 53.39),
        (TestColors.justBelowPerceptualMiddleGray, 49.99999849),
        (TestColors.justAbovePerceptualMiddleGray, 50.00000452)
    ])
    func perceivedLightness(color: Color, expected: CGFloat) throws {
        #expect(color.perceivedLightness.isApproximatelyEqual(to: expected, tolerance: 0.01))
    }
    
    @Test("Calculates perceived contrast between colors", arguments: [
        (TestColors.black, TestColors.white, -100.0),
        (TestColors.white, TestColors.black, 100.0),
        (TestColors.black, TestColors.black, 0.0)
    ])
    func perceivedContrast(color1: Color, color2: Color, expected: CGFloat) throws {
        #expect(color1.perceivedContrast(against: color2) == expected)
    }
    
    @Test("Returns best contrasting color with no options", arguments: [
        (TestColors.black, TestColors.white),
        (TestColors.white, TestColors.black),
        (TestColors.middleGray, TestColors.black),
        (TestColors.justBelowPerceptualMiddleGray, TestColors.white),
        (TestColors.justAbovePerceptualMiddleGray, TestColors.black)
    ])
    func perceptualContrastingColorDefault(color: Color, expected: Color) throws {
        #expect(color.perceptualContrastingColor() == expected)
    }
    
    @Test("Returns best contrasting color from two options", arguments: [
        (TestColors.black, [TestColors.middleGray, TestColors.white], TestColors.white),
        (TestColors.white, [TestColors.middleGray, TestColors.black], TestColors.black)
    ])
    func perceptualContrastingColorTwoOptions(color: Color, colors: [Color], expected: Color) throws {
        let result = color.perceptualContrastingColor(from: colors[0], colors[1])
        #expect(result == expected)
    }
    
    @Test("Correctly identifies perceptually light and dark colors", arguments: [
        (TestColors.black, true, false),
        (TestColors.white, false, true),
        (TestColors.middleGray, false, true),
        (TestColors.justBelowPerceptualMiddleGray, true, false),
        (TestColors.justAbovePerceptualMiddleGray, false, true)
    ])
    func perceptualLightnessDarkness(color: Color, isDark: Bool, isLight: Bool) throws {
        #expect(color.isPerceptuallyDark == isDark)
        #expect(color.isPerceptuallyLight == isLight)
    }
}
