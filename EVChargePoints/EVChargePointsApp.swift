//
//  EVChargePointsApp.swift
//  EVChargePoints
//
//  Created by Simon Topliss on 15/06/2023.
//

import SwiftUI

@main
struct EVChargePointsApp: App {

    // Create a delegate for check for when UI Testing
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage(UserDefaultKeys.tabSelection) private var tabSelection = Tabs.map

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection) {
                MapView()
                    .tabItem {
                        Label(
                            Tabs.map.label,
                            systemImage: Tabs.map.icon
                        )
                    }
                    .tag(Tabs.map)

                ChargePointListView()
                    .tabItem {
                        Label(
                            Tabs.list.label,
                            systemImage: Tabs.list.icon
                        )
                    }
                    .tag(Tabs.list)

                RoutesView()
                    .tabItem {
                        Label(
                            Tabs.routes.label,
                            systemImage: Tabs.routes.icon
                        )
                    }
                    .tag(Tabs.routes)

                SettingsView()
                    .tabItem {
                        Label(
                            Tabs.settings.label,
                            systemImage: Tabs.settings.icon
                        )
                    }
                    .tag(Tabs.settings)
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        if UITestingHelper.isUITesting { print("👷🏻‍♂️ UI Testing") }
        #endif
        return true
    }
}
