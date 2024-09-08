//
//  AppDelegate.swift
//  Letports
//
//  Created by mosi on 8/5/24.
//

import UIKit
import Firebase
import GoogleSignIn
import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        }
        
        UITabBar.appearance().unselectedItemTintColor = .lp_gray
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("Push notifications permission granted.")
            } else if let error = error {
                print("Push notifications permission denied with error: \(error.localizedDescription)")
            }
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // APNS 토큰을 설정
        Messaging.messaging().apnsToken = deviceToken
        
        print("APNS device token set.")
    }
    
    // FCM 토큰 수신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM registration token: \(String(describing: fcmToken))")
        
        if let fcmToken = fcmToken {
            // FCM 토큰을 서버에 전송하거나 Firestore에 저장하는 로직
            NotificationService.shared.setFCMToken(fcmToken)
        }
    }
    
    // 푸시 알림 수신 처리 (iOS 10 이상)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Push notification received with userInfo: \(userInfo)")
        
        // 알림을 어떤 형태로 표시할지 결정
        completionHandler([.alert, .badge, .sound])
    }
    
    // 푸시 알림 클릭 시 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Push notification clicked with userInfo: \(userInfo)")
        
        // 추가 작업 필요시 처리
        
        completionHandler()
    }
    
}

