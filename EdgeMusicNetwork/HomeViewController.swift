//
//  HomeViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/8/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import StoreKit

private let kPlaylists = "playlists", kChannels = "channels", kMoods = "moods"

class HomeViewController: PortraitViewController {
	
	private let sections = [kPlaylists, kChannels, kMoods]
	private let sectionTitles = [kPlaylists: "Watch Vradio", kChannels: "Watch by Channels", kMoods: "Watch by Mood"]
	private let sectionTypes = [kPlaylists: EMNCategoryType.Playlist, kChannels: EMNCategoryType.Channel, kMoods: EMNCategoryType.Mood]
	private let titleWidth: CGFloat = 150
	private var setup = false
	private var blankSpaceWidth: CGFloat!
	private var slideMenuAnimator = SlideMenuAnimator()
	private var wsManager: WebserviceManager!
    private var isLoading = false
    var isItemPurchased = false
    var currentIndex : Int!
    private var menuShownTapGestureCloseMenu: UITapGestureRecognizer!
    var isChangedDevice : Bool!
    var currentDeviceMode : String = String()
    var currentUIOrientation : UIDeviceOrientation!
	
    @IBOutlet weak var indicator: UIImageView!
	@IBOutlet weak var menuScrollView: UIScrollView!
	@IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var btnWatching: UIButton!
    
    private var navBarHairline : UIImageView!
    var purchaseManager:IAPManager!
    private var alertControlerManager : AlertControllerManager = AlertControllerManager()
    
	var menuOptions: [SubmenuOptionView] = []
	var currentPage = 1
    
    func showTrial()
    {
        let trialVC = self.storyboard!.instantiateViewControllerWithIdentifier("trialLeft");
        let navVC = UINavigationController(rootViewController: trialVC);
        self.presentViewController(navVC, animated: true, completion: nil);
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        isLoading = false
     	wsManager = WebserviceManager()
        for aView: UIView in self.navigationController!.navigationBar.subviews {
            for bView: UIView in aView.subviews {
                if bView.dynamicType === UIImageView() {
                    if((bView.bounds.size.width == self.navigationController!.navigationBar.frame.size.width) && bView.bounds.size.height < 2){
                        self.navBarHairline = bView as! UIImageView;
                    }
                }
            }
        }
        
        if(self.navBarHairline != nil){
            self.navBarHairline.hidden = true;
        }
        purchaseManager = Singleton.sharedInstance.iapManager
        let user = Singleton.sharedInstance.user;
        if(user != nil){
            if(Singleton.sharedInstance.user.retrievedFavorites == false){
                wsManager.getUserFavoriteVideos(completionHandler: { (items) -> Void in
                    if(Singleton.sharedInstance.user != nil){
                        Singleton.sharedInstance.user.favorites = items;
                        Singleton.sharedInstance.user.retrievedFavorites = true;
                    }
                });
            }
            
            if(user.subscriptionType == "free"){
                if(Int(user.trialDaysLeft!) > 0){
                    Singleton.sharedInstance.isLoadPremiumVideo = true
                    let trialDaysLeft = "Trial: \(user.trialDaysLeft!) days left";
                    let trialButton = UIBarButtonItem(title: trialDaysLeft, style: .Plain, target: self, action: #selector(HomeViewController.showTrial));
                    self.navigationItem.rightBarButtonItem = trialButton;
                }else{
                    Singleton.sharedInstance.isLoadPremiumVideo = false
                    let rightIcon = UIBarButtonItem(title: "Go Premium", style: .Plain, target: self, action: #selector(HomeViewController.subScription))
                    self.navigationItem.rightBarButtonItem = rightIcon
                }
            }else{
                Singleton.sharedInstance.isLoadPremiumVideo = true
            }
            
            wsManager.getUserPlaylists(completionHandler: { (playlists) -> Void in
                if (Singleton.sharedInstance.userPlaylists.count > 0){
                    Singleton.sharedInstance.userPlaylists = [];
                }
                Singleton.sharedInstance.userPlaylists = playlists as [NSDictionary]
            })
            
        }
        
        let menuIcon = UIImage(named: "hamburger_menu")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(HomeViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = menuButton
        /*
        var backIcon = UIImage(named: "back")
        var backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: nil, action:nil)
        self.navigationItem.backBarButtonItem = backButton
        */
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        self.navigationItem.title = " "
        
        let titleIcon = UIImage(named: "logo_small")
        let titleIconIV = UIImageView(image: titleIcon)
        titleIconIV.frame = CGRectMake(0, 0, 15.0, 25.0)
        titleIconIV.contentMode = .ScaleAspectFit
        //titleIconIV.backgroundColor = UIColor.blackColor()
        self.navigationItem.titleView = titleIconIV
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.ItemPurchased(_:)), name: "ItemPurchaseNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.SubscriptionDowngrade(_:)), name: "DowngradeNotification", object: nil)
        self.currentUIOrientation = UIDevice.currentDevice().orientation
        if UIDevice.currentDevice().orientation.isLandscape == true {
            Singleton.sharedInstance.currentScreenMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            Singleton.sharedInstance.currentScreenMode = "Portrait"
        } else {
            Singleton.sharedInstance.currentScreenMode = "Other"
        }
        
	}
    
	override func viewWillAppear(animated: Bool) {
        isLoading = false
		super.viewWillAppear(animated)
        if isItemPurchased {
            self.navigationItem.rightBarButtonItem = nil
        }
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        let user = Singleton.sharedInstance.user;
        if(user != nil){
            if(Singleton.sharedInstance.user.retrievedFavorites == false){
                wsManager.getUserFavoriteVideos(completionHandler: { (items) -> Void in
                    if(Singleton.sharedInstance.user != nil){
                        Singleton.sharedInstance.user.favorites = items;
                        Singleton.sharedInstance.user.retrievedFavorites = true;
                    }
                });
            }
            
            if(user.subscriptionType == "free"){
                if(Int(user.trialDaysLeft!) > 0){
                    Singleton.sharedInstance.isLoadPremiumVideo = true
                    let trialDaysLeft = "Trial: \(user.trialDaysLeft!) days left";
                    let trialButton = UIBarButtonItem(title: trialDaysLeft, style: .Plain, target: self, action: #selector(HomeViewController.showTrial));
                    self.navigationItem.rightBarButtonItem = trialButton;
                }else{
                    Singleton.sharedInstance.isLoadPremiumVideo = false
                    let rightIcon = UIBarButtonItem(title: "Go Premium", style: .Plain, target: self, action: #selector(HomeViewController.subScription))
                    self.navigationItem.rightBarButtonItem = rightIcon
                }
            }else{
                Singleton.sharedInstance.isLoadPremiumVideo = true
            }
            
        }
        
	}
	
	override func viewDidAppear(animated: Bool) {
        isLoading = false
		super.viewDidAppear(animated)
        
        var screenMode:String!
        if UIDevice.currentDevice().orientation.isLandscape == true {
            screenMode = "Landscape"
        } else if UIDevice.currentDevice().orientation == .Portrait {
            screenMode = "Portrait"
        } else {
            screenMode = "Other"
        }
        if Singleton.sharedInstance.currentDeviceReload == true {
            if currentIndex == nil {
                currentIndex = 2
            }
            initScrollView()
            self.buildScrollView()
            //println("[HVC] menu size: \(menuScrollView.contentSize), content size: \(contentScrollView.contentSize)")
            
//            menuOptions[currentIndex - 1].isActive = true
//            scrollToPage((CGFloat(currentIndex) - 1), animated: false)
            Singleton.sharedInstance.currentDeviceReload = false
            return
        }
        if Singleton.sharedInstance.currentDeviceReload == false && screenMode != Singleton.sharedInstance.currentScreenMode && Singleton.sharedInstance.currentHomeFromBack == true {
            if currentIndex == nil {
                currentIndex = 2
            }
            initScrollView()
            self.buildScrollView()
            //println("[HVC] menu size: \(menuScrollView.contentSize), content size: \(contentScrollView.contentSize)")
//            menuOptions[1].isActive = true
//            currentIndex = 2
//            scrollToPage(2, animated: false)
            return
        }
		if !setup {
			setup = true
			//println("[HVC] setup")
            currentIndex = 2
			self.buildScrollView()
			//println("[HVC] menu size: \(menuScrollView.contentSize), content size: \(contentScrollView.contentSize)")
			menuOptions[1].isActive = true
			scrollToPage(2, animated: false) //show Channels at the beginning
		}
//        menuOptions[1].isActive = true
//        currentIndex = 2
//        scrollToPage(2, animated: false) //show Channels at the beginning
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if !isLoading{
            if let destination = segue.destinationViewController as? ArtistPageViewController {
                destination.emnCategory = sender as! EMNCategory // sender => items[indexPath.row]
                destination.isTitleHidden = sender as? Playlist == nil
                destination.from = .Home;
                isLoading = true
            }
        }
        
		
	}
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return !isLoading
    }
    func buildScrollView() {
        blankSpaceWidth = (menuScrollView.bounds.width - titleWidth) / 2
        //println("[HVC] blankSpace width: \(blankSpaceWidth)")
        let menuHeight = menuScrollView.frame.height
        var x1: CGFloat = 0, x2: CGFloat = 0
        
        let spaceAtStart = UIView(frame: CGRect(x: x1, y: 0, width: blankSpaceWidth, height: menuHeight))
        //spaceAtStart.backgroundColor = UIColor.orangeColor()
        menuScrollView.addSubview(spaceAtStart)
        x1 += blankSpaceWidth
        
        for index in 0..<sections.count {
            // adding title
            let nib = NSBundle.mainBundle().loadNibNamed("SubmenuOptionView", owner: self, options: nil)
            let submenuView = nib[0] as! SubmenuOptionView
            submenuView.frame = CGRect(x: x1, y: 0, width: titleWidth, height: menuHeight)
            submenuView.setTitle(sectionTitles[sections[index]]!)
            submenuView.addTarget(self, action: #selector(HomeViewController.changeToPage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            menuOptions += [submenuView]
            menuScrollView.addSubview(submenuView)
            
            x1 += titleWidth
            
            // adding content
            let className = NSStringFromClass(EMNCategoryViewController).componentsSeparatedByString(".").last!
            let vc = storyboard?.instantiateViewControllerWithIdentifier(className) as! EMNCategoryViewController
            vc.view.frame = CGRect(origin: CGPoint(x: x2, y: 0), size: CGSize(width: contentScrollView.bounds.width, height: contentScrollView.bounds.height))
            
            vc.categoryType = sectionTypes[sections[index]]!
            vc.refreshData()
            
            x2 += vc.view.bounds.width
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            contentScrollView.addSubview(vc.view)
        }
        
        let spaceAtEnd = UIView(frame: CGRect(x: x1, y: 0, width: blankSpaceWidth, height: menuHeight))
        //spaceAtEnd.backgroundColor = UIColor.redColor()
        menuScrollView.addSubview(spaceAtEnd)
        x1 += blankSpaceWidth
        
        menuScrollView.contentSize = CGSize(width: x1, height: menuHeight)
        contentScrollView.contentSize = CGSize(width: x2, height: contentScrollView.frame.size.height)
        let x: CGFloat = titleWidth * (CGFloat(currentIndex) - 0.5) + blankSpaceWidth - (menuScrollView.bounds.width / 2)
        contentScrollView.setContentOffset(CGPoint(x: contentScrollView.bounds.width * (CGFloat(currentIndex) - 1), y: 0), animated: false)
        menuScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        for (index, option) in menuOptions.enumerate() {
            option.isActive = index + 1 == currentIndex ? true : false
        }
    }
    func initScrollView () {
        for  spaceAtEnd : UIView in self.menuScrollView.subviews  {
            spaceAtEnd.removeFromSuperview()
        }
        
        for emnView : UIView in self.contentScrollView.subviews {
            emnView.removeFromSuperview()
        }
        
        self.menuOptions = []
        contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        menuScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        Singleton.sharedInstance.currentHomeFromBack = false
    }
	func changeToPage(menuOption: SubmenuOptionView) {
		for (index, option) in menuOptions.enumerate() {
			if option == menuOption {
//                self.currentIndex = (index + 1)
				scrollToPage(CGFloat(index + 1), animated: true)
				break
			}
		}
	}
    
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self)
        self.sideMenuViewController.hideContentViewController()
    }
    
    func subScription(){
        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpgradeVC") as! UpgradeViewController
        Singleton.sharedInstance.currentUpgradeFrom = .Home
        self.presentViewController(upgradeVC, animated: true, completion: nil)
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
//        self.collectionView.reloadData()
        self.initScrollView()
        self.buildScrollView()
        if UIDevice.currentDevice().orientation.isLandscape == true {
            Singleton.sharedInstance.currentScreenMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            Singleton.sharedInstance.currentScreenMode = "Portrait"
        } else {
            Singleton.sharedInstance.currentScreenMode = "Other"
        }
    }
    func goBack()
    {
        print("Going back");
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    func SubscriptionDowngrade (notofication : NSNotification) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            let rightIcon = UIBarButtonItem(title: "Go Premium", style: .Plain, target: self, action: #selector(HomeViewController.subScription))
            self.navigationItem.rightBarButtonItem = rightIcon
        }
    }
    
    @IBAction func goWatching(sender: AnyObject) {
        if Singleton.sharedInstance.watchingVC != nil {
            Singleton.sharedInstance.watchingVC?.fromSearch = false
            if Singleton.sharedInstance.watchingVC?.player?.isPlaying() == false {
                Singleton.sharedInstance.watchingVC?.player?.play()
            }
            self.navigationController?.pushViewController(Singleton.sharedInstance.watchingVC!, animated: true)
        } else {
            let alert = UIAlertController(title: "Unknown Error!", message:"There happens unknown error.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            // Add the actions
            alert.addAction(okAction)
            
            // Present the controller
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func ItemPurchased(notification : NSNotification){
        isItemPurchased = true
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
//                    dismissViewControllerAnimated(true, completion: nil)
                    self.goBack()
                }
                let cancelAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
//                    Singleton.sharedInstance.iapManager.buyProduct(0)
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

extension HomeViewController: UIScrollViewDelegate {
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		//println("[HVC] endDragging offset: \(scrollView.contentOffset) willDecelerate: \(decelerate)")
		if scrollView == menuScrollView {
			if !decelerate {
				let offsetInTitles = menuScrollView.contentOffset.x + (menuScrollView.bounds.width / 2) - blankSpaceWidth
				let page = floor(offsetInTitles / titleWidth ) + 1
				//println("[HVC] page: \(page)")
				scrollToPage(page, animated: true)
			}
		}
	}
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		//println("[HVC] EndDecelerating offset: \(scrollView.contentOffset)")
		if scrollView == menuScrollView {
			let offsetInTitles = menuScrollView.contentOffset.x + (menuScrollView.bounds.width / 2) - blankSpaceWidth
			let page = floor(offsetInTitles / titleWidth ) + 1
			//println("[HVC] page: \(page)")
			scrollToPage(page, animated: true)
		} else if scrollView == contentScrollView {
			let page = floor(contentScrollView.contentOffset.x / contentScrollView.bounds.width) + 1
			//println("[HVC] page: \(page)")
			scrollToMenu(page)
		}
	}
	
	func scrollToPage(page: CGFloat, animated: Bool) {
		//_ = menuScrollView.frame
		let x: CGFloat = titleWidth * (page - 0.5) + blankSpaceWidth - (menuScrollView.bounds.width / 2) // page - 0.5 to account for positioning in the middle of the selected page
		menuScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        currentIndex = Int(page)
		contentScrollView.setContentOffset(CGPoint(x: contentScrollView.bounds.width * (page - 1), y: 0), animated: animated)
		
		for (index, option) in menuOptions.enumerate() {
			option.isActive = CGFloat(index + 1) == page ? true : false
		}
	}
	
	func scrollToMenu(page: CGFloat) {
		let x: CGFloat = titleWidth * (page - 0.5) + blankSpaceWidth - (menuScrollView.bounds.width / 2) // page - 0.5 to account for positioning in the middle of the selected page
		menuScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
		currentIndex = Int(page)
		for (index, option) in menuOptions.enumerate() {
			option.isActive = CGFloat(index + 1) == page ? true : false
		}
	}
	
}
