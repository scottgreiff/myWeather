//
//  WeatherViewController.swift
//  myWeather
//
//  Created by Scott Alan Greiff on 4/3/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SGWeatherKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var forecastDateLabel: UILabel!
    @IBOutlet weak var conditionsIconLabel: UILabel!
    @IBOutlet weak var conditionsNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var conditionWeatherLabel: UILabel!
    @IBOutlet weak var highTempTitleLabel: UILabel!
    @IBOutlet weak var lowTempTitleLabel: UILabel!
    
    @IBOutlet weak var dayOneTitleLabel: UILabel!
    @IBOutlet weak var dayOneConditionLabel: UILabel!
    @IBOutlet weak var dayTwoTitleLabel: UILabel!
    @IBOutlet weak var dayTwoConditionLabel: UILabel!
    @IBOutlet weak var dayThreeTitleLabel: UILabel!
    @IBOutlet weak var dayThreeConditionLabel: UILabel!
    

    var locManager: CLLocationManager = CLLocationManager()
    let weatherAgent: WeatherKitAgent = WeatherKitAgent(apiKey: "195ca018929c41a89f286e0910a5da77")
    var haveNewUserLocation: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUI()
        self.requestLocationAccess()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initUI() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.mapType = .Standard
        self.mapView.zoomEnabled = true
        self.mapView.scrollEnabled = true

        self.clearLabelContents()

        self.mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.mapTapped(_:))))
    }

    func clearLabelContents() {
        self.cityNameLabel.text = ""
        self.currentTempLabel.text = ""
        self.highTempLabel.text = ""
        self.lowTempLabel.text = ""
        self.forecastDateLabel.text = ""
        self.conditionsNameLabel.text = ""
        self.conditionWeatherLabel.text = ""
        self.highTempTitleLabel.text = ""
        self.lowTempTitleLabel.text = ""
        self.dayOneTitleLabel.text = ""
        self.dayOneConditionLabel.text = ""
        self.dayTwoTitleLabel.text = ""
        self.dayTwoConditionLabel.text = ""
        self.dayThreeTitleLabel.text = ""
        self.dayThreeConditionLabel.text = ""
    }

    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title,
                message: message,
                preferredStyle: .Alert)

        controller.addAction(UIAlertAction(title: "OK",
                style: .Default,
                handler: nil))

        self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension WeatherViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = mapView.centerCoordinate
        if (haveNewUserLocation) {
            self.weatherAgent.currentWeather(location) {
                result in
                mapView.removeAnnotations(mapView.annotations)
                self.updateWeatherInfo(result)
            }

            haveNewUserLocation = false
        }
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        if (mapView.showsUserLocation) {
            haveNewUserLocation = true
            mapView.showsUserLocation = false
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is WeatherAnnotation {
            let annotationView = WeatherAnnotationView(annotation: annotation, reuseIdentifier: "Weather")
            annotationView.canShowCallout = true
            return annotationView
        }

        return nil
    }

    func mapTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.locationInView(self.mapView);
        if let map = self.mapView {
            let coord = map.convertPoint(point, toCoordinateFromView: map)

            self.weatherAgent.currentWeather(coord) {
                result in
                map.removeAnnotations(map.annotations)
                self.updateWeatherInfo(result)
            }
        }
    }

    func updateWeatherInfo(result: WeatherKitAgent.Result) {
        if let error = result.error() {
            displayAlertWithTitle("Weather Error",
                    message: "Error fetching weather forecasts: \(error.localizedDescription)")
            return
        }

        if let city = result.data() {
            if let weatherListItem: WeatherListItem = city.weatherList!.first {
                self.cityNameLabel.text = city.name

                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .NoStyle

                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .ShortStyle

                var nowIsDay = true

                if let sunriseTime = weatherListItem.sunrise_time {
                    if let sunsetTime = weatherListItem.sunset_time {
                        nowIsDay = weatherListItem.forecastDate.isGreaterThanDate(sunriseTime) && weatherListItem.forecastDate.isLessThanDate(sunsetTime)
                    }
                }

                self.highTempTitleLabel.text = "Hi:"
                self.lowTempTitleLabel.text = "Low:"

                self.currentTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp)! + "°"
                self.highTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp_max)! + "°"
                self.lowTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp_min)! + "°"
                self.forecastDateLabel.text = "Forecast date: \(dateFormatter.stringFromDate(weatherListItem.forecastDate))"
                self.conditionsNameLabel.text = weatherListItem.weather.description
                let wiType = WeatherIconUtility.WITypeLookupByWeatherId(weatherListItem.weather.id, isDay: nowIsDay)
                self.conditionsIconLabel.WIIcon = wiType
                self.addMapAnnotations(city, conditions: weatherListItem.weather.main, type: wiType, isDay: nowIsDay)
                
                self.fetchExtendedForecast(city.lat, lon: city.lon)
            }
        } else {
            self.clearLabelContents()
        }
    }
    
    func fetchExtendedForecast(lat: Double, lon: Double) {
        self.weatherAgent.dailyForecast(CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
            result in
            
            if let city = result.data() {
                if city.weatherList?.count < 7 {
                    return
                }
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.doesRelativeDateFormatting = true
                
                let dayOneItem: WeatherListItem = city.weatherList![1]
                let dayTwoItem: WeatherListItem = city.weatherList![2]
                let dayThreeItem: WeatherListItem = city.weatherList![3]

                self.dayOneTitleLabel.text = "\(dateFormatter.stringFromDate(dayOneItem.forecastDate))"
                self.dayOneConditionLabel.WIIcon = WeatherIconUtility.WITypeLookupByWeatherId(dayOneItem.weather.id, isDay: true)
                self.dayTwoTitleLabel.text = "\(dateFormatter.stringFromDate(dayTwoItem.forecastDate))"
                self.dayTwoConditionLabel.WIIcon = WeatherIconUtility.WITypeLookupByWeatherId(dayTwoItem.weather.id, isDay: true)
                self.dayThreeTitleLabel.text = "\(dateFormatter.stringFromDate(dayThreeItem.forecastDate))"
                self.dayThreeConditionLabel.WIIcon = WeatherIconUtility.WITypeLookupByWeatherId(dayThreeItem.weather.id, isDay: true)
            }
        }
    }

    func addMapAnnotations(city: City, conditions: String, type: WIType, isDay: Bool) {
        if let _ = city.lat {
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(city.lat), CLLocationDegrees(city.lon))
            let annotation = WeatherAnnotation(coordinate: coordinate, title: city.name, subtitle: conditions, type: type)
            mapView.addAnnotation(annotation)

            // move map to center on annotation, but maintain current map zoom scale
            let span = mapView.region.span
            let center = mapView.region.center

            let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
            let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
            let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
            let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)

            let metersInLatitude = loc1.distanceFromLocation(loc2)
            let metersInLongitude = loc3.distanceFromLocation(loc4)

            let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersInLatitude, metersInLongitude)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed with error = \(error)")
    }

    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("The authorization status of location services is changed to: \(status.rawValue)")

        self.requestLocationAccess()
    }

    func locationManager(manager: CLLocationManager,
                         didUpdateToLocation newLocation: CLLocation,
                         fromLocation oldLocation: CLLocation) {

        print("Latitude = \(newLocation.coordinate.latitude)")
        print("Longitude = \(newLocation.coordinate.longitude)")
    }

    func requestWhenInUseAuthorization() {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()

        if status == .AuthorizedWhenInUse || status == .Denied {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func requestLocationAccess() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .Authorized:
                createLocationManager()
            case .AuthorizedWhenInUse:
                createLocationManager()
            case .Denied:
                displayAlertWithTitle("Denied",
                        message: "Location services are not allowed for this app")
            case .NotDetermined:
                createLocationManager()
                locManager.requestWhenInUseAuthorization()
            case .Restricted:
                displayAlertWithTitle("Restricted",
                        message: "Location services are not allowed for this app")
            }
        }
    }

    func createLocationManager() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locManager.distanceFilter = kCLDistanceFilterNone

        CLLocationManager.locationServicesEnabled()
    }
}
