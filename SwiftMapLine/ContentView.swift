import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.01161, longitude: 135.76811),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    @State private var places: [IdentifiablePlace] = [] //ここに座標が溜まっていく
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                interactionModes: .pan,
                showsUserLocation: true,
                annotationItems: places
            ) { place in
                MapPin(coordinate: place.location, tint: Color.blue)
            }
        }
        .onAppear {
            locationManager.requestPermission()
            startTracking()
        }
    }
    
    private func startTracking() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in //ここの時間を変えればいける
            if let location = locationManager.lastLocation {
                let newPlace = IdentifiablePlace(lat: location.latitude, long: location.longitude)
                places.append(newPlace) //ここで座標を配列に追加
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var lastLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.lastLocation = location.coordinate
            }
        }
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
