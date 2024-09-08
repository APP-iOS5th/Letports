import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Combine

class NotificationService {
    static let shared = NotificationService()
    private var uid: String?
    private var fcmToken: String?
    
    private init() {}
    
    private var notificationServiceURL: String? {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "NotificationService") as? String {
            let fullURLString = "https://" + urlString
            return fullURLString
        } else {
            return nil
        }
    }
    
    func setUIDAndRegisterToken(uid: String, fcmToken: String) {
        self.uid = uid
        self.fcmToken = fcmToken
        updateFCMTokenInFirestore()
    }
    
    func setFCMToken(_ fcmToken: String) {
        self.fcmToken = fcmToken
        if let uid = self.uid {
            updateFCMTokenInFirestore()
        }
    }
    
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
    
    func clearStoredToken() {
        uid = nil
        fcmToken = nil
    }
    
    func sendPushNotificationByUID(uid: String, title: String, body: String) -> AnyPublisher<Void, FirestoreError> {
        guard let urlString = notificationServiceURL else {
            print("Notification Service URL is nil or missing")
            return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"])))
                .eraseToAnyPublisher()
        }
        guard let url = URL(string: urlString) else {
            return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed URL"])))
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
