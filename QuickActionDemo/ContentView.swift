//
//  ContentView.swift
//  QuickActionDemo
//
//  Created by Itsuki on 2024/09/30.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("favoriteSymbols") private var favoriteSymbolsString: String = ""
    
    @State private var favoriteSymbols: [String] = []
    @State private var allSymbols: [String] = []
    
    @StateObject private var manager = ShortCutManager.instance
    @Environment(\.scenePhase) private var scenePhase

    private let columns: [GridItem] = [.init(.adaptive(minimum: 72, maximum: 72))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    Text("My Favorite Symbols")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: columns, content: {
                        ForEach(allSymbols, id: \.self) { name in
                            Button(action: {
                                manager.symbolName = name
                            }, label: {
                                Image(systemName: name)
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .overlay(alignment: .topTrailing, content: {
                                        if favoriteSymbols.contains(name) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.pink)
                                        }
                                    })
                            })
                            .foregroundStyle(.black)
                        }
                    })
                    .scrollTargetLayout()
                }
            }
            .scrollIndicators(.hidden)
            .padding(.vertical, 64)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.2))
            .onAppear{
                do {
                    guard let path = Bundle.main.path(forResource: "SFSymbols", ofType: "txt") else {
                        print("path not found")
                        return
                    }
                    let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                    let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: CharacterSet.newlines)
                    self.allSymbols = lines
                } catch (let error) {
                    print(error)
                }
                parseFavoritesSymbolString()
            }
            .onChange(of: favoriteSymbolsString, {
                parseFavoritesSymbolString()
            })
            .navigationDestination(item: $manager.symbolName, destination: { name in
                DetailView(name: name)
                    .environmentObject(manager)
            })
            .onChange(of: scenePhase, {
                if scenePhase == .background || scenePhase == .inactive {
                    manager.addOpenLastShortCut()
                }
            })
        }
    }
    
    private func parseFavoritesSymbolString() {
        let favorites: [String] = favoriteSymbolsString.split(separator: ",").map({String($0)})
        self.favoriteSymbols = favorites
    }
}

#Preview {
    ContentView()
}
