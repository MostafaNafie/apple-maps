//
//  AddressViewController.swift
//  AppleMaps
//
//  Created by Mustafa on 7/2/20.
//  Copyright © 2020 Mustafa Nafie. All rights reserved.
//

import UIKit
import MapKit

class AddressViewController: UIViewController {

	// MARK:- Outlets and Properties
	
	@IBOutlet weak var mapView: MKMapView! {
		didSet { mapView.delegate = self }
	}
	@IBOutlet weak var addressLabel: UILabel!
	
	private let locationManager = CLLocationManager()
	private let regionInMeters: Double = 10000
	private var previousLocation: CLLocation?
	
	// MARK:- View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		checkLocationServices()
	}
	
}

// MARK:- LocationManager Delegate

extension AddressViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	
}

// MARK:- MapView Delegate

extension AddressViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let center = getCenterLocation(of: mapView)
		let geoCoder = CLGeocoder()
		guard previousLocation != nil else { return }
		
		// Call reverGocodeLocation only if the difference between the previous location and current location is greater than 50 meters
		guard center.distance(from: previousLocation!) > 50 else { return }
		previousLocation = center
		
		geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
			guard let self = self else { return }
			
			if let _ = error {
				#warning("Alert the user")
				return
			}
			
			guard let placemark = placemarks?.first else {
				#warning("Alert the user")
				return
			}
			
			let streetNumber = placemark.subThoroughfare ?? ""
			let streetName = placemark.thoroughfare ?? ""
			
			DispatchQueue.main.async {
				self.addressLabel.text = "\(streetNumber) \(streetName)"
			}
		}
	}
	
}

// MARK:- Helper Functions

extension AddressViewController {
	
	private func checkLocationServices() {
		// Check whether location services are enabled for the device or not
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
//			mapView.showsUserLocation = true
			centerMapViewOn(location: locationManager.location?.coordinate)
//			locationManager.startUpdatingLocation()
			// Get the initailLocation
			previousLocation = getCenterLocation(of: mapView)
		case .denied:
			#warning("TODO: Alert the user")
			break
		case .authorizedAlways:
			break
		case .restricted:
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
	
	private func getCenterLocation(of mapView: MKMapView) -> CLLocation {
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
}
