//
//  AppDelegate.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/2/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
 		let storyboard = UIStoryboard(name: "Edge", bundle: nil)
        
        print("[AppDelegate] Creating disk cache");
        let URLCache = NSURLCache(memoryCapacity: 6 * 1024 * 1024, diskCapacity: 32 * 1024 * 1024, diskPath: "ImageDownloadCache");
        NSURLCache.setSharedURLCache(URLCache);
        
        print("[AppDelegate] Opening login flow")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Login") as! UINavigationController
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
   		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default        
		
        let systemTintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        UINavigationBar.appearance().tintColor = systemTintColor
        
        //UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "Gotham-Book", size: 15)]
        
        let navbarFont = UIFont(name: "Gotham-Book", size: 15) ?? UIFont.systemFontOfSize(13)
        let barbuttonFont = UIFont(name: "Gotham-Book", size: 13) ?? UIFont.systemFontOfSize(12)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:systemTintColor]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: barbuttonFont, NSForegroundColorAttributeName:systemTintColor], forState: UIControlState.Normal)

        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clearColor();
        
		//print("[AppDelegate] bundle ID: \(NSBundle.mainBundle().bundleIdentifier)")
		return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Singleton.sharedInstance.unPauseWhenBackground = true;
        print("BACKGROUNDED");
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print("[APP DELEGATE] OpenURL - Url: \(url)");
		return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	

}
