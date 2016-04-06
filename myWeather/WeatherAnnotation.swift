//
//  WeatherAnnotation.swift
//  myWeather
//
//  Created by sgreiff on 4/6/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import Foundation
import MapKit

class WeatherAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: WIType

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: WIType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}