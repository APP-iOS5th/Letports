//
//  NotificationService.swift
//  Letports
//
//  Created by mosi on 9/8/24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Combine

class NotificationService {
    static let shared = NotificationService()
    private var cancellables = Set<AnyCancellable>()
    private var uid: String?
    private var fcmToken: String?
    
    private init() {}
    
    func setUIDAndRegisterToken(uid: String, fcmToken: String) {
        self.uid = uid
        self.fcmToken = fcmToken
        updateFCMTokenInFirestore()
    }
    
    /// FCM 토큰을 설정하는 메서드
    func setFCMToken(_ fcmToken: String) {
        self.fcmToken = fcmToken
        print("FCM token set to: \(fcmToken)")
        
        // UID가 설정된 경우에만 Firestore에 업데이트
        if let uid = self.uid {
            updateFCMTokenInFirestore()
        }
    }
    
    /// Firestore에 FCM 토큰을 업데이트하는 메서드
    private func updateFCMTokenInFirestore() {
        guard let uid = uid, let fcmToken = fcmToken else {
            print("UID or FCM token is missing.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("token").document(uid).setData(["token": fcmToken], merge: true) { error in
            if let error = error {
                print("Error updating FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token successfully updated in Firestore.")
            }
        }
    }
    
    /// 저장된 UID와 FCM 토큰을 초기화하는 메서드 (로그아웃 시 호출)
    func clearStoredToken() {
        uid = nil
        fcmToken = nil
    }
    
    /// UID를 기반으로 푸시 알림을 전송하는 메서드
    func sendPushNotificationByUID(uid: String, title: String, body: String) -> AnyPublisher<Void, FirestoreError> {
        guard let url = URL(string: "https://letports.site/send-notification-by-uid") else {
            return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"])))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["uid": uid, "title": title, "body": body]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            return Fail(error: FirestoreError.unknownError(error))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send notification with status code: \((output.response as? HTTPURLResponse)?.statusCode ?? 0)"]))
                }
                return ()
            }
            .mapError { error in
                FirestoreError.unknownError(error)
            }
            .eraseToAnyPublisher()
    }
}
