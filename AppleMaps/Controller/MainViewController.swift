//
//  MainViewController.swift
//  AppleMaps
//
//  Created by Mustafa on 8/2/20.
//  Copyright © 2020 Mustafa Nafie. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
	
	// MARK:- Outlets and Properties

	private let locationManager = CLLocationManager()

	// MARK:- View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLocationManager()
    }

}


// MARK:- LocationManager Delegate

extension MainViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	
}

// MARK:- Helper Functions

extension MainViewController {
	
	private func setupLocationManager() {
		locationManager.delegate = self
		checkLocationServices()
	}
	
	private func checkLocationServices() {
		// Check whether location services are enabled for the device or not
		if CLLocationManager.locationServicesEnabled() {
			// Check whether location services are enabled for the app or not
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
			// Enable Buttons
			break
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
	
}
