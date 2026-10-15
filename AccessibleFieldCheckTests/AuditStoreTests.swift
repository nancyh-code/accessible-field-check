//
//  AuditStoreTests.swift
//  AccessibleFieldCheckTests
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation
import SwiftData
import Testing
@testable import AccessibleFieldCheck

@MainActor
struct AuditStoreTests {

    private let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
    private let later = Date(timeIntervalSince1970: 1_700_000_100)
    private let latest = Date(timeIntervalSince1970: 1_700_000_200)

    @Test func createDraftPersistsCallerTitleAndUnreviewedCatalogItems() throws {
        let (store, _) = try makeStore()
        let title = "Revisión de checkout"
        let catalogIDs = AccessibilityCriterionCatalog.all.map(\.id)

        let audit = try store.createDraft(title: title, now: createdAt)
        let fetched = try store.fetchAudits()

        #expect(audit.title == title)
        #expect(audit.status == .draft)
        #expect(audit.createdAt == createdAt)
        #expect(audit.updatedAt == createdAt)
        #expect(audit.items.count == catalogIDs.count)
        #expect(Set(audit.items.map(\.criterionID)) == Set(catalogIDs))
        #expect(Set(audit.items.map(\.criterionID)).count == catalogIDs.count)

        for item in audit.items {
            #expect(item.result == .notReviewed)
            #expect(item.note == nil)
            #expect(item.updatedAt == createdAt)
        }

        #expect(fetched.count == 1)
        #expect(fetched[0].identifier == audit.identifier)
        #expect(fetched[0].title == title)
    }

    @Test func updateResultChangesOnlyTheTargetItemAndTimestamps() throws {
        let (store, _) = try makeStore()
        let audit = try store.createDraft(title: "Formulario", now: createdAt)
        let target = try item(audit, criterionID: "dynamicType")
        let other = try item(audit, criterionID: "colorContrast")
        let otherIdentifier = other.identifier
        let otherUpdatedAt = other.updatedAt

        try store.updateResult(item: target, result: .pass, now: later)

        #expect(target.result == .pass)
        #expect(target.updatedAt == later)
        #expect(audit.updatedAt == later)

        let unchanged = try item(audit, identifier: otherIdentifier)
        #expect(unchanged.result == .notReviewed)
        #expect(unchanged.updatedAt == otherUpdatedAt)
        #expect(audit.items.filter { $0.result == .pass }.count == 1)
    }

    @Test func updateNoteAddsEditsRemovesAndNormalizesEmptyString() throws {
        let (store, _) = try makeStore()
        let audit = try store.createDraft(title: "Navegación", now: createdAt)
        let target = try item(audit, criterionID: "voiceOverLabels")

        try store.updateNote(item: target, note: "Falta etiqueta", now: later)
        #expect(target.note == "Falta etiqueta")
        #expect(target.updatedAt == later)
        #expect(audit.updatedAt == later)

        try store.updateNote(item: target, note: "Etiqueta genérica", now: latest)
        #expect(target.note == "Etiqueta genérica")
        #expect(target.updatedAt == latest)
        #expect(audit.updatedAt == latest)

        let removedAt = Date(timeIntervalSince1970: 1_700_000_300)
        try store.updateNote(item: target, note: nil, now: removedAt)
        #expect(target.note == nil)
        #expect(target.updatedAt == removedAt)
        #expect(audit.updatedAt == removedAt)

        let emptiedAt = Date(timeIntervalSince1970: 1_700_000_400)
        try store.updateNote(item: target, note: "temporal", now: later)
        try store.updateNote(item: target, note: "", now: emptiedAt)
        #expect(target.note == nil)
        #expect(target.updatedAt == emptiedAt)
        #expect(audit.updatedAt == emptiedAt)
    }

    @Test func completeKeepsUnreviewedItemsAndReopenPreservesResults() throws {
        let (store, _) = try makeStore()
        let audit = try store.createDraft(title: "Modal", now: createdAt)
        let reviewed = try item(audit, criterionID: "modalAccessibility")
        let unfinished = try item(audit, criterionID: "errorIdentification")
        let reviewedIdentifier = reviewed.identifier
        let unfinishedIdentifier = unfinished.identifier
        let itemSnapshots = audit.items.map { ItemSnapshot(item: $0) }

        try store.updateResult(item: reviewed, result: .needsAttention, now: later)
        try store.updateNote(item: reviewed, note: "Foco atrapado", now: later)

        try store.complete(audit, now: latest)

        #expect(audit.status == .completed)
        #expect(audit.updatedAt == latest)
        #expect(audit.items.count == itemSnapshots.count)
        #expect(try item(audit, identifier: reviewedIdentifier).result == .needsAttention)
        #expect(try item(audit, identifier: reviewedIdentifier).note == "Foco atrapado")
        #expect(try item(audit, identifier: unfinishedIdentifier).result == .notReviewed)
        #expect(try item(audit, identifier: unfinishedIdentifier).note == nil)

        for snapshot in itemSnapshots {
            let current = try item(audit, identifier: snapshot.identifier)
            if current.identifier == reviewedIdentifier {
                #expect(current.updatedAt == later)
            } else {
                #expect(current.updatedAt == snapshot.updatedAt)
                #expect(current.result == snapshot.result)
                #expect(current.note == snapshot.note)
            }
        }

        let reopenedAt = Date(timeIntervalSince1970: 1_700_000_300)
        try store.reopen(audit, now: reopenedAt)

        #expect(audit.status == .draft)
        #expect(audit.updatedAt == reopenedAt)
        #expect(try item(audit, identifier: reviewedIdentifier).result == .needsAttention)
        #expect(try item(audit, identifier: reviewedIdentifier).note == "Foco atrapado")
        #expect(try item(audit, identifier: unfinishedIdentifier).result == .notReviewed)
        #expect(try item(audit, identifier: unfinishedIdentifier).note == nil)
        #expect(audit.items.count == itemSnapshots.count)
    }

    @Test func fetchAuditsReturnsUpdatedAtDescending() throws {
        let (store, _) = try makeStore()
        let older = try store.createDraft(title: "Primera", now: createdAt)
        let newer = try store.createDraft(title: "Segunda", now: later)

        try store.updateResult(
            item: try item(older, criterionID: "focusOrder"),
            result: .pass,
            now: latest
        )

        let fetched = try store.fetchAudits()

        #expect(fetched.map(\.identifier) == [older.identifier, newer.identifier])
        #expect(fetched.map(\.updatedAt) == [latest, later])
    }

    @Test func persistenceRoundTripPreservesAuditAndItemData() throws {
        let container = try makeContainer()
        let store = AuditStore(modelContext: ModelContext(container))
        let audit = try store.createDraft(title: "Contraste", now: createdAt)
        let target = try item(audit, criterionID: "colorContrast")
        let auditIdentifier = audit.identifier
        let itemIdentifier = target.identifier

        try store.updateResult(item: target, result: .needsAttention, now: later)
        try store.updateNote(item: target, note: "Ratio insuficiente", now: later)

        let reloadedStore = AuditStore(modelContext: ModelContext(container))
        let fetched = try reloadedStore.fetchAudits()

        #expect(fetched.count == 1)
        let reloaded = fetched[0]
        #expect(reloaded.identifier == auditIdentifier)
        #expect(reloaded.title == "Contraste")
        #expect(reloaded.status == .draft)
        #expect(reloaded.createdAt == createdAt)
        #expect(reloaded.updatedAt == later)

        let reloadedItem = try item(reloaded, identifier: itemIdentifier)
        #expect(reloadedItem.criterionID == "colorContrast")
        #expect(reloadedItem.result == .needsAttention)
        #expect(reloadedItem.note == "Ratio insuficiente")
        #expect(reloadedItem.updatedAt == later)

        for other in reloaded.items where other.identifier != itemIdentifier {
            #expect(other.result == .notReviewed)
            #expect(other.note == nil)
        }
    }

    @Test func unknownEnumRawValuesFallBackWithoutChangingStoredRawValues() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AuditStore(modelContext: context)
        let audit = try store.createDraft(title: "Estados", now: createdAt)
        let target = try item(audit, criterionID: "reduceMotion")

        audit.statusRaw = "notARealStatus"
        target.resultRaw = "notARealResult"
        try context.save()

        #expect(audit.status == .draft)
        #expect(target.result == .notReviewed)

        let reloadedStore = AuditStore(modelContext: ModelContext(container))
        let reloaded = try reloadedStore.fetchAudits()[0]
        let reloadedItem = try item(reloaded, identifier: target.identifier)

        #expect(reloaded.statusRaw == "notARealStatus")
        #expect(reloaded.status == .draft)
        #expect(reloadedItem.resultRaw == "notARealResult")
        #expect(reloadedItem.result == .notReviewed)
    }

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Audit.self,
            AuditItem.self,
            configurations: configuration
        )
    }

    private func makeStore() throws -> (AuditStore, ModelContainer) {
        let container = try makeContainer()
        return (AuditStore(modelContext: ModelContext(container)), container)
    }

    private func item(_ audit: Audit, criterionID: String) throws -> AuditItem {
        try #require(audit.items.first { $0.criterionID == criterionID })
    }

    private func item(_ audit: Audit, identifier: UUID) throws -> AuditItem {
        try #require(audit.items.first { $0.identifier == identifier })
    }
}

private struct ItemSnapshot {
    let identifier: UUID
    let result: AuditResult
    let note: String?
    let updatedAt: Date

    init(item: AuditItem) {
        identifier = item.identifier
        result = item.result
        note = item.note
        updatedAt = item.updatedAt
    }
}
