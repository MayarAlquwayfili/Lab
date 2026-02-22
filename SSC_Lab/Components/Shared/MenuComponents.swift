//
//  MenuComponents.swift
//  SSC_Lab
//
//  Reusable context menu items for consistent Edit/Delete across Lab and Wins.
//

import SwiftUI

/// Shared "Edit" context menu item 
struct SharedEditMenuItem: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Edit", systemImage: "pencil")
        }
    }
}

/// Shared "Delete" context menu item
struct SharedDeleteMenuItem: View {
    var action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Label("Delete", systemImage: "trash")
        }
    }
}
