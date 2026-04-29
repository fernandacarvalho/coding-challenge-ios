//
//  CountryDetailsView.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import SwiftUI
import MapKit

struct CountryDetailsView: View {
    @StateObject var viewModel: CountryDetailsViewModel
    @State private var cameraPosition: MapCameraPosition

    init(viewModel: CountryDetailsViewModel) {
       _viewModel = StateObject(wrappedValue: viewModel)

        let coordinate = viewModel.country.latLong.map {
            CLLocationCoordinate2D(
                latitude: $0.lat,
                longitude: $0.long
            )
        } ?? CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0
        )

        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 8,
                        longitudeDelta: 8
                    )
                )
            )
        )
    }

    var body: some View {
        if let latLong = viewModel.country.latLong {
            let coordinate = CLLocationCoordinate2D(
                latitude: latLong.lat,
                longitude: latLong.long
            )

            Map(position: $cameraPosition) {
                Marker(viewModel.country.name, coordinate: coordinate)
            }
            .ignoresSafeArea()
            .navigationBarHidden(false)

        } else {
            Spacer()
        }
    }
}
