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
	
	@IBOutlet weak var mapView: MKMapView! {
		didSet { mapView.delegate = self }
	}
	
	private let locationManager = CLLocationManager()
	private let regionInMeters = Double(10000)
	
	// MARK:- View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		checkLocationServices()
	}

}

// MARK:- MapView Delegate

extension MapViewController: MKMapViewDelegate {
	
	
}

// MARK:- LocationManager Delegate

extension MapViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		centerMapViewOn(location: location.coordinate)

	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	
}

// MARK:- Helper Functions

extension MapViewController {
	
	private func checkLocationServices() {
		// Check whether location services are enabled or not
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			// Check whether location services are enabled for the app or not
			checkLocationAuthorization()
		} else {
			#warning("TODO: Alert the user")
		}
	}
	
	private func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	private func checkLocationAuthorization() {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .authorizedWhenInUse:
			print("Authorized When in Use")
			// Show user's location on map
			mapView.showsUserLocation = true
			centerMapViewOn(location: locationManager.location?.coordinate)
			// Update user's location on map
			locationManager.startUpdatingLocation()
		case .authorizedAlways:
			break
		case .restricted:
			break
		case .denied:
			break
		@unknown default:
			break
		}
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

