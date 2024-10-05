//
//  DetailView.swift
//  QuickActionDemo
//
//  Created by Itsuki on 2024/09/30.
//


import SwiftUI

struct DetailView: View {
    
    @AppStorage("favoriteSymbols") private var favoriteSymbolsString: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var manager: ShortCutManager

    @State private var shortCutExist = false
    
    var name: String
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(spacing: 48) {
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 72)

            
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 72)
            
            Toggle(isOn: $isFavorite, label: {
                Text("Favorite")
                    .foregroundStyle(.pink)
            })
            .tint(.pink)
            .padding(.horizontal, 80)
            
            HStack {
                Button(action: {
                    if shortCutExist {
                        manager.removeOpenFavoriteShortCut(name)
                        shortCutExist = false
                    } else {
                        manager.addOpenFavoriteShortCut(name)
                        shortCutExist = true
                    }
                    
                }, label: {
                    Image(systemName: shortCutExist ? "checkmark.square" : "square")
                    Text("Open Favorite ShortCut")
                })
            }
            .foregroundStyle(.pink)

            if let errorMessage = manager.errorMessage {
                Text("Error Occurred: \(errorMessage)")
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 72)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.gray.opacity(0.2))
        .onAppear {
            self.isFavorite = isSymbolFavorite()
            self.shortCutExist = manager.openFavoriteExist(name)
        }
        .onChange(of: favoriteSymbolsString, {
            self.isFavorite = isSymbolFavorite()
        })
        .onChange(of: isFavorite, {
            var favorites: [String] = favoriteSymbolsString.split(separator: ",").map({String($0)})
            if isFavorite && !favorites.contains(name) {
                favorites.append(name)
            } else if !isFavorite && !favorites.contains(name) {
                favorites.removeAll(where: {$0 == name})
            }
            favoriteSymbolsString = favorites.joined(separator: ",")
        })
        .onChange(of: scenePhase, {
            if scenePhase == .background || scenePhase == .inactive {
                manager.addOpenLastShortCut(name)
            }
        })
    }
    
    private func isSymbolFavorite() -> Bool {
        let favorites: [String] = favoriteSymbolsString.split(separator: ",").map({String($0)})
        return favorites.contains(name)
    }
}

#Preview {
    DetailView(name: "heart.fill")
        .environmentObject(ShortCutManager.instance)
}

