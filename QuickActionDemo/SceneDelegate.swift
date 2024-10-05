//
//  SceneDelegate.swift
//  QuickActionDemo
//
//  Created by Itsuki on 2024/09/30.
//

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, willConnectTo
               session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
    
        if let shortcutItem = connectionOptions.shortcutItem {
            print("open from shortcut: \(shortcutItem)")
            ShortCutManager.instance.processShortCut(shortcutItem)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("short cut received on loaded app: \(shortcutItem)")
        ShortCutManager.instance.processShortCut(shortcutItem)
    }

}

