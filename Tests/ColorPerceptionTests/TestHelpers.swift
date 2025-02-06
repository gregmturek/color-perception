//
//  TestHelpers.swift
//  ColorPerception
//
//  Created by Greg Turek on 2/6/25.
//

import CoreGraphics
import SwiftUI

extension CGFloat {
    func isApproximatelyEqual(to other: CGFloat, tolerance: CGFloat = 0.0001) -> Bool {
        abs(self - other) < tolerance
    }
}

struct TestUIColors {
    static let black = UIColor.black
    static let white = UIColor.white
    static let red = UIColor.red
    static let green = UIColor.green
    static let blue = UIColor.blue
    static let gray = UIColor.gray
    
    static let middleGray = UIColor(white: 0.5, alpha: 1.0)
    static let justBelowPerceptualMiddleGray = UIColor(white: 0.466326, alpha: 1.0)
    static let justAbovePerceptualMiddleGray = UIColor(white: 0.466327, alpha: 1.0)
    
    static let halfAlphaMiddleGray = UIColor(white: 0.5, alpha: 0.5)
    static let quarterAlphaMiddleGray = UIColor(white: 0.5, alpha: 0.25)
    static let eightyPercentAlphaMiddleGray = UIColor(white: 0.5, alpha: 0.8)
    static let twentyPercentAlphaMiddleGray = UIColor(white: 0.5, alpha: 0.2)
    
    static let halfAlphaRed = UIColor.red.withAlphaComponent(0.5)
    static let eightyPercentAlphaGreen = UIColor.green.withAlphaComponent(0.8)
}

struct TestColors {
    static let black = Color.black
    static let white = Color.white
    static let red = Color.red
    static let green = Color.green
    static let blue = Color.blue
    static let gray = Color.gray
    
    static let middleGray = Color(white: 0.5)
    static let justBelowPerceptualMiddleGray = Color(white: 0.466326)
    static let justAbovePerceptualMiddleGray = Color(white: 0.466327)
}
