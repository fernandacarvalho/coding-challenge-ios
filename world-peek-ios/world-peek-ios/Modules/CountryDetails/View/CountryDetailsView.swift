//
//  CountryDetailsView.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import MapKit
import SwiftUI

struct CountryDetailsView: View {
    @StateObject private var viewModel: CountryDetailsViewModel
    @State private var cameraPosition: MapCameraPosition
    @State private var isVisible = false
    @State private var isCardVisible = false

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

        let centeredCoordinate = CLLocationCoordinate2D(
            latitude: coordinate.latitude - 2.0,
            longitude: coordinate.longitude
        )

        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: centeredCoordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 8,
                        longitudeDelta: 8
                    )
                )
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            mapLayer

            if isCardVisible {
                CountryInfoCardView(
                    viewModel: viewModel
                )
                .zIndex(100)
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(false)
        .opacity(isVisible ? 1 : 0)
        .task {
            withAnimation(.easeIn(duration: 0.3)) {
                isVisible = true
            }

            try? await Task.sleep(
                for: .seconds(0.3)
            )

            withAnimation(
                .spring(
                    response: 0.5,
                    dampingFraction: 0.78
                )
            ) {
                isCardVisible = true
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            if let latLong = viewModel.country.latLong {
                Marker(
                    viewModel.country.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: latLong.lat,
                        longitude: latLong.long
                    )
                )
            }
        }
        .allowsHitTesting(
            !viewModel.isCardExpanded
        )
        .ignoresSafeArea()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map")
    }
}
