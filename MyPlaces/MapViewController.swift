//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 5/31/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager() // менеджер который будет отслеживать местоположение пользователя
    let regionInMeters = 5_000.00
    var incomeSegueIdentifier = ""

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func centerViewInUserLocation() { // по нажатию на кнопку геолокации, центрируем карту
        
        showUserLocation()
    }
    @IBAction func doneButtonPressed() { // при нажатии done мы будем передавать в параметр метода getAddress текущее значение адреса, а потом закрывать VC
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func setupPlaceMark() { // устанавливаем месту отметку
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder() // преобразует адрес из location в  географические координаты и гео. названия
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation() // описываем точку на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() { // метод для проверки включенных на устройстве функций для нахождения геолокации
        
        if CLLocationManager.locationServicesEnabled() { // если геолокация доступна
            setupLocationManager()
            checkLocationAuthorization()
        } else { // Алерт контроллер для включения геолокации на устройстве
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location services are disabled", message: "To enable it Go to: Settings -> Privacy -> Location services and turn On")
            }
        }
    }
    
    private func setupLocationManager() { // устанавливаем местоположение
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // настраиваем точность определения местопололожения пользователя
    }
    
    private func checkLocationAuthorization() { // проверка статуса на разрешение использовать геопозицию
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // геолокация в момент использования
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied: // когда приложению отказано использовать службу геолокации
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not available", message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
            break
        case .notDetermined: // статус не определен, если пользователь не решил может ли использовать приложение локацию
            locationManager.requestWhenInUseAuthorization()
        case .restricted: // приложение не авторизовано для служб геолокаций
            break
        case .authorizedAlways: // авторизован всегда
            break
        @unknown default:
            print("New case is available ")
        }
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation { // метод для определения координат в центре отображаемой области карты под Pin
        let latitude = mapView.centerCoordinate.latitude // широта
        let longitude = mapView.centerCoordinate.longitude // долгота
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10 // радиус
            imageView.clipsToBounds = true // обрезаем
            imageView.image = UIImage(data: imageData) // подставляем картинку предварительно проверив на опциональное значение
            annotationView?.rightCalloutAccessoryView = imageView // отображаем нашу картинку на банере
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // будет вызываться при каждой смене региона и будет отоброжаться новый адрес
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder() // отвечает за преобразование географических координат и названий
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare // улица
            let buildNumber = placemark?.subThoroughfare // номер дома
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
                
            }
            
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
