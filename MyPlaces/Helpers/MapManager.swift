//
//  MapManager.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 6/3/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() // менеджер который будет отслеживать местоположение пользователя
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 2000.00 // область в метрах
    private var directionsArray: [MKDirections] = [] // массив маршрутов, чтобы потом из него удалять старые маршруты, при движении пользователя
    
    // MARK: Mark of Place
    func setupPlaceMark(place: Place, mapView: MKMapView) { // устанавливаем месту отметку
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) { // метод для проверки включенных на устройстве функций для нахождения геолокации
        
        if CLLocationManager.locationServicesEnabled() { // если геолокация доступна
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else { // Алерт контроллер для включения геолокации на устройстве
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location services are disabled", message: "To enable it Go to: Settings -> Privacy -> Location services and turn On")
            }
        }
    }
    
    // MARK: Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) { // проверка статуса на разрешение использовать геопозицию
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // геолокация в момент использования
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // MARK: Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) { // метод для построения маршрута
        
        guard let location = locationManager.location?.coordinate else { // определяем местоположение пользователя
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation() // включим режим постоянного отслеживая местоположения пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request =  createDirectionsRequest(from: location) else { // запрос на прокладку маршрута
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request) // построение маршрута
        
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available ")
                return
            }
            
            for route in response.routes { //  массив с маршрутами, каждый объет route содержит сведения о геометрии маршрута на карте, время пути, дистанцию
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // отображение размера маршрута на карте
                
                //  расстояние и время в пути
                let distance = String(format: "%.1f", route.distance / 1000) // округляем дистанцию до км.
                let timeInterval = route.expectedTravelTime / 60 // время
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) минут.")
            }
        }
    }
    
    // MARK: Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {// настройка запроса для построения маршрута
        
        guard let destinationCoordinate = placeCoordinate else { return nil } // определяем точку на карте
        let startingLocation = MKPlacemark(coordinate: coordinate) // стартовая точка маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate) // назначение
        
        let request = MKDirections.Request() // настройка параметров для маршрута
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // MARK: меняем отображаемую зону области карты в соответствии с передвижением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // MARK: Сброс всех ранее построенных маршрутов для построение нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) { // обновляем маршрут, когда дистанци сокращяется, удаляем старые из массива
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }

    // MARK: Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation { // метод для определения координат в центре отображаемой области карты под Pin
        
        let latitude = mapView.centerCoordinate.latitude // широта
        let longitude = mapView.centerCoordinate.longitude // долгота
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
    
    
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1 // позиционирования нашего alert
        alertWindow.makeKeyAndVisible() // делаем видимость
        alertWindow.rootViewController?.present(alert, animated: true)
        
        
    }
}
