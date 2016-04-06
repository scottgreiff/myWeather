//
//  WAIcon.swift
//  myWeather
//
//  Created by sgreiff on 4/5/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    /**
     To set an icon, use i.e. `labelName.WIIcon = WIType.WIDayCloudyWindy`
     */
    var WIIcon: WIType? {
        set {
            if let newValue = newValue {
                FontLoader.loadFontIfNeeded()
                let weatherIcon = UIFont(name: WIStruct.FontName, size: self.font.pointSize)
                assert(font != nil, WIStruct.ErrorAnnounce)
                font = weatherIcon!
                text = newValue.text
            }
        }

        get {
            if let text = text {
                if let index = WIIcons.indexOf(text) {
                    return WIType(rawValue: index)
                }
            }

            return nil
        }
    }

    /**
     To set an icon, use i.e. `labelName.setWIIcon(WIType.WIDayCloudyWindy, iconSize: 35)`
     */
    func setWIIcon(icon: WIType, iconSize: CGFloat) {
        WIIcon = icon
        font = UIFont(name: font.fontName, size: iconSize)
    }

    func setWIText(prefixText prefixText: String, icon: WIType?, postfixText: String, size: CGFloat?, iconSize: CGFloat? = nil) {
        FontLoader.loadFontIfNeeded()
        let textFont = UIFont(name: WIStruct.FontName, size: size ?? self.font.pointSize)
        assert(textFont != nil, WIStruct.ErrorAnnounce)
        font = textFont!

        let textAttribute = [NSFontAttributeName: font]
        let myString = NSMutableAttributedString(string: prefixText, attributes: textAttribute)

        if let iconText = icon?.text {
            let iconFont = UIFont(name: WIStruct.FontName, size: iconSize ?? size ?? self.font.pointSize)!
            let iconAttribute = [NSFontAttributeName: iconFont]

            let iconString = NSAttributedString(string: iconText, attributes: iconAttribute)
            myString.appendAttributedString(iconString)
        }

        let postfixString = NSAttributedString(string: postfixText)
        myString.appendAttributedString(postfixString)

        self.attributedText = myString
    }
}

// Original idea from https://github.com/thii/FontAwesome.swift/blob/master/FontAwesome/FontAwesome.swift

public extension UIImageView {
    /**
     Create UIImage from WIType
     */
    public func setWIIconWithName(icon: WIType, textColor: UIColor, backgroundColor: UIColor = UIColor.clearColor()) {
        self.image = UIImage(icon: icon, size: frame.size, textColor: textColor, backgroundColor: backgroundColor)
    }
}

public extension UIImage {
    public convenience init(icon: WIType, size: CGSize, textColor: UIColor = UIColor.blackColor(), backgroundColor: UIColor = UIColor.clearColor()) {

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center

        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        let fontHeightAdjustment: CGFloat = 2
        let fontSize = min(size.width / fontAspectRatio, size.height)

        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: WIStruct.FontName, size: fontSize)
        assert(font != nil, WIStruct.ErrorAnnounce)
        let attributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor, NSParagraphStyleAttributeName: paragraph]

        let attributedString = NSAttributedString(string: icon.text!, attributes: attributes)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width * fontAspectRatio, size.height * fontAspectRatio), false, 0.0)
        attributedString.drawInRect(CGRectMake(0, (size.height - fontSize) / 2, size.width * fontAspectRatio, fontSize * fontHeightAdjustment))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.init(CGImage: image.CGImage!, scale: image.scale, orientation: image.imageOrientation)
    }
}

private struct WIStruct {
    static let FontName = "Weather Icons"
    static let ErrorAnnounce = "****** WEATHER ICONS SWIFT - WeatherIcons font not found in the bundle or not associated with Info.plist when manual installation was performed. ******"
}

private class FontLoader {

    struct Static {
        static var onceToken: dispatch_once_t = 0
    }

    static func loadFontIfNeeded() {
        if (UIFont.fontNamesForFamilyName(WIStruct.FontName).count == 0) {

            dispatch_once(&Static.onceToken) {
                let bundle = NSBundle(forClass: FontLoader.self)
                var fontURL = NSURL()

                fontURL = bundle.URLForResource(WIStruct.FontName, withExtension: "ttf")!
                let data = NSData(contentsOfURL: fontURL)!

                let provider = CGDataProviderCreateWithCFData(data)
                let font = CGFontCreateWithDataProvider(provider)!

                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(font, &error) {

                    let errorDescription: CFStringRef = CFErrorCopyDescription(error!.takeUnretainedValue())
                    let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
                    NSException(name: NSInternalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
                }
            }
        }
    }
}

/**
 List of all icons in Weather Icon
 */

public enum WIType: Int {
    static var count: Int {
        return WIIcons.count
    }

    var text: String? {
        return WIIcons[rawValue]
    }

    case WIDaySunny, WIDayCloudy, WIDayCloudyGusts, WIDayCloudyWindy, WIDayFog, WIDayHail, WIDayHaze, WIDayLightning, WIDayRain, WIDayRainMix, WIDayRainWind, WIDayShowers, WIDaySleet, WIDaySleetStorm, WIDaySnow, WIDaySnowThunderstorm, WIDaySnowWind, WIDaySprinkle, WIDayStormShowers, WIDaySunnyOvercast, WIDayThunderstorm, WIDayWindy, WISolarEclipse, WIHot, WIDayCloudyHigh, WIDayLightWind, WINightClear, WINightAltCloudy, WINightAltCloudyGusts, WINightAltCloudyWindy, WINightAltHail, WINightAltLightning, WINightAltRain, WINightAltRainMix, WINightAltRainWind, WINightAltShowers, WINightAltSleet, WINightAltSleetStorm, WINightAltSnow, WINightAltSnowThunderstorm, WINightAltSnowWind, WINightAltSprinkle, WINightAltStormShowers, WINightAltThunderstorm, WINightCloudy, WINightCloudyGusts, WINightCloudyWindy, WINightFog, WINightHail, WINightLightning, WINightPartlyCloudy, WINightRain, WINightRainMix, WINightRainWind, WINightShowers, WINightSleet, WINightSleetStorm, WINightSnow, WINightSnowThunderstorm, WINightSnowWind, WINightSprinkle, WINightStormShowers, WINightThunderstorm, WILunarEclipse, WIStars, WIStormShowers, WIThunderstorm, WINightAltCloudyHigh, WINightCloudyHigh, WINightAltPartlyCloudy, WICloud, WICloudy, WICloudyGusts, WICloudyWindy, WIFog, WIHail, WIRain, WIRainMix, WIRainWind, WIShowers, WISleet, WISnow, WISprinkle, WISnowWind, WISmog, WISmoke, WILightning, WIRaindrops, WIRaindrop, WIDust, WISnowflakeCold, WIWindy, WIStrongWind, WISandstorm, WIEarthquake, WIFire, WIFlood, WIMeteor, WITsunami, WIVolcano, WIHurricane, WITornado, WISmallCraftAdvisory, WIGaleWarning, WIStormWarning, WIHurricaneWarning, WIWindDirection, WIAlien, WICelsius, WIFahrenheit, WIDegrees, WIThermometer, WIThermometerExterior, WIThermometerInternal, WICloudDown, WICloudUp, WICloudRefresh, WIHorizon, WIHorizonAlt, WISunrise, WISunset, WIMoonrise, WIMoonset, WIRefresh, WIRefreshAlt, WIUmbrella, WIBarometer, WIHumidity, WINa, WITrain, WIMoonNew, WIMoonWaxingCrescent1, WIMoonWaxingCrescent2, WIMoonWaxingCrescent3, WIMoonWaxingCrescent4, WIMoonWaxingCrescent5, WIMoonWaxingCrescent6, WIMoonFirstQuarter, WIMoonWaxingGibbous1, WIMoonWaxingGibbous2, WIMoonWaxingGibbous3, WIMoonWaxingGibbous4, WIMoonWaxingGibbous5, WIMoonWaxingGibbous6, WIMoonFull, WIMoonWaningGibbous1, WIMoonWaningGibbous2, WIMoonWaningGibbous3, WIMoonWaningGibbous4, WIMoonWaningGibbous5, WIMoonWaningGibbous6, WIMoonThirdQuarter, WIMoonWaningCrescent1, WIMoonWaningCrescent2, WIMoonWaningCrescent3, WIMoonWaningCrescent4, WIMoonWaningCrescent5, WIMoonWaningCrescent6, WIMoonAltNew, WIMoonAltWaxingCrescent1, WIMoonAltWaxingCrescent2, WIMoonAltWaxingCrescent3, WIMoonAltWaxingCrescent4, WIMoonAltWaxingCrescent5, WIMoonAltWaxingCrescent6, WIMoonAltFirstQuarter, WIMoonAltWaxingGibbous1, WIMoonAltWaxingGibbous2, WIMoonAltWaxingGibbous3, WIMoonAltWaxingGibbous4, WIMoonAltWaxingGibbous5, WIMoonAltWaxingGibbous6, WIMoonAltFull, WIMoonAltWaningGibbous1, WIMoonAltWaningGibbous2, WIMoonAltWaningGibbous3, WIMoonAltWaningGibbous4, WIMoonAltWaningGibbous5, WIMoonAltWaningGibbous6, WIMoonAltThirdQuarter, WIMoonAltWaningCrescent1, WIMoonAltWaningCrescent2, WIMoonAltWaningCrescent3, WIMoonAltWaningCrescent4, WIMoonAltWaningCrescent5, WIMoonAltWaningCrescent6, WIMoon0, WIMoon1, WIMoon2, WIMoon3, WIMoon4, WIMoon5, WIMoon6, WIMoon7, WIMoon8, WIMoon9, WIMoon10, WIMoon11, WIMoon12, WIMoon13, WIMoon14, WIMoon15, WIMoon16, WIMoon17, WIMoon18, WIMoon19, WIMoon20, WIMoon21, WIMoon22, WIMoon23, WIMoon24, WIMoon25, WIMoon26, WIMoon27, WITime1, WITime2, WITime3, WITime4, WITime5, WITime6, WITime7, WITime8, WITime9, WITime10, WITime11, WITime12, WIDirectionUp, WIDirectionUpRight, WIDirectionRight, WIDirectionDownRight, WIDirectionDown, WIDirectionDownLeft, WIDirectionLeft, WIDirectionUpLeft, WIWindBeaufort0, WIWindBeaufort1, WIWindBeaufort2, WIWindBeaufort3, WIWindBeaufort4, WIWindBeaufort5, WIWindBeaufort6, WIWindBeaufort7, WIWindBeaufort8, WIWindBeaufort9, WIWindBeaufort10, WIWindBeaufort11, WIWindBeaufort12, WIYahoo0, WIYahoo1, WIYahoo2, WIYahoo3, WIYahoo4, WIYahoo5, WIYahoo6, WIYahoo7, WIYahoo8, WIYahoo9, WIYahoo10, WIYahoo11, WIYahoo12, WIYahoo13, WIYahoo14, WIYahoo15, WIYahoo16, WIYahoo17, WIYahoo18, WIYahoo19, WIYahoo20, WIYahoo21, WIYahoo22, WIYahoo23, WIYahoo24, WIYahoo25, WIYahoo26, WIYahoo27, WIYahoo28, WIYahoo29, WIYahoo30, WIYahoo31, WIYahoo32, WIYahoo33, WIYahoo34, WIYahoo35, WIYahoo36, WIYahoo37, WIYahoo38, WIYahoo39, WIYahoo40, WIYahoo41, WIYahoo42, WIYahoo43, WIYahoo44, WIYahoo45, WIYahoo46, WIYahoo47, WIYahoo3200, WIForecastIoClearDay, WIForecastIoClearNight, WIForecastIoRain, WIForecastIoSnow, WIForecastIoSleet, WIForecastIoWind, WIForecastIoFog, WIForecastIoCloudy, WIForecastIoPartlyCloudyDay, WIForecastIoPartlyCloudyNight, WIForecastIoHail, WIForecastIoThunderstorm, WIForecastIoTornado, WIWmo46800, WIWmo468000, WIWmo46801, WIWmo468001, WIWmo46802, WIWmo468002, WIWmo46803, WIWmo468003, WIWmo46804, WIWmo468004, WIWmo46805, WIWmo468005, WIWmo468010, WIWmo468011, WIWmo468012, WIWmo468018, WIWmo468020, WIWmo468021, WIWmo468022, WIWmo468023, WIWmo468024, WIWmo468025, WIWmo468026, WIWmo468027, WIWmo468028, WIWmo468029, WIWmo468030, WIWmo468031, WIWmo468032, WIWmo468033, WIWmo468034, WIWmo468035, WIWmo468040, WIWmo468041, WIWmo468042, WIWmo468043, WIWmo468044, WIWmo468045, WIWmo468046, WIWmo468047, WIWmo468048, WIWmo468050, WIWmo468051, WIWmo468052, WIWmo468053, WIWmo468054, WIWmo468055, WIWmo468056, WIWmo468057, WIWmo468058, WIWmo468060, WIWmo468061, WIWmo468062, WIWmo468063, WIWmo468064, WIWmo468065, WIWmo468066, WIWmo468067, WIWmo468068, WIWmo468070, WIWmo468071, WIWmo468072, WIWmo468073, WIWmo468074, WIWmo468075, WIWmo468076, WIWmo468077, WIWmo468078, WIWmo468080, WIWmo468081, WIWmo468082, WIWmo468083, WIWmo468084, WIWmo468085, WIWmo468086, WIWmo468087, WIWmo468089, WIWmo468090, WIWmo468091, WIWmo468092, WIWmo468093, WIWmo468094, WIWmo468095, WIWmo468096, WIWmo468099, WIOwm200, WIOwm201, WIOwm202, WIOwm210, WIOwm211, WIOwm212, WIOwm221, WIOwm230, WIOwm231, WIOwm232, WIOwm300, WIOwm301, WIOwm302, WIOwm310, WIOwm311, WIOwm312, WIOwm313, WIOwm314, WIOwm321, WIOwm500, WIOwm501, WIOwm502, WIOwm503, WIOwm504, WIOwm511, WIOwm520, WIOwm521, WIOwm522, WIOwm531, WIOwm600, WIOwm601, WIOwm602, WIOwm611, WIOwm612, WIOwm615, WIOwm616, WIOwm620, WIOwm621, WIOwm622, WIOwm701, WIOwm711, WIOwm721, WIOwm731, WIOwm741, WIOwm761, WIOwm762, WIOwm771, WIOwm781, WIOwm800, WIOwm801, WIOwm802, WIOwm803, WIOwm804, WIOwm900, WIOwm901, WIOwm902, WIOwm903, WIOwm904, WIOwm905, WIOwm906, WIOwm957, WIOwmDay200, WIOwmDay201, WIOwmDay202, WIOwmDay210, WIOwmDay211, WIOwmDay212, WIOwmDay221, WIOwmDay230, WIOwmDay231, WIOwmDay232, WIOwmDay300, WIOwmDay301, WIOwmDay302, WIOwmDay310, WIOwmDay311, WIOwmDay312, WIOwmDay313, WIOwmDay314, WIOwmDay321, WIOwmDay500, WIOwmDay501, WIOwmDay502, WIOwmDay503, WIOwmDay504, WIOwmDay511, WIOwmDay520, WIOwmDay521, WIOwmDay522, WIOwmDay531, WIOwmDay600, WIOwmDay601, WIOwmDay602, WIOwmDay611, WIOwmDay612, WIOwmDay615, WIOwmDay616, WIOwmDay620, WIOwmDay621, WIOwmDay622, WIOwmDay701, WIOwmDay711, WIOwmDay721, WIOwmDay731, WIOwmDay741, WIOwmDay761, WIOwmDay762, WIOwmDay771, WIOwmDay781, WIOwmDay800, WIOwmDay801, WIOwmDay802, WIOwmDay803, WIOwmDay804, WIOwmDay900, WIOwmDay901, WIOwmDay902, WIOwmDay903, WIOwmDay904, WIOwmDay905, WIOwmDay906, WIOwmDay957, WIOwmNight200, WIOwmNight201, WIOwmNight202, WIOwmNight210, WIOwmNight211, WIOwmNight212, WIOwmNight221, WIOwmNight230, WIOwmNight231, WIOwmNight232, WIOwmNight300, WIOwmNight301, WIOwmNight302, WIOwmNight310, WIOwmNight311, WIOwmNight312, WIOwmNight313, WIOwmNight314, WIOwmNight321, WIOwmNight500, WIOwmNight501, WIOwmNight502, WIOwmNight503, WIOwmNight504, WIOwmNight511, WIOwmNight520, WIOwmNight521, WIOwmNight522, WIOwmNight531, WIOwmNight600, WIOwmNight601, WIOwmNight602, WIOwmNight611, WIOwmNight612, WIOwmNight615, WIOwmNight616, WIOwmNight620, WIOwmNight621, WIOwmNight622, WIOwmNight701, WIOwmNight711, WIOwmNight721, WIOwmNight731, WIOwmNight741, WIOwmNight761, WIOwmNight762, WIOwmNight771, WIOwmNight781, WIOwmNight800, WIOwmNight801, WIOwmNight802, WIOwmNight803, WIOwmNight804, WIOwmNight900, WIOwmNight901, WIOwmNight902, WIOwmNight903, WIOwmNight904, WIOwmNight905, WIOwmNight906, WIOwmNight957, WIWuChanceflurries, WIWuChancerain, WIWuChancesleat, WIWuChancesnow, WIWuChancetstorms, WIWuClear, WIWuCloudy, WIWuFlurries, WIWuHazy, WIWuMostlycloudy, WIWuMostlysunny, WIWuPartlycloudy, WIWuPartlysunny, WIWuRain, WIWuSleat, WIWuSnow, WIWuSunny, WIWuTstorms, WIWuUnknown
}

private let WIIcons = ["\u{f00d}", "\u{f002}", "\u{f000}", "\u{f001}", "\u{f003}", "\u{f004}", "\u{f0b6}", "\u{f005}", "\u{f008}", "\u{f006}", "\u{f007}", "\u{f009}", "\u{f0b2}", "\u{f068}", "\u{f00a}", "\u{f06b}", "\u{f065}", "\u{f00b}", "\u{f00e}", "\u{f00c}", "\u{f010}", "\u{f085}", "\u{f06e}", "\u{f072}", "\u{f07d}", "\u{f0c4}", "\u{f02e}", "\u{f086}", "\u{f022}", "\u{f023}", "\u{f024}", "\u{f025}", "\u{f028}", "\u{f026}", "\u{f027}", "\u{f029}", "\u{f0b4}", "\u{f06a}", "\u{f02a}", "\u{f06d}", "\u{f067}", "\u{f02b}", "\u{f02c}", "\u{f02d}", "\u{f031}", "\u{f02f}", "\u{f030}", "\u{f04a}", "\u{f032}", "\u{f033}", "\u{f083}", "\u{f036}", "\u{f034}", "\u{f035}", "\u{f037}", "\u{f0b3}", "\u{f069}", "\u{f038}", "\u{f06c}", "\u{f066}", "\u{f039}", "\u{f03a}", "\u{f03b}", "\u{f070}", "\u{f077}", "\u{f01d}", "\u{f01e}", "\u{f07e}", "\u{f080}", "\u{f081}", "\u{f041}", "\u{f013}", "\u{f011}", "\u{f012}", "\u{f014}", "\u{f015}", "\u{f019}", "\u{f017}", "\u{f018}", "\u{f01a}", "\u{f0b5}", "\u{f01b}", "\u{f01c}", "\u{f064}", "\u{f074}", "\u{f062}", "\u{f016}", "\u{f04e}", "\u{f078}", "\u{f063}", "\u{f076}", "\u{f021}", "\u{f050}", "\u{f082}", "\u{f0c6}", "\u{f0c7}", "\u{f07c}", "\u{f071}", "\u{f0c5}", "\u{f0c8}", "\u{f073}", "\u{f056}", "\u{f0cc}", "\u{f0cd}", "\u{f0ce}", "\u{f0cf}", "\u{f0b1}", "\u{f075}", "\u{f03c}", "\u{f045}", "\u{f042}", "\u{f055}", "\u{f053}", "\u{f054}", "\u{f03d}", "\u{f040}", "\u{f03e}", "\u{f047}", "\u{f046}", "\u{f051}", "\u{f052}", "\u{f0c9}", "\u{f0ca}", "\u{f04c}", "\u{f04b}", "\u{f084}", "\u{f079}", "\u{f07a}", "\u{f07b}", "\u{f0cb}", "\u{f095}", "\u{f096}", "\u{f097}", "\u{f098}", "\u{f099}", "\u{f09a}", "\u{f09b}", "\u{f09c}", "\u{f09d}", "\u{f09e}", "\u{f09f}", "\u{f0a0}", "\u{f0a1}", "\u{f0a2}", "\u{f0a3}", "\u{f0a4}", "\u{f0a5}", "\u{f0a6}", "\u{f0a7}", "\u{f0a8}", "\u{f0a9}", "\u{f0aa}", "\u{f0ab}", "\u{f0ac}", "\u{f0ad}", "\u{f0ae}", "\u{f0af}", "\u{f0b0}", "\u{f0eb}", "\u{f0d0}", "\u{f0d1}", "\u{f0d2}", "\u{f0d3}", "\u{f0d4}", "\u{f0d5}", "\u{f0d6}", "\u{f0d7}", "\u{f0d8}", "\u{f0d9}", "\u{f0da}", "\u{f0db}", "\u{f0dc}", "\u{f0dd}", "\u{f0de}", "\u{f0df}", "\u{f0e0}", "\u{f0e1}", "\u{f0e2}", "\u{f0e3}", "\u{f0e4}", "\u{f0e5}", "\u{f0e6}", "\u{f0e7}", "\u{f0e8}", "\u{f0e9}", "\u{f0ea}", "\u{f095}", "\u{f096}", "\u{f097}", "\u{f098}", "\u{f099}", "\u{f09a}", "\u{f09b}", "\u{f09c}", "\u{f09d}", "\u{f09e}", "\u{f09f}", "\u{f0a0}", "\u{f0a1}", "\u{f0a2}", "\u{f0a3}", "\u{f0a4}", "\u{f0a5}", "\u{f0a6}", "\u{f0a7}", "\u{f0a8}", "\u{f0a9}", "\u{f0aa}", "\u{f0ab}", "\u{f0ac}", "\u{f0ad}", "\u{f0ae}", "\u{f0af}", "\u{f0b0}", "\u{f08a}", "\u{f08b}", "\u{f08c}", "\u{f08d}", "\u{f08e}", "\u{f08f}", "\u{f090}", "\u{f091}", "\u{f092}", "\u{f093}", "\u{f094}", "\u{f089}", "\u{f058}", "\u{f057}", "\u{f04d}", "\u{f088}", "\u{f044}", "\u{f043}", "\u{f048}", "\u{f087}", "\u{f0b7}", "\u{f0b8}", "\u{f0b9}", "\u{f0ba}", "\u{f0bb}", "\u{f0bc}", "\u{f0bd}", "\u{f0be}", "\u{f0bf}", "\u{f0c0}", "\u{f0c1}", "\u{f0c2}", "\u{f0c3}", "\u{f056}", "\u{f00e}", "\u{f073}", "\u{f01e}", "\u{f01e}", "\u{f017}", "\u{f017}", "\u{f017}", "\u{f015}", "\u{f01a}", "\u{f015}", "\u{f01a}", "\u{f01a}", "\u{f01b}", "\u{f00a}", "\u{f064}", "\u{f01b}", "\u{f015}", "\u{f017}", "\u{f063}", "\u{f014}", "\u{f021}", "\u{f062}", "\u{f050}", "\u{f050}", "\u{f076}", "\u{f013}", "\u{f031}", "\u{f002}", "\u{f031}", "\u{f002}", "\u{f02e}", "\u{f00d}", "\u{f083}", "\u{f00c}", "\u{f017}", "\u{f072}", "\u{f00e}", "\u{f00e}", "\u{f00e}", "\u{f01a}", "\u{f064}", "\u{f01b}", "\u{f064}", "\u{f00c}", "\u{f00e}", "\u{f01b}", "\u{f00e}", "\u{f077}", "\u{f00d}", "\u{f02e}", "\u{f019}", "\u{f01b}", "\u{f0b5}", "\u{f050}", "\u{f014}", "\u{f013}", "\u{f002}", "\u{f031}", "\u{f015}", "\u{f01e}", "\u{f056}", "\u{f055}", "\u{f055}", "\u{f013}", "\u{f013}", "\u{f055}", "\u{f055}", "\u{f013}", "\u{f013}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f016}", "\u{f050}", "\u{f014}", "\u{f017}", "\u{f017}", "\u{f019}", "\u{f01b}", "\u{f015}", "\u{f01e}", "\u{f063}", "\u{f063}", "\u{f063}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f014}", "\u{f017}", "\u{f01c}", "\u{f019}", "\u{f01c}", "\u{f019}", "\u{f015}", "\u{f015}", "\u{f01b}", "\u{f01b}", "\u{f01c}", "\u{f01c}", "\u{f019}", "\u{f019}", "\u{f076}", "\u{f076}", "\u{f076}", "\u{f01c}", "\u{f019}", "\u{f01c}", "\u{f01c}", "\u{f019}", "\u{f019}", "\u{f015}", "\u{f015}", "\u{f015}", "\u{f017}", "\u{f017}", "\u{f01b}", "\u{f01b}", "\u{f01b}", "\u{f01b}", "\u{f076}", "\u{f076}", "\u{f076}", "\u{f01b}", "\u{f076}", "\u{f019}", "\u{f01c}", "\u{f019}", "\u{f019}", "\u{f01d}", "\u{f017}", "\u{f017}", "\u{f017}", "\u{f015}", "\u{f016}", "\u{f01d}", "\u{f01e}", "\u{f01e}", "\u{f016}", "\u{f01e}", "\u{f01e}", "\u{f056}", "\u{f01e}", "\u{f01e}", "\u{f01e}", "\u{f016}", "\u{f016}", "\u{f016}", "\u{f016}", "\u{f01e}", "\u{f01e}", "\u{f01e}", "\u{f01c}", "\u{f01c}", "\u{f019}", "\u{f017}", "\u{f019}", "\u{f019}", "\u{f01a}", "\u{f019}", "\u{f01c}", "\u{f01c}", "\u{f019}", "\u{f019}", "\u{f019}", "\u{f019}", "\u{f017}", "\u{f01a}", "\u{f01a}", "\u{f01a}", "\u{f01d}", "\u{f01b}", "\u{f01b}", "\u{f0b5}", "\u{f017}", "\u{f017}", "\u{f017}", "\u{f017}", "\u{f017}", "\u{f01b}", "\u{f01b}", "\u{f01a}", "\u{f062}", "\u{f0b6}", "\u{f063}", "\u{f014}", "\u{f063}", "\u{f063}", "\u{f011}", "\u{f056}", "\u{f00d}", "\u{f011}", "\u{f011}", "\u{f012}", "\u{f013}", "\u{f056}", "\u{f01d}", "\u{f073}", "\u{f076}", "\u{f072}", "\u{f021}", "\u{f015}", "\u{f050}", "\u{f010}", "\u{f010}", "\u{f010}", "\u{f005}", "\u{f005}", "\u{f005}", "\u{f005}", "\u{f010}", "\u{f010}", "\u{f010}", "\u{f00b}", "\u{f00b}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f00b}", "\u{f00b}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f008}", "\u{f006}", "\u{f009}", "\u{f009}", "\u{f009}", "\u{f00e}", "\u{f00a}", "\u{f0b2}", "\u{f00a}", "\u{f006}", "\u{f006}", "\u{f006}", "\u{f006}", "\u{f006}", "\u{f00a}", "\u{f00a}", "\u{f009}", "\u{f062}", "\u{f0b6}", "\u{f063}", "\u{f003}", "\u{f063}", "\u{f063}", "\u{f000}", "\u{f056}", "\u{f00d}", "\u{f000}", "\u{f000}", "\u{f000}", "\u{f00c}", "\u{f056}", "\u{f00e}", "\u{f073}", "\u{f076}", "\u{f072}", "\u{f0c4}", "\u{f004}", "\u{f050}", "\u{f02d}", "\u{f02d}", "\u{f02d}", "\u{f025}", "\u{f025}", "\u{f025}", "\u{f025}", "\u{f02d}", "\u{f02d}", "\u{f02d}", "\u{f02b}", "\u{f02b}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f02b}", "\u{f02b}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f028}", "\u{f026}", "\u{f029}", "\u{f029}", "\u{f029}", "\u{f02c}", "\u{f02a}", "\u{f0b4}", "\u{f02a}", "\u{f026}", "\u{f026}", "\u{f026}", "\u{f026}", "\u{f026}", "\u{f02a}", "\u{f02a}", "\u{f029}", "\u{f062}", "\u{f0b6}", "\u{f063}", "\u{f04a}", "\u{f063}", "\u{f063}", "\u{f022}", "\u{f056}", "\u{f02e}", "\u{f022}", "\u{f022}", "\u{f022}", "\u{f086}", "\u{f056}", "\u{f03a}", "\u{f073}", "\u{f076}", "\u{f072}", "\u{f021}", "\u{f024}", "\u{f050}", "\u{f064}", "\u{f019}", "\u{f0b5}", "\u{f01b}", "\u{f01e}", "\u{f00d}", "\u{f002}", "\u{f064}", "\u{f0b6}", "\u{f002}", "\u{f00d}", "\u{f002}", "\u{f00d}", "\u{f01a}", "\u{f0b5}", "\u{f01b}", "\u{f00d}", "\u{f01e}", "\u{f00d}"]