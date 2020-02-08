//
//  DirectionsViewController.swift
//  AppleMaps
//
//  Created by Mustafa on 8/2/20.
//  Copyright © 2020 Mustafa Nafie. All rights reserved.
//

import UIKit
import MapKit

class DirectionsViewController: UIViewController {
	
	// MARK:- Outlets and Properties
	
	@IBOutlet weak var mapView: MKMapView! {
		didSet { mapView.delegate = self }
	}
	@IBOutlet weak var addressLabel: UILabel!
	
	private let locationManager = CLLocationManager()
	private let regionInMeters: Double = 10000
	private var previousLocation: CLLocation?
	private var previousDirections: MKDirections?
	
	// MARK:- View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		checkLocationServices()
		setMapViewGestureRecognizer()
	}
	
	@IBAction func goButtonTapped(_ sender: Any) {
		getDirections()
	}
}

// MARK:- LocationManager Delegate

extension DirectionsViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	
}

// MARK:- MapView Delegate

extension DirectionsViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		getAddress()
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = .blue
		
		return renderer
	}
	
}

// MARK:- GestureRecognizer Delegate

extension DirectionsViewController: UIGestureRecognizerDelegate {
	
	func setMapViewGestureRecognizer(){
		let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
		gestureRecognizer.minimumPressDuration = 0.5
		gestureRecognizer.delaysTouchesBegan = true
		gestureRecognizer.delegate = self
		self.mapView.addGestureRecognizer(gestureRecognizer)
	}
	
	@objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
		if gestureReconizer.state != UIGestureRecognizer.State.ended {
			let touchLocation = gestureReconizer.location(in: mapView)
			let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
			centerMapViewOn(location: locationCoordinate)
			print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
			return
		}
		if gestureReconizer.state != UIGestureRecognizer.State.began {
			return
		}
	}
	
}

// MARK:- Helper Functions

extension DirectionsViewController {
	
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
			// Show user's location on map
			mapView.showsUserLocation = true
			centerMapViewOn(location: locationManager.location?.coordinate)
			// Get the initailn Location
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
	
	private func getAddress() {
		let center = getCenterLocation(of: mapView)
		let geoCoder = CLGeocoder()
		guard previousLocation != nil else { return }
		
		// Call reverGocodeLocation only if the difference between the previous location and current location is greater than 50 meters
		guard center.distance(from: previousLocation!) > 50 else { return }
		previousLocation = center
		
		geoCoder.reverseGeocodeLocation(center) { [unowned self] (placemarks, error) in
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
	
	private func getDirections() {
		guard let location = locationManager.location?.coordinate else {
			return
		}
		
		resetMapView()
		let request = createDirectionsRequest(from: location)
		let directions = MKDirections(request: request)
		previousDirections = directions
		
		directions.calculate { [unowned self] (response, error) in
			guard let response = response else { return }
			
			for route in response.routes {
				self.mapView.addOverlay(route.polyline)
				self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
			}
		}
	}
	
	private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
		let startingLocation = MKPlacemark(coordinate: coordinate)
		let destinationCoordinates = getCenterLocation(of: mapView).coordinate
		let destinationLocation = MKPlacemark(coordinate: destinationCoordinates)
		
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: startingLocation)
		request.destination = MKMapItem(placemark: destinationLocation)
		request.transportType = .automobile
		request.requestsAlternateRoutes = true
		
		return request
	}
	
	private func resetMapView() {
		// Remove the previously displayed directions on the map
		mapView.removeOverlays(mapView.overlays)
		// Cancel previous request if any
		previousDirections?.cancel()
	}
	
}
