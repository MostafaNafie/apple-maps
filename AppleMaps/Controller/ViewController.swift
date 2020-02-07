//
//  ViewController.swift
//  AppleMaps
//
//  Created by Mustafa on 7/2/20.
//  Copyright © 2020 Mustafa Nafie. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView! {
		didSet { mapView.delegate = self }
	}
	
	private let locationManager = CLLocationManager()
	private let regionInMeters = Double(10000)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		checkLocationServices()
	}


}

extension ViewController: MKMapViewDelegate {
	
}

extension ViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		let center = location.coordinate
		let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	
}

extension ViewController {
	
	private func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	private func checkLocationServices() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			checkLocationAuthorization()
		} else {
			#warning("TODO: Alert the user")
		}
	}
	
	private func checkLocationAuthorization() {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .authorizedWhenInUse:
			print("Authorized When in Use")
			mapView.showsUserLocation = true
			centerViewonUserLocation()
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
	
	private func centerViewonUserLocation() {
		if let location = locationManager.location?.coordinate {
			let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
			mapView.setRegion(region, animated: true)
		}
	}
	
}

