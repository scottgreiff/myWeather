//
//  ViewController.swift
//  myWeather
//
//  Created by Scott Alan Greiff on 4/3/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SGWeatherKit
import JSQCoreDataKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var forecastDateLabel: UILabel!
    @IBOutlet weak var conditionsIconLabel: UILabel!
    @IBOutlet weak var conditionsNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!

    var stack: CoreDataStack!
    var locManager : CLLocationManager = CLLocationManager()
    let weatherAgent: WeatherKitAgent = WeatherKitAgent(apiKey: "195ca018929c41a89f286e0910a5da77")

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)

        factory.createStackInBackground { (result: StackResult) in
            switch result {
            case .success(let s):
                self.stack = s
            case .failure(let e):
                print("Error: \(e)")
            }
        }
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.mapType = .Standard
        self.mapView.zoomEnabled = true
        self.mapView.scrollEnabled = true
        
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
        self.cityNameLabel.text = ""
        self.currentTempLabel.text = ""
        self.highTempLabel.text = ""
        self.lowTempLabel.text = ""
        self.forecastDateLabel.text = ""
        self.conditionsNameLabel.text = ""
    }
    
    func requestLocationAccess() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .Authorized:
                createLocationManager(true)
            case .AuthorizedWhenInUse:
                createLocationManager(true)
            case .Denied:
                displayAlertWithTitle("Denied",
                                      message: "Location services are not allowed for this app")
            case .NotDetermined:
                createLocationManager(false)
                locManager.requestWhenInUseAuthorization()
            case .Restricted:
                displayAlertWithTitle("Restricted",
                                      message: "Location services are not allowed for this app")
            }
        }
    }
    
    func createLocationManager(startImmediately: Bool) {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locManager.distanceFilter = kCLDistanceFilterNone
        
        CLLocationManager.locationServicesEnabled()
        
        if startImmediately{
//            locManager.startUpdatingLocation()
        }
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = mapView.centerCoordinate
        self.weatherAgent.currentWeather(location) { result in
            self.updateWeatherInfo(result)
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
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
                
                self.currentTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp)!+"°"
                self.highTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp_max)!+"°"
                self.lowTempLabel.text = numberFormatter.stringFromNumber(weatherListItem.environment.temp_min)!+"°"
                self.forecastDateLabel.text = "Forecast date: \(dateFormatter.stringFromDate(weatherListItem.forecastDate))"
                self.conditionsNameLabel.text = weatherListItem.weather.description
                self.conditionsIconLabel.WIIcon = WeatherIconUtility.WITypeLookupByWeatherId(weatherListItem.weather.id, isDay: nowIsDay)
            }
        } else {
            self.cityNameLabel.text = ""
            self.currentTempLabel.text = ""
            self.highTempLabel.text = ""
            self.lowTempLabel.text = ""
            self.forecastDateLabel.text = ""
            self.conditionsNameLabel.text = ""
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        print("The authorization status of location services is changed to: ")
        
        switch CLLocationManager.authorizationStatus() {
        case .Authorized:
            createLocationManager(true)
        case .AuthorizedWhenInUse:
            createLocationManager(true)
        case .Denied:
            displayAlertWithTitle("Denied",
                                  message: "Location services are not allowed for this app")
        case .NotDetermined:
            createLocationManager(false)
            locManager.requestWhenInUseAuthorization()
        case .Restricted:
            displayAlertWithTitle("Restricted",
                                  message: "Location services are not allowed for this app")
        }
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateToLocation newLocation: CLLocation,
                                             fromLocation oldLocation: CLLocation){
        
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
}
