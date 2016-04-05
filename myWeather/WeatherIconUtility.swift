//
//  WeatherIconUtility.swift
//  myWeather
//
//  Created by sgreiff on 4/5/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import Foundation

public class WeatherIconUtility {
    class func WITypeLookupByWeatherId(weatherId: Int, isDay: Bool) -> WIType {
        var result = WIType.WINa
        
        switch weatherId {
        case 200, 201, 202, 210, 211, 212, 221:
            isDay == true ? (result = WIType.WIDayThunderstorm) : (result = WIType.WINightThunderstorm)
        case 230, 231, 232, 901:
            isDay == true ? (result = WIType.WIDayStormShowers) : (result = WIType.WINightStormShowers)
        case 300, 301, 302, 310, 311, 312, 313, 314, 321, 621, 622:
            isDay == true ? (result = WIType.WIDayShowers) : (result = WIType.WINightShowers)
            result = WIType.WIDayShowers
        case 500, 501, 502, 503, 504, 511, 520, 521, 522, 531:
            isDay == true ? (result = WIType.WIDayRain) : (result = WIType.WINightRain)
        case 600, 601, 602, 611, 612:
            isDay == true ? (result = WIType.WIDaySnow) : (result = WIType.WINightSnow)
        case 615, 616, 620, 611, 612:
            isDay == true ? (result = WIType.WIDayRainMix) : (result = WIType.WINightRainMix)
        case 701,721, 741:
            isDay == true ? (result = WIType.WIDayFog) : (result = WIType.WINightFog)
        case 800, 951:
            isDay == true ? (result = WIType.WIDaySunny) : (result = WIType.WINightClear)
        case 801, 802, 803, 804:
            isDay == true ? (result = WIType.WIDayCloudy) : (result = WIType.WINightCloudy)
        case 906:
            isDay == true ? (result = WIType.WIDayHail) : (result = WIType.WINightHail)
            result = WIType.WIDayHail
        case 906:
            isDay == true ? (result = WIType.WIDayCloudyWindy) : (result = WIType.WINightCloudyWindy)
        default:
            result = WIType.WINa
        }
        
        return result
    }
}


extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false

        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }

        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false

        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }
}