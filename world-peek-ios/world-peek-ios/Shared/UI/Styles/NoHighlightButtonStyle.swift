//
//  NoHighlightButtonStyle.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 29/04/26.
//

import SwiftUI

// MARK: Remove highlight no tap

struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1)
            .scaleEffect(1)
    }
}
