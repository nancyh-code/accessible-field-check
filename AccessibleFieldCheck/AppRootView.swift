//
//  AppRootView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

enum AppDestination: Hashable {
    case newAudit
}

struct AppRootView: View {
    @State private var path: [AppDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            AuditsView(path: $path)
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .newAudit:
                        NewAuditPlaceholderView()
                    }
                }
        }
    }
}

#Preview {
    AppRootView()
}
