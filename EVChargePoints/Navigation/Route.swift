//
//  Route.swift
//  EVChargePoints
//
//  Created by Simon Topliss 20/07/2023.
//

import Foundation
import SwiftUI

enum Route {
    case mapView // TODO: Pass a navigation destination/location
    case chargePointDetail(chargeDevice: ChargeDevice)
    case routesView // TODO: Pass a navigation destination/location
    case settingsView
    case filtersView
    case filterAccessTypesView
    case filterConnectorTypesView
    case filterLocationTypesView
    case filterNetworkTypesView
    case filterPaymentTypesView
    case filterChargerTypesView
    case searchView
}

extension Route: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        // TODO: Add routes for List, Detail, Routes and Settings etc
        switch (lhs, rhs) {
            case (.mapView, .mapView):
                return true
            case let (.chargePointDetail(lhsChargeDevice), .chargePointDetail(rhsChargeDevice)):
                return lhsChargeDevice == rhsChargeDevice
            case (.routesView, .routesView):
                return true
            case (.settingsView, .settingsView):
                return true
            case (.filtersView, .filtersView):
                return true
            case (.searchView, .searchView):
                return true
            case (.filterAccessTypesView, .filterAccessTypesView):
                return true
            case (.filterConnectorTypesView, .filterConnectorTypesView):
                return true
            case (.filterLocationTypesView, .filterLocationTypesView):
                return true
            case (.filterNetworkTypesView, .filterNetworkTypesView):
                return true
            case (.filterPaymentTypesView, .filterPaymentTypesView):
                return true
            case (.filterChargerTypesView, .filterChargerTypesView):
                return true
            default:
                return false
        }
    }
}

extension Route: View {

    var body: some View {

        switch self {
            case .mapView:
                MapView()
            case let .chargePointDetail(chargeDevice):
                ChargePointDetailView(chargeDevice: chargeDevice)
            case .routesView:
                RoutesView()
            case .settingsView:
                SettingsView()
            case .filtersView:
                FiltersView()
            case .searchView:
                SearchView()
            case .filterAccessTypesView:
                AccessTypesView()
            case .filterConnectorTypesView:
                ConnectorTypesView()
            case .filterLocationTypesView:
                LocationTypesView()
            case .filterNetworkTypesView:
                NetworkTypesView()
            case .filterPaymentTypesView:
                PaymentTypesView()
            case .filterChargerTypesView:
                ChargerTypesView()
        }
    }
}
