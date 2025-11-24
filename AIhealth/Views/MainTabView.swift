//
//  MainTabView.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI
import Combine

class TabNavigationManager: ObservableObject {
    @Published var selectedTab: Int = 0
}

struct MainTabView: View {
    @StateObject private var tabManager = TabNavigationManager()

    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            // Home Tab
            NavigationStack {
                DashboardHomeScreen()
                    .environmentObject(tabManager)
            }
            .tabItem {
                Label("tab_home".localized, systemImage: "house.fill")
            }
            .tag(0)

            // Chat Tab
            NavigationStack {
                ChatScreen()
            }
            .tabItem {
                Label("tab_consultation".localized, systemImage: "message.fill")
            }
            .tag(1)

            // Reservation Tab
            NavigationStack {
                ReservationScreen()
            }
            .tabItem {
                Label("tab_reservation".localized, systemImage: "calendar.badge.plus")
            }
            .tag(2)

            // Reports Tab
            NavigationStack {
                ReportListScreen()
            }
            .tabItem {
                Label("tab_records".localized, systemImage: "doc.text.fill")
            }
            .tag(3)
        }
        .accentColor(.bluePrimary)
    }
}

#Preview {
    MainTabView()
}
