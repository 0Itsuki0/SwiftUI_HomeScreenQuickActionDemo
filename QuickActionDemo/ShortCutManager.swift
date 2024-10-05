//
//  QuickActionManager.swift
//  QuickActionDemo
//
//  Created by Itsuki on 2024/10/02.
//

import SwiftUI

class ShortCutManager: ObservableObject {
    static let instance = ShortCutManager()

    @Published var symbolName: String?
    @Published var errorMessage: String?

    private let unlikeActionType = "UnlikeAction"
    private let openLastActionType = "openLastAction"
    private let openFavoriteActionType = "openFavoriteAction"
    private let symbolNameInfoKey = "name"
    
    func processShortCut(_ shortcut: UIApplicationShortcutItem) {
        print("short cut opened: \(shortcut)")

        switch shortcut.type {
        case self.unlikeActionType:
            print("unlike all symbols")
            UserDefaults.standard.setValue("", forKey: "favoriteSymbols")
            self.symbolName = nil
            
        case self.openLastActionType:
            
            if let symbolName = shortcut.userInfo?[self.symbolNameInfoKey] as? String {
                print("openLast: \(symbolName)")
                self.symbolName = symbolName.isEmpty ? nil : symbolName
            }
            
        case self.openFavoriteActionType:
            
            if let symbolName = shortcut.userInfo?[self.symbolNameInfoKey] as? String {
                print("openLast: \(symbolName)")
                self.symbolName = symbolName
            }
            
        default:
            print("unknown short cut received: \(shortcut.type)")
            break
        }
    }

    
    // symbolName: nil if at main ContentView
    func addOpenLastShortCut(_ symbolName: String? = nil) {
        var currentShortCutItems = UIApplication.shared.shortcutItems ?? []
        currentShortCutItems.removeAll(where: {$0.type == self.openLastActionType})
        
        currentShortCutItems.append(UIApplicationShortcutItem(
            type: self.openLastActionType,
            localizedTitle: "Open Last Visit",
            localizedSubtitle: (symbolName != nil) ? "\(symbolName!) Detail Page!" : "Main Page!",
            icon: (symbolName != nil) ? UIApplicationShortcutIcon(systemImageName: symbolName!) : UIApplicationShortcutIcon(type: .share),
            userInfo: [self.symbolNameInfoKey: (symbolName ?? "") as NSSecureCoding]
        ))
        
        UIApplication.shared.shortcutItems = currentShortCutItems
    }
    
    
    func addOpenFavoriteShortCut(_ symbolName: String) {
        self.errorMessage = nil
        var currentShortCutItems = UIApplication.shared.shortcutItems ?? []
        if currentShortCutItems.filter({$0.type == self.openFavoriteActionType}).count > 2 {
            self.errorMessage = "Max of 2 Open Favorite short cut allowed!"
            return
        }
                
        currentShortCutItems.append(UIApplicationShortcutItem(
            type: self.openFavoriteActionType,
            localizedTitle: "Open Favorite",
            localizedSubtitle: "Open \(symbolName)!",
            icon: UIApplicationShortcutIcon(systemImageName: symbolName),
            userInfo: [self.symbolNameInfoKey: symbolName as NSSecureCoding]
        ))
        
        UIApplication.shared.shortcutItems = currentShortCutItems
    }
    
    
    func removeOpenFavoriteShortCut(_ symbolName: String) {
        var currentShortCutItems = UIApplication.shared.shortcutItems ?? []
        currentShortCutItems = currentShortCutItems.filter({$0.userInfo?[self.symbolNameInfoKey] as? String != symbolName})
        UIApplication.shared.shortcutItems = currentShortCutItems
    }
    
    
    func removeAllOpenFavorite() {
        var currentShortCutItems = UIApplication.shared.shortcutItems ?? []
        currentShortCutItems.removeAll(where: {$0.type == self.openFavoriteActionType})
        UIApplication.shared.shortcutItems = currentShortCutItems
    }
    
    
    func openFavoriteExist(_ symbolName: String) -> Bool {
        let currentShortCutItems = UIApplication.shared.shortcutItems ?? []
        return !currentShortCutItems.filter({$0.userInfo?[self.symbolNameInfoKey] as? String == symbolName}).isEmpty
    }

}
