
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            MetricsView()
                .tabItem {
                    Label("Metrics", systemImage: "chart.xyaxis.line")
                }
                .tag(1)

            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.text.fill")
                }
                .tag(2)

            MedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name("MedAINavigateToTab")
            )
        ) { notification in
            if let tab = notification.object as? Int,
               (0...4).contains(tab) {
                selectedTab = tab
            }
        }
    }
}
