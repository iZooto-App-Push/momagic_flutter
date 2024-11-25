import Flutter
import UIKit
import UserNotifications
import MomagiciOSSDK

@objc public class MomagicFlutterPlugin: NSObject, FlutterPlugin,UNUserNotificationCenterDelegate,NotificationOpenDelegate,NotificationReceiveDelegate {
    
    
    
    
    static var data = "";
    
    internal init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    var channel = FlutterMethodChannel()
    var launchNotification: [String: Any]?
    var resumingFromBackground = false
    static var loggingEnabled = false
    public func onNotificationOpen(action: Dictionary<String, Any>) {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: action, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        self.channel.invokeMethod(AppConstant.IZ_PLUGIN_OPEN_NOTIFICATION, arguments: decoded)
        
    }
    public func onNotificationReceived(payload: MomagiciOSSDK.Payload) {
        
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "momagic_flutter", binaryMessenger: registrar.messenger())
        let instance = MomagicFlutterPlugin(channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
        let center = UNUserNotificationCenter.current()
        center.delegate = instance
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case AppConstant.IZ_PLUGIN_INITIALISE:
            let map = call.arguments as? Dictionary<String, String>
            guard let map = call.arguments as? Dictionary<String, String>,
                  let appId = map[AppConstant.IZ_PLUGIN_APP_ID] else {
                print("Error: 'map' is not a Dictionary<String, String> or 'appId' is nil")
                return
            }
            
            let momagicInitSettings = [AppConstant.IZ_PLUGIN_AUTO_PROMPT: true,AppConstant.IZ_PLUGIN_IS_WEBVIEW: true,AppConstant.IZ_PLUGIN_PROVISIONAL_AUTH:false]
            DATB.initialisation(momagic_app_id: appId, application: UIApplication.shared,  initSetting:momagicInitSettings)
            UNUserNotificationCenter.current().delegate = self
            DATB.notificationOpenDelegate = self
            break;
        case AppConstant.IZ_PLUGIN_ADD_EVENTS:
            if let map = call.arguments as? Dictionary<String, String>,
               let eventName = map[AppConstant.IZ_PLUGIN_EVENT_NAME] {
                DATB.addEvent(eventName: eventName, data: map)
            } else {
                print("Error: 'map' is not a Dictionary<String, String> or 'eventName' is nil")
            }
            break;
        case AppConstant.IZ_PLUGIN_ADD_USER_PROPERTIES:
            
            if let userPropertiesData = call.arguments as? Dictionary<String, String>,
               let keyName = userPropertiesData[AppConstant.IZ_PLUGIN_PROPERTIES_KEY],
               let valueName = userPropertiesData[AppConstant.IZ_PLUGIN_PROPERTIES_VALUE] {
                let data = [keyName: valueName]
                DATB.addUserProperties(data: data)
            } else {
                print("Error: 'call.arguments' is not a Dictionary<String, String> or 'keyName' or 'valueName' is nil")
            }
            break;
        case AppConstant.IZ_PLUGIN_SET_SUBSCRIPTION:
            guard let enable = call.arguments as? Bool else {
                print("Error: 'enable' is not a Boolean")
                return
            }
            DATB.setSubscription(isSubscribe: enable)
            break;
            
        case AppConstant.IZ_PLUGIN_NAVIGATE_TO_SETTING :
            DATB.checkNotificationEnable()
            break;
        case AppConstant.IZ_PLUGIN_GET_NOTIFICATION_FEED:
            guard let map = call.arguments as? Dictionary<String, Any> else {
                // Handle the case where 'map' is not a Dictionary<String, Any>
                print("Error: 'map' is not a Dictionary<String, Any>")
                return
            }
            let enable: Bool = map[AppConstant.IZ_PLUGIN_IS_PAGINATION] as? Bool ?? false
            DATB.getNotificationFeed(isPagination: enable){ (jsonString, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                    result(AppConstant.IZ_PLUGIN_NO_MORE_DATA)
                } else if let jsonString = jsonString {
                    result(jsonString)
                }
            }
            break;
        case AppConstant.IZ_PLUGIN_SUBSCRIBER_ID:
                    guard let subscriberId = call.arguments as? String else {
                        print("Error: 'Subscriber ID' is either not a String or is empty")
                        return
                    }
                    DATB.setSubscriberID(subscriberID: subscriberId)
                    break;
                    
            
            
        default:
            result(AppConstant.IZ_PLUGIN_NOT_RESULT)
            break;
        }
    }
    /* Define the all deligate
     
     - On Token
     - On Notification Recevied
     - on Notification Clicks
     
     */
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        launchNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        
        return true
    }
    
    //handle token
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DATB.getToken(deviceToken: deviceToken)
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        channel.invokeMethod(AppConstant.IZ_PLUGIN_TOKEN_RECEIVED, arguments: token)
    }
    
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        
        return true
    }
    // called forground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: [])
            
            if let decoded = String(data: jsonData, encoding: .utf8) {
                channel.invokeMethod(AppConstant.IZ_PLUGIN_RECEIVED_PAYLOAD, arguments: decoded)
                DATB.handleForeGroundNotification(notification: notification, displayNotification: AppConstant.IZ_PLUGIN_IS_NONE, completionHandler: completionHandler)
                completionHandler([.alert])
                
            } else {
                // Handle the case where decoding fails
                print("Failed to decode JSON data to String.")
            }
        } catch {
            // Handle any other errors that might occur during JSON serialization
            print("Error during JSON serialization: \(error)")
        }
        
    }
    // called background
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: [])
            if let decoded = String(data: jsonData, encoding: .utf8) {
               // channel.invokeMethod(AppConstant.IZ_PLUGIN_RECEIVED_PAYLOAD, arguments: decoded)
                DATB.notificationHandler(response: response)
            } else {
                print("Failed to decode JSON data to String.")
            }
        } catch {
            print("Error during JSON serialization: \(error)")
        }
        
        completionHandler()
    }
    
    func onResume(userInfo: [AnyHashable: Any]) {
        if launchNotification != nil {
            channel.invokeMethod(AppConstant.IZ_PLUGIN_ON_RESUME, arguments: userInfo)
            self.launchNotification = nil
            return
        }
        channel.invokeMethod(AppConstant.IZ_PLUGIN_ON_RESUME, arguments: userInfo)
    }
}
