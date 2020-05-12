//
//  AppDelegate.swift
//  NoteApp
//
//  Created by 王冠之 on 2020/4/16.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("home = \(NSHomeDirectory())")
        
        return true
    }
}

