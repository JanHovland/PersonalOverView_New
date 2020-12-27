//
//  PersonMapView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

import Foundation
import SwiftUI
import MapKit

/// https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1

/// http://maps.apple.com/?address=Kvernfallvegen,3,4347,Lye
/// http://maps.apple.com/?address=Kvernfallvegen 3 4347 Lye

struct PersonMapView: View {
    
    /// Ikke i bruk lenger

    @Environment(\.presentationMode) var presentationMode

    var locationOnMap: String
    var address: String
    var subtitle: String

    var body: some View {
        /// Compilerer OK men under kjøring kommer denne feilmeldingen:
        /// Use of unresolved identifier 'MapView' når MapView ligger i MapView.swift
        /// OK når struct MapView ligger lokalt
        MapView(locationOnMap: locationOnMap,
                address: address,
                subtitle: subtitle)
        .overlay(
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.none)
                    })
                        .padding(.trailing, 20)
                        .padding(.top, 70)
                    Spacer()
                }
        })
    }

}

struct MapView: UIViewRepresentable {

    var locationOnMap: String
    var address: String
    var subtitle: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        /// Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationOnMap, completionHandler: { placemarks, error in
            if let error = error {
                let _ = error.localizedDescription
                return
            }
            if let placemarks = placemarks {
                /// Get the first placemark
                let placemark = placemarks[0]
                /// placemark = Uelandsgata 2, Uelandsgata 2, 4360 Varhaug, Norge @ <+58.61729080,+5.64474960> +/- 100.00m, region CLCircularRegion (identifier:'<+58.61729080,+5.64474960> radius 70.82', center:<+58.61729080,+5.64474960>, radius:70.82m)
                /// Add annotation
                let annotation = MKPointAnnotation()
                mapView.addAnnotation(annotation)
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    annotation.title = address
                    annotation.subtitle = subtitle
                    /// Display the annotationn
                    mapView.showAnnotations([annotation], animated: true)
                    mapView.selectAnnotation(annotation, animated: true)
                }
            }

        })
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            let _ = mapView.centerCoordinate
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.canShowCallout = true
            return view
        }
    }

}

