//
//  UIColorExtensionTests.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import Testing
import UIKit
@testable import ColorPerception

struct UIColorExtensionTests {
    @Test("Calculates relative luminance for standard colors", arguments: [
        (TestUIColors.black, 0.0),
        (TestUIColors.white, 1.0),
        (TestUIColors.middleGray, 0.2140),
        (TestUIColors.justBelowPerceptualMiddleGray, 0.18418651),
        (TestUIColors.justAbovePerceptualMiddleGray, 0.18418656)
    ])
    func relativeLuminance(color: UIColor, expected: CGFloat) throws {
        #expect(color.relativeLuminance.isApproximatelyEqual(to: expected, tolerance: 0.001))
    }
    
    @Test("Calculates perceived lightness correctly", arguments: [
        (TestUIColors.black, 0.0),
        (TestUIColors.white, 100.0),
        (TestUIColors.middleGray, 53.39),
        (TestUIColors.justBelowPerceptualMiddleGray, 49.99999849),
        (TestUIColors.justAbovePerceptualMiddleGray, 50.00000452)
    ])
    func perceivedLightness(color: UIColor, expected: CGFloat) throws {
        #expect(color.perceivedLightness.isApproximatelyEqual(to: expected, tolerance: 0.01))
    }
    
    @Test("Calculates perceived contrast between colors", arguments: [
        (TestUIColors.black, TestUIColors.white, -100.0),
        (TestUIColors.white, TestUIColors.black, 100.0),
        (TestUIColors.black, TestUIColors.black, 0.0)
    ])
    func perceivedContrast(color1: UIColor, color2: UIColor, expected: CGFloat) throws {
        #expect(color1.perceivedContrast(against: color2) == expected)
    }
    
    @Test("Returns best contrasting color with no options", arguments: [
        (TestUIColors.black, TestUIColors.white),
        (TestUIColors.white, TestUIColors.black),
        (TestUIColors.middleGray, TestUIColors.black),
        (TestUIColors.justBelowPerceptualMiddleGray, TestUIColors.white),
        (TestUIColors.justAbovePerceptualMiddleGray, TestUIColors.black)
    ])
    func perceptualContrastingColorDefault(color: UIColor, expected: UIColor) throws {
        #expect(color.perceptualContrastingColor() == expected)
    }
    
    @Test("Returns best contrasting color from two options", arguments: [
        (TestUIColors.black, [TestUIColors.middleGray, TestUIColors.white], TestUIColors.white),
        (TestUIColors.white, [TestUIColors.middleGray, TestUIColors.black], TestUIColors.black)
    ])
    func perceptualContrastingColorTwoOptions(color: UIColor, colors: [UIColor], expected: UIColor) throws {
        let result = color.perceptualContrastingColor(from: colors[0], colors[1])
        #expect(result == expected)
    }
    
    @Test("Correctly identifies perceptually light and dark colors", arguments: [
        (TestUIColors.black, true, false),
        (TestUIColors.white, false, true),
        (TestUIColors.middleGray, false, true),
        (TestUIColors.justBelowPerceptualMiddleGray, true, false),
        (TestUIColors.justAbovePerceptualMiddleGray, false, true)
    ])
    func perceptualLightnessDarkness(color: UIColor, isDark: Bool, isLight: Bool) throws {
        #expect(color.isPerceptuallyDark == isDark)
        #expect(color.isPerceptuallyLight == isLight)
    }
}
