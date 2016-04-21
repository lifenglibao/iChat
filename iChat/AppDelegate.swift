//
//  AppDelegate.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var webSocket: SRWebSocket!
    var IS_LOGIN = Bool()
    var SELF_USER_ID : String = ""
    var SELF_USER_NAME : String = ""
    var SELF_USER_AVATAR : String = ""
    var CHAT_LIST_DATA = NSMutableArray()
    var GROUP_FRIEND_DATA = NSMutableArray()
    var GROUP_NAME_STRING : String = ""

    func openWebSocket () {
        self.webSocket = SRWebSocket.init(URL: NSURL.init(string: API_URL))
        self.webSocket.open()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Override point for customization after application launch.

        openWebSocket()
        chkAndCreateDirectory()
        let vc = GET_VIEW_CONTROLLER("ViewController")
        let navController = UINavigationController.init(rootViewController: vc)
        navController.navigationBar.barTintColor = RGBA_ALPHA(0.071, G: 0.060, B: 0.086, A: 1.0)
        navController.navigationBar.tintColor    = UIColor.whiteColor()
        //        UINavigationBar.appearance().barTintColor = RGBA_ALPHA(0.071, G: 0.060, B: 0.086, A: 1.0)
        //        UINavigationBar.appearance().tintColor    = UIColor.whiteColor()
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()

        if #available(iOS 8.0, *) {
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        } else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        if let launchOptions = launchOptions {
            let notificationPayload: NSDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary!
            self.application(application, didReceiveRemoteNotification: notificationPayload as [NSObject : AnyObject] )
        }
        
        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        var deviceTokenString :String = "\(deviceToken)"
        
        deviceTokenString     = deviceTokenString.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceTokenString     = deviceTokenString.stringByReplacingOccurrencesOfString(">", withString: "")
        deviceTokenString     = deviceTokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let userDefault       = NSUserDefaults()
        userDefault.setValue(deviceTokenString, forKey: "user_device_token")
        userDefault.synchronize()
        
        print("deviceToken:\n----\(userDefault.valueForKey("user_device_token") as! String)----")
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        //        application.applicationIconBadgeNumber = 0
        //
        //        pushUserInfo = userInfo["aps"]!["alert"]!!.description
        //
        //
        //        if application.applicationState == UIApplicationState.Active {
        //
        //            //            alertViewHelper.showAlert("", msg: pushUserInfo as! String, dgt: self, cancelTitle: "Close", otherTitle: "View Now")
        //            //            alertViewHelper.showAlert("", msg: pushUserInfo as! String, dgt: self, cancelTitle: "Ok")
        //
        //        }else{
        //            let rootViewController        = self.window!.rootViewController as! UINavigationController
        //            notificationsHelper.readNotification(rootViewController)
        //        }
    }
    
    
    func chkAndCreateDirectory() {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let dataPath = documentsDirectory.stringByAppendingPathComponent("iChat")
        print("Destination Path----",dataPath)
        
        let fileManger = NSFileManager.defaultManager()
        
        if (!fileManger.fileExistsAtPath(dataPath)) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            } catch {
                print("general error - \(error)", terminator: "\n")
            }
        }
        
        
        let destinationPath = getdestinationPath()
        
        if (fileManger.fileExistsAtPath(destinationPath)) {
            return
        }else {
            
            let sourcePath = (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent("iChat.sqlite")
            do {
                try fileManger.copyItemAtPath(sourcePath, toPath: destinationPath)
                print("success copy item to path!!!")
            } catch let error as NSError {
                print(error.localizedDescription)
            } catch {
                print("general error - \(error)", terminator: "\n")
            }
        }
    }

    func getdestinationPath ()->String {
        
        let pathsArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let doumentDirectoryPath = pathsArray[0] as NSString
        let destinationPath = doumentDirectoryPath.stringByAppendingPathComponent("iChat/iChat.sqlite")
        
        print("Destination Path----",destinationPath)
        
        return destinationPath
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        if (self.webSocket.readyState == .CLOSING || self.webSocket.readyState == .CLOSED){
            openWebSocket()
        }
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if (self.webSocket.readyState == .CLOSING || self.webSocket.readyState == .CLOSED){
            openWebSocket()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

