//
//  AppDelegate.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupUserNotifications()
        return true
    }
    
    private func setupUserNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知權限已獲得")
            } else if let error = error {
                print("通知權限錯誤: \(error.localizedDescription)")
            }
        }
    }
    
//    var window: UIWindow?
//    private let viewModel = WeatherViewModel()
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        setupUserNotifications()
//        return true
//    }
//    
//    private func setupUserNotifications() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("通知權限已獲得")
//            } else if let error = error {
//                print("通知權限錯誤: \(error)")
//            }
//        }
//    }
//    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // 儲存當前狀態
//        try? StorageService().save(viewModel.weather, forKey: "last_weather")
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // 重新載入資料
//        viewModel.refreshWeather()
//    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

