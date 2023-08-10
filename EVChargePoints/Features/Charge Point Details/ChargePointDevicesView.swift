//
//  ChargePointDevicesView.swift
//  EVChargePoints
//
//  Created by Simon Topliss on 19/07/2023.
//

import SwiftUI

struct ChargePointDevicesView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var dataManager: DataManager

    let chargeDevice: ChargeDevice

    var body: some View {
        Form {
            DeviceOwnerSection(deviceOwner: chargeDevice.deviceOwner)

            ForEach(0..<chargeDevice.connector.count, id: \.self) { index in
                ConnectionSection(connector: chargeDevice.connector[index], connectorCount: index)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    ChargePointDevicesView(
        chargeDevice: ChargePointData.mockChargeDevice
    )
    .environmentObject(DataManager())
}

struct DeviceOwnerSection: View {
    let deviceOwner: DeviceOwner

    var validSection: Bool {
        Validator.isValid(deviceOwner.organisationName) ||
        Validator.isValid(deviceOwner.schemeCode, forType: .schemeCode) ||
        Validator.isValid(deviceOwner.website, forType: .website) ||
        Validator.isValid(deviceOwner.telephoneNo, forType: .telephoneNo) ? true : false
    }

    var body: some View {
        if validSection {
            Section {
                if Validator.isValid(deviceOwner.organisationName) {
                    LabeledContent {
                        FormText(text: deviceOwner.organisationName)
                            .fontWeight(.semibold)
                    } label: {
                        FormLabel(label: "DEVICE OWNER")
                    }
                }

                if Validator.isValid(deviceOwner.schemeCode, forType: .schemeCode) {
                    LabeledContent {
                        FormText(text: deviceOwner.schemeCode)
                    } label: {
                        FormLabel(label: "SCHEME CODE")
                    }
                }

                if Validator.isValid(deviceOwner.website, forType: .website) {
                    LabeledContent {
                        // TODO: Make into link
                         FormText(text: deviceOwner.website)
                    } label: {
                        FormLabel(label: "WEB SITE")
                    }
                }

                if Validator.isValid(deviceOwner.telephoneNo, forType: .telephoneNo) {
                    LabeledContent {
                        // TODO: Make into telephone link
                        FormText(text: deviceOwner.telephoneNo)
                    } label: {
                        FormLabel(label: "TELEPHONE")
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct ConnectionSection: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var dataManager: DataManager

    let connector: Connector
    var connectorCount: Int

    var body: some View {
        Section("CONNECTOR \(connectorCount + 1)") {

            LabeledContent {
                FormText(text: dataManager.displayNameFor(connectorType: connector.connectorType.rawValue))
                    .fontWeight(.semibold)

                Image(dataManager.connectorGraphicFor(
                    connectorType: connector.connectorType.rawValue,
                    colorScheme: colorScheme
                ))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 36)
                    .padding(.vertical, 2)
                    .shadow(color: .secondary, radius: 3.0)

            } label: {
                FormLabel(label: "TYPE")
            }

            LabeledContent {
                FormText(text: "\(connector.ratedOutputkW) kW")
            } label: {
                FormLabel(label: "RATED")
            }

            LabeledContent {
                FormText(text: connector.chargeMethod.rawValue)
            } label: {
                FormLabel(label: "METHOD")
            }

            LabeledContent {
                HStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2.0)
                        .fill(
                            connector.chargePointStatus.rawValue == "Out of service" ? .red : .green
                        )
                        .shadow(color: .secondary, radius: 3.0)
                        .frame(height: 12)
                    Spacer()
                }
            } label: {
                FormLabel(label: "STATUS")
            }

            LabeledContent {
                // TODO: replace with coloured indicator
                FormText(text: connector.tetheredCable ? Symbols.no : Symbols.yes)
                    .shadow(color: .secondary, radius: 3.0)
            } label: {
                FormLabel(label: "TETHERED")
            }

            if Validator.isValid(connector.information) {
                LabeledContent {
                    FormText(text: connector.information!)
                } label: {
                    FormLabel(label: "INFORMATION")
                }
            }
        }
    }
}
