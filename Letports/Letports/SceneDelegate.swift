//
//  SceneDelegate.swift
//  Letports
//
//  Created by mosi on 8/5/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var mainCoordinator: TabBarCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
//        let navigationController = UINavigationController()
        
//        mainCoordinator = TabBarCoordinator(navigationController: navigationController)
//        mainCoordinator?.start()
        
//        window?.rootViewController = GatheringUploadVC(viewModel: GatheringUploadVM())
        
        
        let post = SamplePost(postUID: "DEEB99E9-F385-4B54-BEA8-3D6C3794DF8F", userUID: "몰루", title: "Asdfasdfas", contents: "Dfasdfasdfasdf", imageUrls: ["https://firebasestorage.googleapis.com:443/v0/b/letports-81f7f.appspot.com/o/Board_Upload_Images%2F4A37A30D-75DF-4C12-AC6D-20628FB5E1291724128102.612148?alt=media&token=558be13d-e800-4978-a9d1-18ffdc36088f", "https://firebasestorage.googleapis.com:443/v0/b/letports-81f7f.appspot.com/o/Board_Upload_Images%2F00703690-A5FE-468E-9DB5-B240C4B3BB241724128102.6057038?alt=media&token=cf7da634-8a06-4ec8-a48f-9962e77d5a87"], comments: [], boardType: "Free")
        window?.rootViewController = BoardEditorVC(viewModel: BoardEditorVM())
        window?.makeKeyAndVisible()
        
    }
    
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
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

