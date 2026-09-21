//
//  AFCTokens.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

enum AFCTokens {
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    enum Color {
        static let background = systemBackground
        static let surface = systemSurface
        static let primaryText = SwiftUI.Color.primary
        static let secondaryText = SwiftUI.Color.secondary
        static let accent = SwiftUI.Color.accentColor
        static let success = systemSuccess
        static let warning = systemWarning
        static let critical = systemCritical
    }
}

private extension AFCTokens.Color {
    static let systemBackground: SwiftUI.Color = {
        #if os(macOS)
        SwiftUI.Color(nsColor: .windowBackgroundColor)
        #else
        SwiftUI.Color(uiColor: .systemBackground)
        #endif
    }()

    static let systemSurface: SwiftUI.Color = {
        #if os(macOS)
        SwiftUI.Color(nsColor: .controlBackgroundColor)
        #else
        SwiftUI.Color(uiColor: .secondarySystemBackground)
        #endif
    }()

    static let systemSuccess: SwiftUI.Color = {
        #if os(macOS)
        SwiftUI.Color(nsColor: .systemGreen)
        #else
        SwiftUI.Color(uiColor: .systemGreen)
        #endif
    }()

    static let systemWarning: SwiftUI.Color = {
        #if os(macOS)
        SwiftUI.Color(nsColor: .systemOrange)
        #else
        SwiftUI.Color(uiColor: .systemOrange)
        #endif
    }()

    static let systemCritical: SwiftUI.Color = {
        #if os(macOS)
        SwiftUI.Color(nsColor: .systemRed)
        #else
        SwiftUI.Color(uiColor: .systemRed)
        #endif
    }()
}
