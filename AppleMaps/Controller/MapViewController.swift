//
//  MapViewController.swift
//  AppleMaps
//
//  Created by Mustafa on 7/2/20.
//  Copyright © 2020 Mustafa Nafie. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

	// MARK:- Outlets and Properties
	
	@IBOutlet weak var mapView: MKMapView!
	
	private let locationManager = CLLocationManager()
	private let regionInMeters = Double(10000)
	
	// MARK:- View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupLocationManager()
	}

}

// MARK:- LocationManager Delegate

extension MapViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		centerMapViewOn(location: location.coordinate)
	}
	
}

// MARK:- Helper Functions

extension MapViewController {
	
	private func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		startTrackingUserLocation()
	}
	
	private func startTrackingUserLocation() {
		// Show user's location on map
		mapView.showsUserLocation = true
		centerMapViewOn(location: locationManager.location?.coordinate)
		// Update user's location on map
		locationManager.startUpdatingLocation()
	}
	
	private func centerMapViewOn(location: CLLocationCoordinate2D?) {
		if let location = location {
			let region = MKCoordinateRegion(center: location,
											latitudinalMeters: regionInMeters,
											longitudinalMeters: regionInMeters)
			mapView.setRegion(region, animated: true)
		}
	}
	
}

