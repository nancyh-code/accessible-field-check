//
//  NewAuditView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import SwiftData
import SwiftUI

struct NewAuditView: View {
    @Binding var path: [AppDestination]
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var showsTitleError = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AFCTokens.Spacing.medium) {
                Text(String(localized: "audit.new.titleField.label"))
                    .font(.headline)
                    .foregroundStyle(AFCTokens.Color.primaryText)
                    .accessibilityHidden(true)

                TextField(
                    String(localized: "audit.new.titleField.placeholder"),
                    text: $title
                )
                .textFieldStyle(.roundedBorder)
                .font(.body)
                .focused($isTitleFocused)
                .submitLabel(.done)
                .accessibilityLabel(String(localized: "audit.new.titleField.label"))
                .accessibilityIdentifier(AFCAccessibilityID.newAuditTitleField)
                .accessibilityValue(title)
                .accessibilityHint(
                    showsTitleError
                        ? String(localized: "audit.new.titleRequired")
                        : String(localized: "audit.new.titleField.placeholder")
                )

                if showsTitleError {
                    Text(String(localized: "audit.new.titleRequired"))
                        .font(.callout)
                        .foregroundStyle(AFCTokens.Color.critical)
                        .accessibilityIdentifier(AFCAccessibilityID.newAuditTitleError)
                }

                LabeledContent(String(localized: "audit.new.context.label")) {
                    Text(String(localized: "audit.new.context.mobileApp"))
                        .foregroundStyle(AFCTokens.Color.primaryText)
                }
                .font(.body)

                AFCPrimaryButton(
                    title: String(localized: "audit.new.create"),
                    accessibilityIdentifier: AFCAccessibilityID.newAuditCreateButton
                ) {
                    createDraftIfValid()
                }
            }
            .padding(AFCTokens.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.newAuditScreen)
        .navigationTitle(String(localized: "audit.new.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createDraftIfValid() {
        let isBlank = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard !isBlank else {
            showsTitleError = true
            isTitleFocused = true
            AccessibilityNotification.Announcement(
                String(localized: "audit.new.titleRequired")
            ).post()
            return
        }

        showsTitleError = false
        let store = AuditStore(modelContext: modelContext)
        guard let audit = try? store.createDraft(title: title) else {
            return
        }

        path.removeAll { $0 == .newAudit }
        path.append(.checklist(audit.identifier))
    }
}

#Preview {
    NavigationStack {
        NewAuditView(path: .constant([]))
    }
    .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
