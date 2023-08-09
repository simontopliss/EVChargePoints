//
//  FiltersView.swift
//  EVChargePoints
//
//  Created by Simon Topliss on 29/06/2023.
//

import SwiftUI

struct FiltersView: View {

    @EnvironmentObject private var routerManager: NavigationRouter
    @EnvironmentObject private var dataManager: DataManager

    @StateObject private var filtersViewModel = FiltersViewModel()

    var maximumDistanceLabel: String {
        "\(Int(dataManager.distance)) \(dataManager.units == .mi ? "miles" : "kilometres")"
    }

    var body: some View {
        VStack {
            NavigationStack(path: $routerManager.routes) {

                List {
                    maximumDistance()

                    ForEach($filtersViewModel.filters) { filter in
                        FilterNavigationLink(
                            destination: filter.destination,
                            title: filter.title,
                            symbol: filter.symbol
                        )
                    }
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textColor)
            }

//            // TODO: This should be only enabled if the user has made changes
//            Button {
//                // Apply Filters and return back to previous screen
//                routerManager.goBack()
//            } label: {
//                Text("Apply Filter")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//            }
//            .frame(width: 280, height: 44)
//            .background(Color.accentColor)
//            .foregroundStyle(.white)
//            .cornerRadius(8)
//            .padding(.bottom, 48)

        }
        .background(Color.background)
        .navigationDestination(for: Route.self) { $0 }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // Go back to previous route in stack
                    routerManager.goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Save filters
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Save Filter")
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FiltersView()
    }
    .environmentObject(DataManager())
    .environmentObject(FiltersViewModel())
    .environmentObject(NavigationRouter())
}

extension FiltersView {

    func maximumDistance() -> some View {
        VStack(alignment: .leading) {
            Group {
                Text("Maximum distance: ")
                    .fontWeight(.regular)
                + Text("\(maximumDistanceLabel)")
            }
            .font(.body)

            Slider(
                value: $dataManager.distance,
                in: 5...100,
                step: 5
            ) {
                Text("Label")
                    .font(.subheadline)
                    .fontWeight(.regular)
            } minimumValueLabel: {
                Text("5")
                    .font(.subheadline)
                    .fontWeight(.regular)
            } maximumValueLabel: {
                Text("100")
                    .font(.subheadline)
                    .fontWeight(.regular)
            } onEditingChanged: {
                print("\($0)")
            }
        }
        .padding(.vertical, 10)
    }
}

struct FilterNavigationLink: View {

    @Binding var destination: Route
    @Binding var title: String
    @Binding var symbol: Image

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                symbol
                    .font(.title)
                    .fontWeight(.regular)
                    .frame(
                        maxWidth: Symbols.symbolWidth,
                        maxHeight: Symbols.symbolHeight,
                        alignment: .center
                    )
                    .padding(.trailing, 6)
                Text(title)
            }
            .padding(.vertical, 10)
        }
    }
}

final class FiltersViewModel: ObservableObject {

    @Published var filters: [Filter] = []

    init() {
        createFilters()
    }

    func createFilters() {
        filters = [
            Filter(
                title: "Access",
                symbol: Symbols.accessSymbol,
                destination: Route.filterAccessTypesView
            ),
            Filter(
                title: "Charger",
                symbol: Symbols.chargerSymbol,
                destination: Route.filterChargerTypesView
            ),
            Filter(
                title: "Connector",
                symbol: Symbols.connectorSymbol,
                destination: Route.filterConnectorTypesView
            ),
            Filter(
                title: "Location",
                symbol: Symbols.locationSymbol,
                destination: Route.filterLocationTypesView
            ),
            Filter(
                title: "Network",
                symbol: Symbols.networkSymbol,
                destination: Route.filterNetworkTypesView
            ),
            Filter(
                title: "Payment",
                symbol: Symbols.paymentSymbol,
                destination: Route.filterPaymentTypesView
            )
        ]
    }
}

extension FiltersViewModel {
    struct Filter: Identifiable {
        var id = UUID()
        var title: String
        var symbol: Image
        var destination: Route
    }
}

