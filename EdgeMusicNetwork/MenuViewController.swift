//
//  MenuViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/4/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


let visibleWidthForSlidingOutView: CGFloat = 50
let kHome = "home", kProfile = "profile", kAboutEdge = "about",  kLogout = "logout", kUpgrade = "upgrade", kResetPassword = "resetpass"

class MenuViewController: PortraitViewController, UINavigationControllerDelegate{
	
	private var isKeyboardVisible = false
    private var isLogout = false
	private let menuKeys  = [kHome, kProfile, kAboutEdge, kLogout, kUpgrade]
//    private let menuKeys  = [kHome, kProfile, kAboutEdge, kLogout, kUpgrade,kResetPassword]
//    private var menuName  = [kHome: "Home", kProfile: "My Profile", kAboutEdge: "About", kLogout: "Logout", kUpgrade:"Go Premium",kResetPassword:"Reset Password"]
    private var menuName  = [kHome: "Home", kProfile: "My Profile", kAboutEdge: "About", kLogout: "Logout", kUpgrade:"Go Premium"]
    private let menuImage = [kHome: "white_home", kProfile: "white_playlist", kAboutEdge: "white_object",  kLogout: "white_arrow", kUpgrade:"white_contact"]
//    private let menuImage = [kHome: "menu_home_light", kProfile: "menu_profile_light", kAboutEdge: "menu_help_light",  kLogout: "menu_logout_light", kUpgrade:"menu_upgrade_light", kResetPassword:"password"]
	private let wsManager = WebserviceManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    @IBOutlet weak var btnWatching: UIButton!
    var blurView : UIVisualEffectView!
	var searchController: UISearchController!
	var filteredData = [String: [AnyObject]]()
    //var filteredData = [];
	
	override func viewDidAppear(animated: Bool) {
		//println("[MVC] viewDidAppear")
		super.viewDidAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		//println("[MVC] viewDidLayoutSubviews")
		super.viewDidLayoutSubviews()
	}
	
	override func viewDidLoad() {
		//println("[MVC] viewDidLoad")
		super.viewDidLoad()
		
        self.tableView.backgroundColor = UIColor.clearColor();
        
        searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self;
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.searchBar.delegate = self;
        searchController.searchBar.barTintColor =  UIColor.whiteColor();
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal;
        searchController.searchBar.placeholder = "";
        searchController.searchBar.sizeToFit();
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark);
        let darkBlurView = UIVisualEffectView(effect: darkBlur);
        darkBlurView.frame = searchController.searchBar.bounds;
        darkBlurView.alpha = 0;
        self.blurView = darkBlurView;
        self.searchController.searchBar.insertSubview(self.blurView, atIndex: 0);
        
		tableView.tableHeaderView = searchController.searchBar
		definesPresentationContext = true
        // since the search view covers the table view when active we make the view controller define the presentation context
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: "ItemPurchased:", name: "ItemPurchaseNotification", object: nil)
        let cellOptionclassName = NSStringFromClass(MenuOptionCell).componentsSeparatedByString(".").last!;
        tableView.registerNib(UINib(nibName: cellOptionclassName, bundle: nil), forCellReuseIdentifier: "cellOption");
        let videoCellClass = NSStringFromClass(ArtistVideoTableCell).componentsSeparatedByString(".").last!;
        tableView.registerNib(UINib(nibName: videoCellClass, bundle:nil), forCellReuseIdentifier: "videoCell");
        tableView.tableFooterView = UIView();
        tableView.separatorColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.2);
        
        //Change text color for search bar
        for searchSubView in self.searchController.searchBar.subviews
        {
            for subView in searchSubView.subviews
            {
                if let textField = subView as? UITextField
                {
                    textField.attributedPlaceholder = NSAttributedString(string: "Search",
                        attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
                    textField.textColor = UIColor.lightGrayColor();
                }
            }
            if let button = searchSubView as? UIButton
            {
                button.titleLabel?.textColor = UIColor.lightGrayColor();
            }
        }
        
        
	}    
    deinit {
        if #available(iOS 9.0, *) {
            self.searchController.loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
        }
    }
	override func viewWillAppear(animated: Bool) {
		print("[MVC] viewWillAppear")
		super.viewWillAppear(animated)
        
        if (searchController.active && Singleton.sharedInstance.dontHideContentViewFromMenu == false) {
            let timer = NSTimer(timeInterval: 0.2, target: self.sideMenuViewController, selector: #selector(RESideMenu.hideContentViewController), userInfo: nil, repeats: false);
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        // Notification for dismissing Side menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        let user = Singleton.sharedInstance.user;
        if(user != nil){
            
            if(user.subscriptionType == "free"){
                if(Int(user.trialDaysLeft!) > 0){
                    Singleton.sharedInstance.isLoadPremiumVideo = true
                }else{
                    Singleton.sharedInstance.isLoadPremiumVideo = false
                }
            }else{
                Singleton.sharedInstance.isLoadPremiumVideo = true
            }
            
        }
        if Singleton.sharedInstance.user.subscriber() == true {
            menuName[kUpgrade] = "Manage Account"
            tableView.reloadData()
        }
        if Singleton.sharedInstance.isLoadPremiumVideo == true {
            
        }
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
		
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
		// NSNotificationCenter.defaultCenter().removeObserver(self, name: "dismissViews", object: nil)
	}
	
	/*override func prefersStatusBarHidden() -> Bool {
	return true
	}*/
//    func ItemPurchased(notification : NSNotification){
//        
//    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
//        self.collectionView.reloadData()
        tableView.reloadData()
    }
	func keyboardDidShow(notification: NSNotification) {
		if isKeyboardVisible {
			return
		}
		//let info = notification.userInfo as! [String: AnyObject]
		//let aValue = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
		//let keyboardRect = aValue.CGRectValue()
		//keyboardRect = view.convertRect(keyboardRect, fromView: nil)
		//tableViewBottomLayoutConstraint.constant = keyboardRect.size.height
		isKeyboardVisible = true
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if !isKeyboardVisible {
			return
		}
		//tableViewBottomLayoutConstraint.constant = 0
		isKeyboardVisible = false
	}
    
    func logout(){
        if isLogout == false {
            isLogout = true
            
            if reachabilityHandler.verifyInternetConnection() == true {
                FBSDKLoginManager().logOut();
                self.wsManager.logout(completionHandler: { (success, message) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if success {
                            print("[MVC] logged out")
                            Singleton.sharedInstance.user = nil;
                        } else {
                            print("[MVC] failed to logout user: \(message)")
                        }
                        Singleton.sharedInstance.watchingVC?.player?.pause()
                        Singleton.sharedInstance.watchingVC = nil
                        Singleton.sharedInstance.isWatching = false
                        //Dismiss the view
                        self.sideMenuViewController?.parentViewController?.navigationController?.popToRootViewControllerAnimated(false);
                        self.sideMenuViewController.dismissViewControllerAnimated(true, completion: nil);
                    });
                })
            }
            else {
                self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
                self.isLogout = false
            }
        }
    }
    @IBAction func goWatching(sender: AnyObject) {
        if Singleton.sharedInstance.watchingVC != nil {
            Singleton.sharedInstance.watchingVC?.fromSearch = true
            if Singleton.sharedInstance.watchingVC?.player?.isPlaying() == false {
                Singleton.sharedInstance.watchingVC?.player?.play()
            }
            let navVC = UINavigationController(rootViewController: Singleton.sharedInstance.watchingVC!);
            self.sideMenuViewController.contentViewController = navVC;
            self.sideMenuViewController.hideMenuViewController();
        } else {
            let alert = UIAlertController(title: "Unknown Error!", message:"There happens unknown error.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            // Add the actions
            alert.addAction(okAction)
            
            // Present the controller
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func upgrade(){
        if Singleton.sharedInstance.user.subscriber() == true {
            let user = Singleton.sharedInstance.user
            self.menuName[kUpgrade] = "Go Premium"
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
            
            let alert = UIAlertController(title: "Manage Subscription", message:"Downgrade subscription to the Basic plan?", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Downgrade", style: UIAlertActionStyle.Cancel){
                UIAlertAction in
                self.wsManager.downgradeBasicUser(user, completionHandler: { (success, message) -> Void in
                    NSLog("log")
                    if success == true{
                        
                        Singleton.sharedInstance.user.subscriptionType = "free"
                        if(Int(user.trialDaysLeft!) > 0){
                            Singleton.sharedInstance.isLoadPremiumVideo = true
                        }else{
                            Singleton.sharedInstance.isLoadPremiumVideo = false
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.presentViewController(self.alertControlerManager.alertForCancelSubscriptionMessage(), animated: true, completion: nil)
                            let notification = NSNotification(name: "DowngradeNotification", object: self, userInfo: nil)
                            NSNotificationCenter.defaultCenter().postNotification(notification)
                        })
                        
                    }else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.menuName[kUpgrade] = "Manage Account"
                            self.tableView.reloadData()
                            self.presentViewController(self.alertControlerManager.alertForCancelSubscriptionFailedMessage(), animated: true, completion: nil)
                        })
                        
                    }
                })
            }
            let cancelAction = UIAlertAction(title: "Keep Watching", style: UIAlertActionStyle.Default){
                UIAlertAction in
                self.menuName[kUpgrade] = "Manage Account"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
            // Add the actions
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpgradeVC") as! UpgradeViewController
            Singleton.sharedInstance.currentUpgradeFrom = .Home
            
            //        self.sideMenuViewController.contentViewController = upgradeVC
            self.presentViewController(upgradeVC, animated: true, completion: nil)
        }
    }
    func subScription(){
        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpgradeVC") as! UpgradeViewController
        Singleton.sharedInstance.currentUpgradeFrom = .Home
        self.presentViewController(upgradeVC, animated: true, completion: nil)
    }
    func showGoPremiumAlert(){
        let alert = UIAlertController(title: "Go Premium", message:"Watch premium videos and earn double points by upgrading your account.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "Go Premium", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.subScription()
        }
        
        // Add the actions
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // Present the controller
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}

extension MenuViewController: UITableViewDataSource {
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let searchController = searchController where searchController.active {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
			//println("[MVC] numberOfSectionsInTableView: \(filteredData.count) - search results")
			return filteredData.count
		} else {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.None
			//println("[MVC] numberOfSectionsInTableView: 1 - menu")
			return 1
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell
		if let searchController = searchController where searchController.active {
            let customCell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath) as! ArtistVideoTableCell;
			//let key = filteredData.keys.array[indexPath.section]
            let key = Array(filteredData.keys)[indexPath.section];
			let items: [AnyObject] = filteredData[key]!
			if let video = items[indexPath.row] as? Video {
                
                customCell.videoNameLabel.text = video.name
                customCell.artistNameLabel.text = video.artistName
                customCell.videoInfoLabel.text = "\(video.views) views"
                //customCell.detailButton.addTarget(self, action: "watchVideoPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                customCell.video = video
                customCell.isPremiumVideo = false
                if (video.isEMG == true && Singleton.sharedInstance.user.subscriber() == false) {
                    customCell.imgPremium.image = UIImage(named: "premium_label")
                    customCell.isPremiumVideo = true
                }
                customCell.thumbnailImageView.image = nil
                if let thumbnail = video.thumbnail {
                    customCell.thumbnailImageView.image = thumbnail
                } else {
                    customCell.activityIndicator.startAnimating()
                    downloadImageForItem(video, indexPath: indexPath)
                }
                
			} else {
				customCell.videoNameLabel.text = "not EMN Category"
			}
			cell = customCell
			//println("[MVC] cellForRowAtIndexPath: \(indexPath.section) - \(indexPath.row) - search results")
		} else {
			let customCell = tableView.dequeueReusableCellWithIdentifier("cellOption", forIndexPath: indexPath) as! MenuOptionCell
			customCell.menuLabel.text = menuName[menuKeys[indexPath.row]]
            customCell.backgroundColor = UIColor.clearColor();
			customCell.menuImageView.image = UIImage(named: menuImage[menuKeys[indexPath.row]]!)
			customCell.selectionStyle = UITableViewCellSelectionStyle.None
			cell = customCell
			//println("[MVC] cellForRowAtIndexPath: \(indexPath.section) - \(indexPath.row) - menu")
		}
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if let searchController = searchController where searchController.active {
			let key = Array(filteredData.keys)[section]
			//println("[MVC] numberOfRowsInSection: \(section) - key: \(key) - count: \(filteredData[key]?.count ?? 0) - search results")
			return filteredData[key]?.count ?? 0
		} else {
			//println("[MVC] numberOfRowsInSection: \(section) - count: \(menuKeys.count) - menu")
			return menuKeys.count
		}
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if let searchController = searchController where searchController.active {
			let view = UINib(nibName: "SearchResultTitleView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SearchResultTitleView
			view.titleLabel.text = Array(filteredData.keys)[section].uppercaseString
            view.backgroundColor = UIColor.darkGrayColor();
			return view
		}
		return UIView()
	}
	
}

extension MenuViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
		if !searchController.active {
			setupHighlighted(indexPath)
		}
	}
	
	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		if !searchController.active {
			setupUnhighlighted(indexPath)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let searchController = searchController where searchController.active {
			
            if !searchController.active {
                self.searchController!.searchBar.resignFirstResponder();
            }
            let key = Array(filteredData.keys)[indexPath.section];
            let items: [AnyObject] = filteredData[key]!
            let video = items[indexPath.row]
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
            
//			let key = Array(self.filteredData.keys)[indexPath.section]
//			let items: [AnyObject] = filteredData[key]!
			
			if let item = items[indexPath.row] as? EMNCategory {
                
				//println("[MVC] selected \(key): \(item.id) - \(item.name)")
                if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
                    self.showGoPremiumAlert()
                    return
                }
				var vc: UIViewController
				if let item = item as? Video {
                    if Singleton.sharedInstance.isWatching == true {
                        Singleton.sharedInstance.isWatchingBackground = true
                    }
					let className = NSStringFromClass(WatchingViewController).componentsSeparatedByString(".").last!
					vc = self.storyboard?.instantiateViewControllerWithIdentifier(className) as! WatchingViewController
                    (vc as! WatchingViewController).playlist = [item.ooyalaId];
                    (vc as! WatchingViewController).addVideoToDict(item);
                    (vc as! WatchingViewController).fromSearch = true;
                    (vc as! WatchingViewController).from = .Search;
                    Singleton.sharedInstance.dontHideContentViewFromMenu = true;
                    self.activityIndicator.stopAnimating()
                    let navVC = UINavigationController(rootViewController: vc);
                    self.sideMenuViewController.contentViewController = navVC;
                    self.sideMenuViewController.hideMenuViewController();
                    return;
				} else {
                    if Singleton.sharedInstance.isWatching == true {
                        Singleton.sharedInstance.isWatchingBackground = true
                    }
					let className = NSStringFromClass(ArtistPageViewController).componentsSeparatedByString(".").last!
					vc = self.storyboard?.instantiateViewControllerWithIdentifier(className) as! ArtistPageViewController
					(vc as! ArtistPageViewController).emnCategory = item
                    (vc as! ArtistPageViewController).from = .Search;
				}
                if reachabilityHandler.verifyInternetConnection() == true {
                    activityIndicator.startAnimating()
                    wsManager.downloadImage2(item.imageURL, completionHandler: { (image) -> Void in
                        //item.image = image
                        item.image = image ?? UIImage(named: "coverArt")!
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.activityIndicator.stopAnimating()
                            let navVC = UINavigationController(rootViewController: vc);
                            self.sideMenuViewController.contentViewController = navVC;
                            self.sideMenuViewController.hideMenuViewController();
                        })
                    })
                }
            }
            return
		}
		
        switch menuKeys[indexPath.row] {
        case kProfile:
            if reachabilityHandler.verifyInternetConnection() == true {
                let profileFlow = self.storyboard?.instantiateViewControllerWithIdentifier("Profile") as! UINavigationController
                //var profileVC = profileFlow.viewControllers[0] as! ProfileViewController
                
                self.wsManager.getUserData(completionHandler: { (user) -> Void in
                    if let user = user {
                        print("User: \(user)")
                        
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.sideMenuViewController.contentViewController = profileFlow
                            self.sideMenuViewController.hideMenuViewController()
                        })
                    } else {
                        print("something went wrong. please try again")
                    }
                })
            }else{
                self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
            }
            break;
            /*
        case kHelp:
            let helpFlow = self.storyboard?.instantiateViewControllerWithIdentifier("Help") as! UINavigationController
            self.sideMenuViewController.contentViewController = helpFlow
            self.sideMenuViewController.hideMenuViewController()
            break;
*/
        case kAboutEdge:
            let settingsFlow = self.storyboard?.instantiateViewControllerWithIdentifier("Settings") as! UINavigationController
            self.sideMenuViewController.contentViewController = settingsFlow
            self.sideMenuViewController.hideMenuViewController()
            break;
        case kHome:
            let watchingFlow = self.storyboard?.instantiateViewControllerWithIdentifier("Watching") as! UINavigationController
            self.sideMenuViewController.contentViewController = watchingFlow
            self.sideMenuViewController.hideMenuViewController()
            break;
        case kLogout:
            self.logout()
            break;
        case kUpgrade:
            self.upgrade()
            break;
//        case kResetPassword:
//            let myDetailView  = self.storyboard?.instantiateViewControllerWithIdentifier("UpdatePass") as! UINavigationController
//            Singleton.sharedInstance.updatePasswordFromMenu = true
//            self.sideMenuViewController.contentViewController = myDetailView
//            self.sideMenuViewController.hideMenuViewController()
//            break;
        default:
            
            break;
        }
        
        return
	}
	
	func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		if !searchController.active {
			setupUnhighlighted(indexPath)
        }
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if let searchController = searchController where searchController.active {
			return 77
		} else {
			return 50
		}
	}
	
	func setupHighlighted(indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! MenuOptionCell
		cell.menuImageView.image = UIImage(named: menuImage[menuKeys[indexPath.row]]! + "_light")
	}
	
	func setupUnhighlighted(indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! MenuOptionCell
		cell.menuImageView.image = UIImage(named: menuImage[menuKeys[indexPath.row]]!)
	}
	
	func compareItPresentingView(presentingView: UIViewController, selectedView: AnyClass) -> Bool{
		
        if let navController = presentingView as? UINavigationController {
            return self.compareItPresentingView(navController.viewControllers[0] , selectedView: selectedView)
        }
        
		if presentingView.isKindOfClass(selectedView) {
			return true
		}
		return false
	}
    
    func downloadImageForItem(item: Video, indexPath: NSIndexPath) {
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.downloadImage2(item.thumbnailURL, completionHandler: { (image) -> Void in
                //item.thumbnail = image
                item.thumbnail = image ?? UIImage(named: "coverArt")!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ArtistVideoTableCell { // cell is nil for cells not visible in screen
                        cell.activityIndicator.stopAnimating()
                        cell.thumbnailImageView.image = item.thumbnail
                    }
                })
            })
        }
        
    }
}

extension MenuViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        //let rect :CGRect = self.sideMenuViewController.contentViewController.view.frame;
        //let temp = NSStringFromCGRect(rect);
//        self.sideMenuViewController.hideContentViewController();
        
        UIView.animateWithDuration(1.0, animations: {
            self.blurView.alpha = 1.0;
        });
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        //let rect :CGRect = self.sideMenuViewController.contentViewController.view.frame;
        //let temp = NSStringFromCGRect(rect);
        return true;
    }
    
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if reachabilityHandler.verifyInternetConnection() == true {
            //println("[MVC] searchBarSearchButtonClicked")
            activityIndicator.startAnimating()
            let searchString = searchController.searchBar.text
            //println("[MVC] search for: \(searchString)")
            
            wsManager.searchForMediaMatching(searchString!, completionHandler: { (itemsDictionary: [String: [AnyObject]]) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //println("[MVC] search results items: \(itemsDictionary.count)")
                    self.activityIndicator.stopAnimating()
                    self.filteredData = itemsDictionary
//                    self.sideMenuViewController.hideContentViewController()
                    self.tableView.reloadData();
//                    self.sideMenuViewController.hideContentViewController()
                    Singleton.sharedInstance.currentSearchQuery = searchString;
                })
            })
        }else{
            self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
        }
		
	}
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredData = [String: [AnyObject]]();
		self.activityIndicator.stopAnimating()
//        self.sideMenuViewController.showContentViewController();
        UIView.animateWithDuration(0.35, animations: {
            self.blurView.alpha = 0.0;
        });
        Singleton.sharedInstance.currentSearchQuery = "";        
		//println("[MVC] searchBarCancelButtonClicked")
	}
	
}

extension MenuViewController: UISearchResultsUpdating {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		tableView.reloadData()
		//println("[MVC] updateSearchResultsForSearchController - reloaded data")
	}
	
}

