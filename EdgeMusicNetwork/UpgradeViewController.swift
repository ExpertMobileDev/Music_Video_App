//
//  UpgradeViewController.swift
//  emn
//
//  Created by mac on 2/17/16.
//  Copyright © 2016 Angel Jonathan GM. All rights reserved.
//

import UIKit

class UpgradeViewController: PortraitViewController {
    private var isLoading = false
    private var isItemPurchased = false
    private var purchaseManager : IAPManager!
    private var alertViewController : AlertControllerManager = AlertControllerManager()
    private let screenSize = UIScreen.mainScreen().bounds.size
    private let wsManager = WebserviceManager()
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnNoThanksContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let menuIcon = UIImage(named: "hamburger_menu")
//        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: "showMenu:")
//        self.navigationItem.leftBarButtonItem = menuButton
        let backIcon = UIImage(named: "back")
        let backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action:#selector(UpgradeViewController.goBack))
        self.navigationItem.leftBarButtonItem = backButton
        purchaseManager = Singleton.sharedInstance.iapManager
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UpgradeViewController.ItemPurchased(_:)), name: "ItemPurchaseNotification", object: nil)
        
//        let image = UIImage(named: "upgrade_background")
//        let imgSize = image?.size
//        var imvWidth,imvHeight : CGFloat!
//        if ( (imgSize?.height)! / (imgSize?.width)!) > (screenSize.height / screenSize.width) {
//            imvHeight = screenSize.height
//            imvWidth = imvHeight * (screenSize.width / screenSize.height)
//        }else {
//            imvWidth = screenSize.width
//            imvHeight = imvWidth * (screenSize.height / screenSize.width)
//        }
//        let frame = CGRectMake((screenSize.width - imvWidth) / 2, (screenSize.height - imvHeight), imvWidth, imvHeight)
//        self.imgBackground.frame = frame
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self)
    }
    func goBack()
    {
        print("Going back");
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func actionCancel(sender: AnyObject) {

        self.goBack()
    }
    @IBAction func actionUpgrade(sender: AnyObject) {
        self.purchaseManager.buyProduct(0)
    }
    
    func ItemPurchased(notification : NSNotification){
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        if (userInfo.objectForKey("Type") != nil){
            let purchaseType = userInfo.objectForKey("Type") as! String
            if purchaseType == "Purchased" {
                isItemPurchased = true
                let user = Singleton.sharedInstance.user
                self.wsManager.upgradePremiumUser(user, completionHandler: { (success, message) -> Void in
                    if success == true {
                        Singleton.sharedInstance.user.subscriptionType = "premium"
                        Singleton.sharedInstance.isLoadPremiumVideo = true
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertController(title: "Purchase", message : "Item purchase successful!.", preferredStyle: UIAlertControllerStyle.Alert )
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel){
                                UIAlertAction in
                                self.goBack()
                            }
                            
                            // Add the actions
                            alert.addAction(okAction)
                            
                            // Present the controller
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                })
                
            }else if purchaseType == "Failed" {
                let alert = UIAlertController(title: "Are You Sure", message : "Item Purchase Failed.", preferredStyle: UIAlertControllerStyle.Alert )
                let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){
                     UIAlertAction in
                    self.goBack()
                }
                let cancelAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.purchaseManager.buyProduct(0)
                }
                
                // Add the actions
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alert, animated: true, completion: nil)
            }else if purchaseType == "Restored" {
                let alert = UIAlertController(title: "Restored", message : "Item purchase restored.", preferredStyle: UIAlertControllerStyle.Alert )
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                // Add the actions
                alert.addAction(okAction)
                
                // Present the controller
                self.presentViewController(alert, animated: true, completion: nil)
            }else if purchaseType == "Deferred" {
                let alert = UIAlertController(title: "Deferred", message : "Item purchase deferred.", preferredStyle: UIAlertControllerStyle.Alert )
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                // Add the actions
                alert.addAction(okAction)
                
                // Present the controller
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } 
        
        
    }
}
