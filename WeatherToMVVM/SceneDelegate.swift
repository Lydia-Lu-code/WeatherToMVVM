//
//  SceneDelegate.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 初始化 ViewModel，並注入所需的服務
        let storageService = StorageService()
        let weatherService = WeatherService(storageService: storageService)
        let viewModel = WeatherViewModel(weatherService: weatherService, storageService: storageService)
        
        let weatherViewController = WeatherViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: weatherViewController)
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 進入背景時儲存資料
        NotificationCenter.default.post(name: .saveWeatherData, object: nil)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 返回前景時更新資料
        NotificationCenter.default.post(name: .refreshWeatherData, object: nil)
    }

//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        // 創建窗口實例
//        let window = UIWindow(windowScene: windowScene)
//        
//        // 創建視圖控制器
//        let weatherViewController = WeatherViewController()
//        let navigationController = UINavigationController(rootViewController: weatherViewController)
//        
//        // 設置窗口的根視圖控制器
//        window.rootViewController = navigationController
//        
//        // 設置並顯示窗口
//        self.window = window
//        window.makeKeyAndVisible()
//    }

//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // Called as the scene transitions from the background to the foreground.
//        // Use this method to undo the changes made on entering the background.
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//    }


}

// 添加通知名稱
extension Notification.Name {
    static let saveWeatherData = Notification.Name("saveWeatherData")
    static let refreshWeatherData = Notification.Name("refreshWeatherData")
}
