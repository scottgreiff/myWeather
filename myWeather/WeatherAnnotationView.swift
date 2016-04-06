//
//  WeatherAnnotationView.swift
//  myWeather
//
//  Created by sgreiff on 4/6/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import Foundation
import MapKit

public class WeatherAnnotationView: MKAnnotationView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let weatherAnnotation = self.annotation as! WeatherAnnotation
        image = UIImage(icon: weatherAnnotation.type, size: CGSize(width: 40, height: 40), textColor: self.tintColor, backgroundColor: UIColor.init(white: 1.0, alpha: 0.5))
    }
}