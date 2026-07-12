import SwiftUI

struct AdaptiveGridLayout {
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?
    var containerSize: CGSize = .zero

    var columnCount: Int {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .compact):
            return 4  // iPhone Plus/Max landscape
        case (.regular, .regular):
            // iPad: both orientations share the same size classes,
            // so compare actual dimensions to detect landscape.
            return containerSize.width > containerSize.height ? 5 : 4
        default:
            return 2  // iPhone portrait (and compact landscape)
        }
    }

    func gridItems(spacing: CGFloat = 12) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
}
