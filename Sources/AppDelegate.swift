////
///  AppDelegate.swift
//

import Crashlytics
import Keys
import TimeAgoInWords
import PINRemoteImage
import PINCache
import ElloUIFonts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var restrictRotation = true

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let debugServer = DebugServer.fromDefaults {
            APIKeys.shared = debugServer.apiKeys
        }

        #if DEBUG
        Tracker.shared.overrideAgent = NullAgent()
        #else
        Crashlytics.start(withAPIKey: ElloKeys().crashlyticsKey())
        #endif

        Keyboard.setup()
        Rate.sharedRate.setup()
        AutoCompleteService.loadEmojiJSON("emojis")
        UIFont.loadFonts()
        ElloLinkedStore.sharedInstance.writeConnection.readWrite { transaction in
            transaction.removeAllObjectsInAllCollections()
        }

        if AppSetup.sharedState.isTesting {
            if UIScreen.main.scale > 2 {
                fatalError("Tests should be run in a @2x retina device (for snapshot specs to work)")
            }

            if Bundle.main.bundleIdentifier != "co.ello.ElloDev" {
                fatalError("Tests should be run with a bundle id of co.ello.ElloDev")
            }
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            self.window = window
            return true
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = AppViewController()
        window.makeKeyAndVisible()
        self.window = window

        UIApplication.shared.statusBarStyle = .lightContent

        setupGlobalStyles()
        setupCaches()

        if let payload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            log(comment: "notification received \(Date())", object: payload)
            PushNotificationController.sharedController.receivedNotification(application, userInfo: payload)
        }

        return true
    }

    func setupGlobalStyles() {
        let font = UIFont.defaultFont()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.greyA()]
        UINavigationBar.appearance().barTintColor = UIColor.white

        let attributes = [
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)

        let normalTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont.defaultFont(11.0)
        ]
        let selectedTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(11.0)
        ]
        UISegmentedControl.appearance().setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        UISegmentedControl.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .normal, barMetrics: .default)
        UISegmentedControl.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.black), for: .selected, barMetrics: .default)

        // Kill all the tildes
        TimeAgoInWordsStrings.updateStrings(["about": ""])
    }

    func setupCaches() {
        let manager = PINRemoteImageManager.shared()
        let diskAgeLimit: TimeInterval = 1_209_600
        let diskByteLimit: UInt = 250_000_000
        let memoryByteLimit: UInt = 10_000_000
        manager.pinCache?.diskCache.ageLimit = diskAgeLimit
        manager.pinCache?.diskCache.byteLimit = diskByteLimit
        manager.pinCache?.memoryCache.costLimit = memoryByteLimit
        _ = CategoryService().loadCategories()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Tracker.shared.sessionEnded()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Tracker.shared.sessionStarted()
    }

}

// MARK: Notifications
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationController.sharedController.updateToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log(comment: "notification received \(Date())", object: userInfo)
        PushNotificationController.sharedController.receivedNotification(application, userInfo: userInfo)
        completionHandler(.noData)
    }
}

// MARK: URLs
extension AppDelegate {
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        guard
            let appVC = window?.rootViewController as? AppViewController
        else {
            return true
        }

        appVC.navigateToDeepLink(url.absoluteString)
        return true
    }
}

extension AppDelegate {

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if AppDelegate.restrictRotation {
                return .portrait
            }
            return .allButUpsideDown
        }
        return .all
    }
}


// universal links
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard
            let webpageURL = userActivity.webpageURL,
            let appVC = window?.rootViewController as? AppViewController,
            userActivity.activityType == NSUserActivityTypeBrowsingWeb
        else { return false }


        appVC.navigateToDeepLink(webpageURL.absoluteString)
        return true
    }
}
