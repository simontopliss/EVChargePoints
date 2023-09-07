//
//  SearchView.swift
//  EVConneXion
//
//  Created by Simon Topliss on 29/06/2023.
//

import SwiftUI

struct SearchView: View {

    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    /// Autocompletion for the input text
    @ObservedObject private var autocomplete = AutocompleteObject()

    /// Input text in the text field
    @State var input: String = ""
    @State private var showInvalidPostcodeAlert = false

    @FocusState private var isFocused: Bool
    @Binding var showSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            searchHeader

            Divider().padding(.bottom)

            if dataManager.recentSearches.isEmpty {
                contentUnavailable
            } else {
                recentSearches
            }
        }
        .padding()
        .alert("Warning", isPresented: $dataManager.hasSearchError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dataManager.searchError?.errorDescription ?? "An error has occurred")
        }
        .alert(isPresented: $dataManager.hasError, error: dataManager.networkError) {
            // TODO: Check NetworkManager.NetworkError errorDescription
            Button("Retry") {
                searchForChargeDevices()
            }
        }
        .alert("Warning", isPresented: $showInvalidPostcodeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Invalid postcode")
        }
        .padding(.top)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    SearchView(showSheet: .constant(true))
        .environmentObject(DataManager())
}

extension SearchView {

    var searchHeader: some View {
        HStack(alignment: .lastTextBaseline) {
            TextField(
                "Search",
                text: $input,
                prompt: Text("Enter postcode…")
            )
            // .onChange(of: input) { _, _ in
            //     autocomplete.autocomplete(input)
            // }
            .focused($isFocused)
            .textFieldStyle(.roundedBorder)
            .foregroundStyle(AppColors.textColor)
            .onSubmit {
                searchForChargeDevices()
            }
            .submitLabel(.search)

            Button(role: .cancel) {
                showSheet.toggle()
            } label: {
                XmarkButtonView(foregroundColor: .gray)
            }
            .offset(y: 2.5)
            .padding(.bottom)
        }
    }

    var contentUnavailable: some View {
        ContentUnavailableView(
            "No recent searches",
            systemImage: Symbols.noRecentSearchesSymbolName,
            description: Text("Your search history will be displayed here.")
        )
    }
}

extension SearchView {
    func searchForChargeDevices() {
        if !dataManager.isPostcode(postcode: input) {
            showInvalidPostcodeAlert.toggle()
        } else {
            Task {
                dismiss()
                try await dataManager.searchForChargeDevices(searchQuery: input)
            }
        }
    }
}

extension SearchView {

    var recentSearches: some View {
        Section("Recent Searches") {
            List(dataManager.recentSearches) { recentSearch in
                Text(recentSearch.searchQuery)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .foregroundStyle(AppColors.textColor)
                    .tag(recentSearch.id)
                    .onTapGesture {
                        input = recentSearch.searchQuery
                        searchForChargeDevices()
                    }
            }
        }
        .listStyle(.inset)
    }
}