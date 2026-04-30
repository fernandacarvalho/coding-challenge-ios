//
//  BottomFadeOverlay.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 29/04/26.
//

import SwiftUI

struct BottomFadeOverlay: View {
    let startColor: Color
    let endColor: Color

    var body: some View {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 54)
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(false)
    }
}
