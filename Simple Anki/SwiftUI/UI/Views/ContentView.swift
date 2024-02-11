//
//  TransitionDemo.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.01.2024.
//

import SwiftUI

// enum TabbedItems: Int, CaseIterable {
//    case home = 0
//    case favorite
//
//    var title: String {
//        switch self {
//        case .home:
//            return "Decks"
//        case .favorite:
//            return "Settings"
//        }
//    }
//
//    var iconName: String {
//        switch self {
//        case .home:
//            return "tray.full.fill"
//        case .favorite:
//            return "gear"
//        }
//    }
// }
//
// struct MainTabbedView: View {
//
//    @State var selectedTab = 0
//    @State var next: Bool = false
//
//    var body: some View {
//
//        ZStack(alignment: .bottom) {
//            TabView(selection: $selectedTab) {
//                NavigationStack {
//                    Button("go to next") {
//                        next.toggle()
//                    }.navigationDestination(isPresented: $next) {
//                        DecksView()
//                    }
//
//
//                }
//
//                Text("Settings")
//                    .tag(1)
//            }
//
//            ZStack {
//                HStack {
//                    ForEach((TabbedItems.allCases), id: \.self) { item in
//                        Button {
//                            selectedTab = item.rawValue
//                        } label: {
//                            customTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
//                        }
//                    }
//                }
//                .padding(6)
//            }
//            .frame(maxWidth: .infinity, maxHeight: 70)
//            .background(.cyan.opacity(0.2))
//            .cornerRadius(35)
//            .padding(.horizontal, 26)
//            .offset(x: next == true ? -400 : 0)
//            .animation(.bouncy(duration: 0.2), value: next)
//        }
//    }
// }
//
// extension MainTabbedView {
//    func customTabItem(imageName: String, title: String, isActive: Bool) -> some View {
//        VStack(spacing: 5) {
//            Spacer()
//            Image(systemName: imageName)
//                .renderingMode(.template)
//                .foregroundColor(isActive ? .black : .gray)
//                Text(title)
//                    .font(.system(size: 10))
//                    .foregroundColor(isActive ? .black : .gray)
//            Spacer()
//        }
//        .padding()
//        .frame(width: 100, height: 60)
//        .background(isActive ? .cyan.opacity(0.4) : .clear)
//        .cornerRadius(30)
//    }
// }

struct FirstView: View {
    var body: some View {
        List {
            ForEach(0..<20) { item in
                NavigationLink {
                    ThirdView()
                } label: {
                    Text("\(item)")
                }

            }
        }
        .listStyle(.plain)
        .navigationTitle("First title")
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

struct SecondView: View {
    var body: some View {
        List {
            ForEach(0..<20) { item in
                NavigationLink {
                    ThirdView()
                } label: {
                    Text("\(item)")
                }
            }
        }
        .navigationTitle("Title")
    }
}

struct ThirdView: View {
    var body: some View {
        VStack {
            List {
                ForEach(0..<20) { _ in
                    Text("Third View with tabBar hidden")
                        .font(.headline)
                }
            }
            .listStyle(.plain)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)

            Divider()

            HStack {
                Button(action: {}, label: {
                    Text("Button")
                })
            }
            .padding(0)
            .frame(height: 42)
        }
        .navigationTitle("Cards")
    }
}

enum Tab: Int {
    case first, second, third
}

struct TabBarView: View {

    @State private var selectedTab: Tab = .first

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .first:
                    NavigationStack {
                        VStack(spacing: 0) {
//                            DecksView()
                            TabBarView()
                        }
                    }
                case .second:
                    NavigationStack {
                        SettingsView()
                    }
                case .third:
                    Text("Third")
                }
            }

            if selectedTab != .first {
                TabBarView()
            }
        }
    }

    @ViewBuilder
    func TabBarView() -> some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                Spacer()
                TabItemView(tab: .first, title: "Decks", icon: "tray.full.fill", selectedTab: $selectedTab)
                Spacer(minLength: 144)
                TabItemView(tab: .second, title: "Settings", icon: "gear", selectedTab: $selectedTab)
                Spacer()
            }
            .padding(.top, 8)

        }
        .frame(height: 50)
    }
}

struct TabItemView2: View {
    let title: String
    let icon: String
    let tab: Tab

    @Binding var selectedTab: Tab

    init(tab: Tab, title: String, icon: String, selectedTab: Binding<Tab>) {
        self.tab = tab
        self.title = title
        self.icon = icon
        self._selectedTab = selectedTab
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(selectedTab == tab ? .blue : .secondary)
        }
        .frame(width: 65, height: 42)
        .onTapGesture {
            selectedTab = tab
        }
    }
}

#Preview {
    TabBarView()
}
