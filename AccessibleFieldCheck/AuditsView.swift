//
//  AuditsView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct AuditsView: View {
    @Binding var path: [AppDestination]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("No hay auditorías todavía")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Button("Nueva auditoría") {
                    path.append(.newAudit)
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 480)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Auditorías")
    }
}

#Preview {
    NavigationStack {
        AuditsView(path: .constant([]))
    }
}
