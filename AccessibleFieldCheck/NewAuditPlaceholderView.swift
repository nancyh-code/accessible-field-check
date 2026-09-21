//
//  NewAuditPlaceholderView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct NewAuditPlaceholderView: View {
    var body: some View {
        Text("Marcador de posición")
            .font(.body)
            .multilineTextAlignment(.center)
            .padding()
            .navigationTitle("Nueva auditoría")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewAuditPlaceholderView()
    }
}
