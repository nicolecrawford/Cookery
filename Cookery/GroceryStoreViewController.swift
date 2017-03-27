//
//  GroceryStoreViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/18/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//
// based off of https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial

import MapKit
import UIKit

class GroceryStoreViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // Public API
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    
    @IBAction func getDirections(_ sender: UIBarButtonItem) {
        let placemark = MKPlacemark(coordinate: storeCoordinates!)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Grocery Store"
        mapItem.openInMaps()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        if UserDefaults.standard.bool(forKey: "groceryStore") {
            let latitude = UserDefaults.standard.double(forKey: "groceryStore-lat")
            let longitude = UserDefaults.standard.double(forKey: "groceryStore-long")
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            storeCoordinates = coordinates
            mapView.centerCoordinate = coordinates
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(region, animated: true)
        }
        if storeCoordinates == nil { directionsButton.isEnabled = false }
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if response == nil {
                return
            }
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: response!.boundingRegion.center.latitude, longitude: response!.boundingRegion.center.longitude)
            self?.storeCoordinates = pointAnnotation.coordinate
            self?.directionsButton.isEnabled = true
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self?.mapView.centerCoordinate = pointAnnotation.coordinate
            self?.mapView.addAnnotation(pinAnnotationView.annotation!)
            
            UserDefaults.standard.setValue(true, forKey: "groceryStore")
            UserDefaults.standard.setValue(pointAnnotation.coordinate.latitude, forKey: "groceryStore-lat")
            UserDefaults.standard.setValue(pointAnnotation.coordinate.longitude, forKey: "groceryStore-long")
            UserDefaults.standard.synchronize()
            let region = CLCircularRegion(center: pointAnnotation.coordinate, radius: self!.regionRadius, identifier: pointAnnotation.title!)
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotification(in: region)
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private let regionRadius: CLLocationDistance = 1000 // 1km
    
    private var storeCoordinates: CLLocationCoordinate2D?

}
