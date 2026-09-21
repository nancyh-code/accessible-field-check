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
            AFCEmptyState(title: "No hay auditorías todavía") {
                AFCPrimaryButton(title: "Nueva auditoría") {
                    path.append(.newAudit)
                }
            }
        }
        .background(AFCTokens.Color.background)
        .navigationTitle("Auditorías")
    }
}

#Preview {
    NavigationStack {
        AuditsView(path: .constant([]))
    }
}
