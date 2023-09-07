//
//  LocationFiltersView.swift
//  EVConneXion
//
//  Created by Simon Topliss on 29/07/2023.
//

import SwiftUI

struct LocationFiltersView: View {

    @EnvironmentObject private var dataManager: DataManager

    var body: some View {
        Form {
            Section("Location") {
                ForEach($dataManager.locationData) { filter in
                    ToggleWithGraphic(
                        displayName: filter.displayName.wrappedValue,
                        graphicName: filter.graphicName.wrappedValue,
                        toggled: filter.setting,
                        itemID: filter.id
                    )
                    .onChange(of: filter.setting.wrappedValue) {
                        dataManager.saveSettings(.location)
                    }
                }
            }
        }
    }
}

#Preview {
    LocationFiltersView()
        .environmentObject(DataManager())
}