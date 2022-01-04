
import UIKit
import Flutter
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyADv789kfEVpjA5tzfmjPrNCbEutWMdtkA")
        GeneratedPluginRegistrant.register(with: self)
        self.registerForRemoteNotification()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    func registerForRemoteNotification() {
        DispatchQueue.main.async {
            
            
            if #available(iOS 10.0, *) {
                let center  = UNUserNotificationCenter.current()
                
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                    if error == nil{
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
            }
            else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
