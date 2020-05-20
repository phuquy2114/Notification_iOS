//
//  AppDelegate.swift
//  Demo Notification
//
//  Created by Softone on 5/6/20.
//  Copyright © 2020 Softone. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        var list: [NotificationModel] = []
        
        if let bodies: [String] = UserDefaults.standard.array(forKey: "body") as? [String] {
            for json in bodies {
                do {
                    let data = try JSONDecoder().decode(NotificationModel.self, from: Data(json.utf8))
                    list.append(data)
                } catch { }
            }
        }
        
        UNUserNotificationCenter.current().getDeliveredNotifications{ notifications in
            //print(notifications)
            print("Count: \(notifications.count)")
            
            for item in notifications {
                print(item.request.content.userInfo)
                
                if let aps = item.request.content.userInfo["aps"] as? [AnyHashable : Any], let googleId = item.request.content.userInfo["gcm.message_id"] as? String, let alert = aps["alert"] as? [AnyHashable : Any], let body = alert["body"] as? String  {
                    let isExits = list.contains{ $0.id == googleId }
                    
                    if !isExits {
                        do {
                            let data = try JSONEncoder().encode(NotificationModel.init(body: body, id: googleId))
                            let string = String(data: data, encoding: .utf8)!
                        
                            var values = UserDefaults.standard.array(forKey: "body")
                            
                            if values == nil {
                                values = []
                            }
                            
                            values?.append(string)
                            UserDefaults.standard.set(values, forKey: "body")
                            UserDefaults.standard.synchronize()
                        } catch {
                            
                        }
                        
                        list.append(NotificationModel.init(body: body, id: googleId))
                    }
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name("Reload"), object: nil, userInfo: nil)
        }
        
        if let option = launchOptions, let userInfo = option[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]  {
            if let aps = userInfo["aps"] as? [AnyHashable : Any], let googleId = userInfo["gcm.message_id"] as? String, let alert = aps["alert"] as? [AnyHashable : Any], let body = alert["body"] as? String  {
                let isExits = list.contains{ $0.id == googleId }
                
                if !isExits {
                    do {
                        let data = try JSONEncoder().encode(NotificationModel.init(body: body, id: googleId))
                        let string = String(data: data, encoding: .utf8)!
                        
                        var values = UserDefaults.standard.array(forKey: "body")
                        
                        if values == nil {
                            values = []
                        }
                        
                        values?.append(string)
                        UserDefaults.standard.set(values, forKey: "body")
                        UserDefaults.standard.synchronize()
                    } catch {
                        
                    }
                    
                    list.append(NotificationModel.init(body: body, id: googleId))
                }
            }
        }
    
        
        print(list)
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in})
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
          }
        }
        
        return true
    }

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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        print("token\(fcmToken)")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let aps = userInfo["aps"] as? [AnyHashable : Any], let googleId = userInfo["gcm.message_id"] as? String, let alert = aps["alert"] as? [AnyHashable : Any], let body = alert["body"] as? String  {
            
            var list: [NotificationModel] = []
            
            if let bodies: [String] = UserDefaults.standard.array(forKey: "body") as? [String] {
                for json in bodies {
                    do {
                        let data = try JSONDecoder().decode(NotificationModel.self, from: Data(json.utf8))
                        list.append(data)
                    } catch { }
                }
            }
            
            let isExits = list.contains{ $0.id == googleId }
            
            if !isExits {
                do {
                    let data = try JSONEncoder().encode(NotificationModel.init(body: body, id: googleId))
                    let string = String(data: data, encoding: .utf8)!
                
                    var values = UserDefaults.standard.array(forKey: "body")
                    
                    if values == nil {
                        values = []
                    }
                    
                    values?.append(string)
                    UserDefaults.standard.set(values, forKey: "body")
                    UserDefaults.standard.synchronize()
                } catch {
                    
                }
            }
        }
        
        //let alert = aps["alert"] as? [AnyHashable : Any], let body = alert["body"]
        
        /*if (application.applicationState == UIApplication.State.inactive) {
            print(userInfo["aps"]?["alert"]?["body"])
        }
        
        if (application.applicationState == UIApplication.State.active) {
            print(userInfo["aps"]?["alert"]?["body"])
        }*/
        
        NotificationCenter.default.post(name: Notification.Name("Reload"), object: nil, userInfo: nil)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Did Register For Remote Notification")
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to Register For Remote Notifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
}

