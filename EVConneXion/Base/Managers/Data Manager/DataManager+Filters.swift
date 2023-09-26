//
//  DataManager+Filters.swift
//  EVConneXion
//
//  Created by Simon Topliss on 10/08/2023.
//

import Foundation

extension DataManager {

    enum FilterResult: String {
        case noLocations
        case noConnectors
        case noChargers
        case noNetworks
    }

    func applyFilters() {
        // print("[\(Self.self)]", #function)
        print("chargeDevices count: \(chargeDevices.count)")

        var filteredDevices: [ChargeDevice] = []
        filterResultError = false
        filterResultErrorMessage = ""

        let filteredLocationTypes = filterDevicesByLocation(chargeDevices)
        print("filteredDevices after filterDevicesByLocation: \(filteredDevices.count)")
        if filteredLocationTypes.isEmpty {
            filterResultErrorMessage = "No location types found in this area. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredLocationTypes
        }

        let filteredConnectorDevices = filterDevicesByConnector(filteredDevices)
        print("filteredDevices after filterDevicesByConnector: \(filteredDevices.count)")
        if filteredConnectorDevices.isEmpty {
            filterResultErrorMessage = "No connection types found in this area. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredConnectorDevices
        }

        let filteredChargerDevices = filterDevicesByChargerType(filteredDevices)
        print("filteredDevices after filterDevicesByChargerType: \(filteredDevices.count)")
        if filteredChargerDevices.isEmpty {
            filterResultErrorMessage = "No charger types found in this area. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredChargerDevices
        }

        let filteredNetworkDevices = filterDevicesByNetwork(filteredDevices)
        print("filteredDevices after filterDevicesByNetwork: \(filteredDevices.count)")
        if filteredNetworkDevices.isEmpty {
            filterResultErrorMessage = "No network types found in this area. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredNetworkDevices
        }

        let filteredAccessDevices = filterDevicesByAccess(filteredDevices)
        print("filteredDevices after filterDevicesByAccess: \(filteredDevices.count)")
        if filteredAccessDevices.isEmpty {
            filterResultErrorMessage = "No charge devices found with these access filters in this area. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredAccessDevices
        }

        let filteredPaymentDevices = filterDevicesByPayment(filteredDevices)
        print("filteredDevices after filterDevicesByPayment: \(filteredDevices.count)")
        if filteredPaymentDevices.isEmpty {
            filterResultErrorMessage = "No charge devices found with these payment filter in this areas. Try a wider search of choose a different filter."
            print(filterResultErrorMessage)
            filterResultError = true
            self.filteredDevices = chargeDevices
            return
        } else {
            filteredDevices = filteredPaymentDevices
        }

        filteredDevices = filteredDevices.compactMap { $0 }

        if !filterResultErrorMessage.isEmpty {
            print(filterResultErrorMessage)

            filterResultError = true
            self.filteredDevices = chargeDevices
            return

        } else {

            filteredDevices.sort(
                by: { LocationManager.shared.distanceFromUser(coordinate: $0.deviceMapItem.coordinate)
                    < LocationManager.shared.distanceFromUser(coordinate: $1.deviceMapItem.coordinate)
                }
            )

            filteredDevices = sortAndRemoveDuplicateDevices(devices: filteredDevices)
            print("filteredDevices after sortAndRemoveDuplicateDevices: \(filteredDevices.count)")
        }

        print("filteredDevices count after all filtering: \(filteredDevices.count)")

        /// Limit Charge Devices as it affects SwiftUI Maps performance
        // TODO: Increase or remove limit?
        self.filteredDevices = Array(filteredDevices.prefix(500))
        print("filteredDevices count after prefix: \(filteredDevices.count)")

        if let deviceMapItem = filteredDevices.first?.deviceMapItem {
            LocationManager.shared.userLocation(coordinate: deviceMapItem.coordinate)
        }
    }

    private func filterDevicesByAccess(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        var filteredAccessDevices: [ChargeDevice] = []
        let filteredAccessTypes: [AccessData] = accessData.filter { $0.setting == true }

        if filteredAccessTypes.isEmpty { return filteredDevices }

        for filteredAccessTypes in filteredAccessTypes {
            if filteredAccessTypes.dataName == "Accessible24Hours" {
                filteredAccessDevices.append(contentsOf: filteredDevices.filter {
                    $0.accessible24Hours == filteredAccessTypes.setting
                })
            } else if filteredAccessTypes.dataName == "AccessRestrictionFlag" {
                filteredAccessDevices.append(contentsOf: filteredDevices.filter {
                    $0.accessRestrictionFlag == filteredAccessTypes.setting
                })
            } else if filteredAccessTypes.dataName == "ParkingFeesFlag" {
                filteredAccessDevices.append(contentsOf: filteredDevices.filter {
                    $0.parkingFeesFlag == filteredAccessTypes.setting
                })
            } else if filteredAccessTypes.dataName == "PhysicalRestrictionFlag" {
                filteredAccessDevices.append(contentsOf: filteredDevices.filter {
                    $0.physicalRestrictionFlag == filteredAccessTypes.setting
                })
            }
        }
        return filteredAccessDevices
    }

    private func filterDevicesByChargerType(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        var filteredChargerDevices: [ChargeDevice] = []
        let slowCharge = 3.0...5.0
        let fastCharge = 7.0...36.0
        // let rapidCharge = 43.0...350

        for chargeDevice in filteredDevices {
            if filteredChargerDevices.contains(chargeDevice) == false {
                let connectors = chargeDevice.connector

                for connector in connectors {
                    if chargerData.selectedSpeed == "Slow", slowCharge ~= connector.ratedOutputkW {
                        filteredChargerDevices.append(chargeDevice)
                    } else if chargerData.selectedSpeed == "Fast",
                              fastCharge ~= connector.ratedOutputkW
                    {
                        filteredChargerDevices.append(chargeDevice)
                    } else if chargerData.selectedSpeed == "Rapid+",
                              connector.ratedOutputkW > 36.0
                    {
                        filteredChargerDevices.append(chargeDevice)
                    }

                    if chargerData.selectedMethod.rawValue == "Single Phase AC",
                       connector.chargeMethod == .singlePhaseAc
                    {
                        filteredChargerDevices.append(chargeDevice)
                    } else if chargerData.selectedMethod.rawValue == "Three Phase AC",
                              connector.chargeMethod == .threePhaseAc
                    {
                        filteredChargerDevices.append(chargeDevice)
                    } else if chargerData.selectedMethod.rawValue == "DC",
                              connector.chargeMethod == .dc
                    {
                        filteredChargerDevices.append(chargeDevice)
                    }

                    if chargerData.tetheredCable, connector.tetheredCable == true {
                        filteredChargerDevices.append(chargeDevice)
                    }
                }
            }
        }
        return filteredChargerDevices
    }

    private func filterDevicesByConnector(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        let filteredConnectorTypes: [String] = connectorData.filter { $0.setting == true }.map { $0.connectorType.rawValue }

        let filteredConnectorDevices = filteredDevices.filter { chargeDevice in
            chargeDevice.connector.contains(where: { connector in
                filteredConnectorTypes.contains(connector.connectorType.rawValue)
            })
        }
        return filteredConnectorDevices
    }

    private func filterDevicesByLocation(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        let filteredLocationTypes: [String] = locationData.filter { $0.setting == true }.map { $0.locationType.rawValue }
        // print(filteredLocationTypes)

        var filteredLocationDevices: [ChargeDevice] = []

        for locationFilter in filteredLocationTypes {
            if locationFilter == "Dealership forecourt" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .dealershipForecourt })
            } else if locationFilter == "Educational establishment" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .educationalEstablishment })
            } else if locationFilter == "Hotel / Accommodation" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .hotelAccommodation })
            } else if locationFilter == "Leisure centre" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .leisureCentre })
            } else if locationFilter == "NHS property" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .nhsProperty })
            } else if locationFilter == "On-street" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .onStreet })
            } else if locationFilter == "Other" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .other })
            } else if locationFilter == "Park & Ride site" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .parkRideSite })
            } else if locationFilter == "Private home" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .privateHome })
            } else if locationFilter == "Public car park" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .publicCarPark })
            } else if locationFilter == "Public estate" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .publicEstate })
            } else if locationFilter == "Retail car park" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .retailCarPark })
            } else if locationFilter == "Service station" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .serviceStation })
            } else if locationFilter == "Workplace car park" {
                filteredLocationDevices.append(contentsOf: chargeDevices.filter { $0.locationType == .workplaceCarPark })
            }
        }

        return filteredLocationDevices
    }

    private func filterDevicesByNetwork(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        let networkFilters: [String] = networkData.filter { $0.setting == true }.map { $0.network }

        let filteredNetworkDevices = filteredDevices.filter { chargeDevice in
            chargeDevice.deviceNetworks.contains(where: { networkDevice in
                networkFilters.contains(networkDevice)
            })
        }
        return filteredNetworkDevices
    }

    private func filterDevicesByPayment(_ filteredDevices: [ChargeDevice]) -> [ChargeDevice] {

        var filteredPaymentDevices: [ChargeDevice] = []
        let filteredPaymentTypes: [PaymentData] = paymentData.filter { $0.setting == true }

        if filteredPaymentTypes.isEmpty { return filteredDevices }

        for filteredPaymentType in filteredPaymentTypes {
            if filteredPaymentType.dataName == "PaymentRequiredFlag" {
                filteredPaymentDevices.append(contentsOf: filteredDevices.filter {
                    $0.paymentRequiredFlag == filteredPaymentType.setting
                })
            } else if filteredPaymentType.dataName == "SubscriptionRequiredFlag" {
                filteredPaymentDevices.append(contentsOf: filteredDevices.filter {
                    $0.subscriptionRequiredFlag == filteredPaymentType.setting
                })
            }
        }
        return filteredPaymentDevices
    }
}
