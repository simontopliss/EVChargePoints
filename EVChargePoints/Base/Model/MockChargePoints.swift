//
//  MockChargePoints.swift
//  EVChargePoints
//
//  Created by Simon Topliss on 14/07/2023.
//

import Foundation

extension ChargePointData {

    static var mockChargeDevices: [ChargeDevice] {
        let chargePointData = try? StaticJSONMapper.decode(
            file: "HU17 0RX - 10 milles",
            type: ChargePointData.self
        )
        return chargePointData!.chargeDevices
    }

    static var mockChargeDevice = mockChargeDevices[5]
}
