//
//  FirstViewController.swift
//  rutgersMap
//
//  Created by Wahhaj Zahedi on 9/27/18.
//  Copyright © 2018 Wahhaj Zahedi. All rights reserved.
//

import UIKit
import GoogleMaps

class FirstViewController: UIViewController, GMSMapViewDelegate, XMLParserDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: GMSMapView!
    var parser = XMLParser()
    var refreshTimer = Timer()
    var busDict = [String:Bus]()
    var locationManager = CLLocationManager()
    var oldAnn = [Bus:CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
        refreshTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(runRefresh), userInfo: nil, repeats: true)
        // Initial Parse:
        let urlString = URL(string: "http://webservices.nextbus.com/service/publicXMLFeed?a=rutgers&command=vehicleLocations")
        self.parser = XMLParser(contentsOf: urlString!)!
        self.parser.delegate = self
        let success:Bool = self.parser.parse()
        if success {
            print("success")
            getLoc()
        } else {
            print("parse failure!")
        }
        // MAP STYLE:
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.view = mapView
        
    }
    func getLoc() {
        for bus in busDict {
            oldAnn.updateValue(bus.value.position, forKey: bus.value)
            for marker in oldAnn {
                marker.key.icon = UIImage(named: "image2.png")
                marker.key.isFlat = true
                marker.key.tracksInfoWindowChanges = true
                marker.key.rotation = CLLocationDegrees(bus.value.heading!)
                marker.key.map = mapView
            }
            mapView.delegate = self
        }
    }
    func updateLoc() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(6.0)
        for bus in self.busDict {
            for marker in self.oldAnn {
                if (marker.key is Bus) {
                    let yacAnn = marker.key as? Bus
                    if yacAnn?.snippet == bus.value.snippet {
                        yacAnn?.rotation = CLLocationDegrees(bus.value.heading!)
                        yacAnn?.position = bus.value.position
                        break
                    }
                }
            }
        }
        self.mapView.delegate = self
        CATransaction.commit()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 15);
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: REFRESH FUNCTION WHICH IS CALLED BY TIMER IN VIEW. RECALLS PARSE, UPDATE LOCATION FUNCTION
    @objc func runRefresh() {
        let urlString = URL(string: "http://webservices.nextbus.com/service/publicXMLFeed?a=rutgers&command=vehicleLocations")
        self.parser = XMLParser(contentsOf: urlString!)!
        self.parser.delegate = self
        
        let success:Bool = self.parser.parse()
        if success {
            updateLoc()
        } else {
            print("parse failure!")
        }
    }
    
    // MARK: PARSING FUNCTIONS ->
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if(elementName=="vehicle")
        {
            let bus = Bus()
            for string in attributeDict {
                let strvalue = string.value as NSString
                switch string.key {
                case "id":
                    bus.snippet = "ID: \(strvalue.integerValue)"
                    break
                case "routeTag":
                    bus.title = strvalue as String
                    break
                case "lat":
                    bus.position.latitude = strvalue.doubleValue
                    break
                case "lon":
                    bus.position.longitude = strvalue.doubleValue
                    break
                case "speedKmHr":
                    bus.speed = strvalue.integerValue
                    break
                case "heading":
                    bus.heading = strvalue.integerValue
                    break
                default:
                    break
                }
            }
            if let subtitle = bus.snippet {
                busDict.updateValue(bus, forKey: subtitle)
            }
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
}

// BUS CLASS INITIALIZES OBJECTS TO HOLD VALUES FROM PARSE DATA
class Bus: GMSMarker {
    var speed:Int?
    var heading:Int?
}
