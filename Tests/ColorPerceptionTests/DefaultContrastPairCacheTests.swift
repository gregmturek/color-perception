import Testing
import SwiftUI
@testable import ColorPerception

@Suite("DefaultContrastPairCache Tests")
struct DefaultContrastPairCacheTests {
    
    @Test("Caches and retrieves contrast choices", arguments: [
        (TestUIColors.middleGray, ContrastChoice.dark),
        (TestUIColors.justBelowPerceptualMiddleGray, ContrastChoice.light),
        (TestUIColors.justAbovePerceptualMiddleGray, ContrastChoice.dark)
    ])
    func cachingAndRetrieving(color: UIColor, choice: ContrastChoice) throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        cache.cache(choice: choice, for: color)
        #expect(cache.getCachedChoice(for: color) == choice)
    }
    
    @Test("Returns correct contrasting color for choice", arguments: [
        (ContrastChoice.dark, TestUIColors.black),
        (ContrastChoice.light, TestUIColors.white)
    ])
    func contrastingColorForChoice(choice: ContrastChoice, expected: UIColor) throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        #expect(cache.getContrastingColor(for: choice) == expected)
    }
    
    @Test("Calculates and caches contrasting color correctly", arguments: [
        (TestUIColors.justAbovePerceptualMiddleGray, 50.00000452, ContrastChoice.dark, TestUIColors.black),
        (TestUIColors.justBelowPerceptualMiddleGray, 49.99999849, ContrastChoice.light, TestUIColors.white)
    ])
    func calculatesAndCachesContrast(
        color: UIColor,
        perceivedLightness: CGFloat,
        expectedChoice: ContrastChoice,
        expectedColor: UIColor
    ) throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        let result = cache.getContrastingColor(for: color, perceivedLightness: perceivedLightness)
        #expect(result == expectedColor)
        #expect(cache.getCachedChoice(for: color) == expectedChoice)
    }
    
    @Test(
        "Handles colors with same components but different alpha",
        arguments: [
            (TestUIColors.middleGray, TestUIColors.halfAlphaMiddleGray, ContrastChoice.dark, ContrastChoice.light),
            (
                TestUIColors.quarterAlphaMiddleGray,
                TestUIColors.eightyPercentAlphaMiddleGray,
                ContrastChoice.light,
                ContrastChoice.dark
            ),
            (
                TestUIColors.eightyPercentAlphaMiddleGray,
                TestUIColors.twentyPercentAlphaMiddleGray,
                ContrastChoice.dark,
                ContrastChoice.light
            )
        ]
    )
    func handlesAlphaCorrectly(color1: UIColor, color2: UIColor, choice1: ContrastChoice, choice2: ContrastChoice) throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        cache.cache(choice: choice1, for: color1)
        cache.cache(choice: choice2, for: color2)
        
        #expect(cache.getCachedChoice(for: color1) == choice1)
        #expect(cache.getCachedChoice(for: color2) == choice2)
    }
    
    @Test(
        "Maintains precision for similar colors",
        arguments: [
            (
                TestUIColors.justBelowPerceptualMiddleGray,
                TestUIColors.justAbovePerceptualMiddleGray,
                ContrastChoice.light,
                ContrastChoice.dark
            ),
            (
                TestUIColors.justAbovePerceptualMiddleGray,
                TestUIColors.justBelowPerceptualMiddleGray,
                ContrastChoice.dark,
                ContrastChoice.light
            )
        ]
    )
    func colorHashPrecision(color1: UIColor, color2: UIColor, choice1: ContrastChoice, choice2: ContrastChoice) throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        cache.cache(choice: choice1, for: color1)
        cache.cache(choice: choice2, for: color2)
        
        #expect(cache.getCachedChoice(for: color1) == choice1)
        #expect(cache.getCachedChoice(for: color2) == choice2)
    }
    
    @Test("Returns nil for uncached colors")
    func uncachedColors() throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        #expect(cache.getCachedChoice(for: TestUIColors.middleGray) == nil)
    }
    
    @Test("Clears cache correctly")
    func clearingCache() throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        cache.cache(choice: ContrastChoice.dark, for: TestUIColors.middleGray)
        cache.clearCache()
        #expect(cache.getCachedChoice(for: TestUIColors.middleGray) == nil)
    }
    
    @Test("Maintains consistent results for same color")
    func consistentResults() throws {
        let cache = DefaultContrastPairCache<UIColor>(
            darkColor: TestUIColors.black,
            lightColor: TestUIColors.white
        )
        
        let color = TestUIColors.middleGray
        let firstResult = cache.getContrastingColor(for: color, perceivedLightness: 53.39)
        let secondResult = cache.getContrastingColor(for: color, perceivedLightness: 53.39)
        
        #expect(firstResult == secondResult)
    }
    
    @Test("Shared caches are properly configured")
    func sharedCaches() throws {
        let uiColorCache = ContrastPairCaches.uiColorCache
        let colorCache = ContrastPairCaches.colorCache
        
        #expect(uiColorCache.darkColor == UIColor.black)
        #expect(uiColorCache.lightColor == UIColor.white)
        
        #expect(colorCache.darkColor == Color.black)
        #expect(colorCache.lightColor == Color.white)
    }
} 
