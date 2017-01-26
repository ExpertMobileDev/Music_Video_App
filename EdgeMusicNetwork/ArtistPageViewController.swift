//
//  ArtistPageViewController.swift
//  EdgeMusicNetwork
//
//  Created by Angel Jonathan GM on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class ArtistPageViewController: PortraitViewController {
	
	private var wsManager = WebserviceManager()
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnWatching: UIButton!
	
    var emnCategory: EMNCategory!;
    var isFromUpgrade = false
    var from :VideoWatchFrom?;
    var videos = [Video]();
    var isTitleHidden = true;
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
	override func prefersStatusBarHidden() -> Bool {
		return false
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
        Singleton.sharedInstance.player = nil;
		//UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
//        Singleton.sharedInstance.sendReportsInQueue();
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
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        
        self.collectionView.reloadData()
//        if Singleton.sharedInstance.isLoadPremiumVideo == true {
//            self.collectionView.reloadData()
//        }
//        self.collectionView.reloadData()
		//UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        print("Navigation controller = \(self.navigationController)")
    
        //self.navigationController?.navigationBar
        self.title = emnCategory.name;
        if isFromUpgrade == true {
            let menuIcon = UIImage(named: "back")
            let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(ArtistPageViewController.showMenu(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }else{
            let backIcon = UIImage(named: "back")
            let backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action:#selector(ArtistPageViewController.goBack))
            self.navigationItem.leftBarButtonItem = backButton
        }
//        self.navigationItem.backBarButtonItem?.title = " "
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		var type: EMNCategoryType?
		if let _ = emnCategory as? Channel {
			type = EMNCategoryType.Channel
			//titleLabel.text = "Channel's Page"
		} else if let _ = emnCategory as? Mood {
			type = EMNCategoryType.Mood
			//titleLabel.text = "Mood's Page"
		} else if let _ = emnCategory as? Playlist {
			type = EMNCategoryType.Playlist
			//titleLabel.text = "Playlist's Page"
		}
		if let type = type {
            if reachabilityHandler.verifyInternetConnection() == true {
                wsManager.getVideosInEMNCategoryItem(emnCategory.id, type: type) { (items) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.videos = items
                        self.collectionView.reloadData()
                    })
                }
            }
			
		}
        if UIDevice.currentDevice().orientation.isLandscape == true {
            Singleton.sharedInstance.currentArtistMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            Singleton.sharedInstance.currentArtistMode = "Portrait"
        } else {
            Singleton.sharedInstance.currentArtistMode = "Other"
        }
        
	}    
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destination = segue.destinationViewController as? WatchingViewController {
            destination.emnCategory = self.emnCategory;
            destination.from = self.from;
			let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)!
			var vs1 = [String](), vs2 = [String]()
			var total = 0
			for (index, video) in videos.enumerate() {
				//if total <= 20 {
					if index < indexPath.row {
						vs1 += [video.ooyalaId]
					} else {
                        if total <= 20 {
                            vs2 += [video.ooyalaId]
                            total += 1
                
                        }
						
					}
                
				//} else {
				//	break
				//}
               destination.addVideoToDict(video)
			}
            for v in vs1 {
                if vs2.count < 20 {
                    // add elments
                    vs2 += [v]
                    
                }else {
                    break
                }

            }
             destination.playlist = vs2
			//let playlist = destination.organizePlaylist(videos, indexOfSelectedItem: indexPath.row)
			//destination.playlist = playlist
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
	@IBAction func backPressed(sender: UIBarButtonItem) {
		emnCategory.image = nil
		dismissViewControllerAnimated(true, completion: nil)
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
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
        if UIDevice.currentDevice().orientation.isLandscape == true {
            Singleton.sharedInstance.currentArtistMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            Singleton.sharedInstance.currentArtistMode = "Portrait"
        } else {
            Singleton.sharedInstance.currentArtistMode = "Other"
        }
        self.collectionView.reloadData()
    }
    func showMenu(sender:AnyObject)
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Watching") as! UINavigationController
        self.sideMenuViewController.contentViewController = vc
        self.sideMenuViewController.hideContentViewController()
    }
    
    func goBack()
    {
        print("Going back");
        var currentMode : String!
        if UIDevice.currentDevice().orientation.isLandscape == true {
            currentMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            currentMode = "Portrait"
        } else {
            currentMode = "Other"
        }
        if currentMode != Singleton.sharedInstance.currentArtistMode {
            Singleton.sharedInstance.currentDeviceReload = true
        }
        Singleton.sharedInstance.currentHomeFromBack = true
        self.navigationController?.popViewControllerAnimated(true)
    }
	func downloadImageForItem(item: Video, indexPath: NSIndexPath) {
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.downloadImage2(item.thumbnailURL, completionHandler: { (image) -> Void in
                //item.thumbnail = image
                item.thumbnail = image ?? UIImage(named: "coverArt")!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? ArtistVideoCell { // cell is nil for cells not visible in screen
                        cell.activityIndicator.stopAnimating()
                        cell.thumbnailImageView.image = item.thumbnail
                    }
                })
            })
        }
		
	}
	
}

extension ArtistPageViewController: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let video = videos[indexPath.row]
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!  ArtistVideoCell
        cell.videoNameLabel.text = video.name;
        cell.artistNameLabel.text = video.artistName;
		cell.videoInfoLabel.text = "\(video.views) views";
        cell.detailButton.addTarget(self, action: #selector(ArtistPageViewController.watchVideoPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        cell.video = video
        cell.detailButton.tag = indexPath.row
        cell.isPremiumVideo = false
        if (video.isEMG == true && Singleton.sharedInstance.user.subscriber() == false) {
            cell.imgPremium.image = UIImage(named: "premium_label")
            cell.isPremiumVideo = true
        }
        
        cell.thumbnailImageView.image = nil;
		if let thumbnail = video.thumbnail {
			cell.thumbnailImageView.image = thumbnail
		} else {
			cell.activityIndicator.startAnimating()
			if collectionView.dragging == false && collectionView.decelerating == false {
				downloadImageForItem(video, indexPath: indexPath)
			}
		}
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		if kind == UICollectionElementKindSectionHeader {
			let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! ArtistVideoHeader
			header.artistNameLabel.text = self.emnCategory.name.uppercaseString
			header.artistNameLabel.hidden = isTitleHidden
			header.artistImageView.image = self.emnCategory.image
			view = header
		}
		return view
	}
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
        return CGSizeMake(UIScreen.mainScreen().bounds.size.width, 70)
    }
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return videos.count
	}
	
	func watchVideoPressed(sender: UIButton) {
        let video = videos[sender.tag]
        if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
            self.showGoPremiumAlert()
            return
        }
        if Singleton.sharedInstance.isWatching == true {
            Singleton.sharedInstance.isWatchingBackground = true
        }
		if let cell = sender.superview?.superview as? ArtistVideoCell {
			performSegueWithIdentifier("watchVideoSegue", sender: cell)
		}
	}
    func subScription(){
//        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("Upgrade") as! UINavigationController
//        Singleton.sharedInstance.currentUpgradeFrom = .Artist
//        Singleton.sharedInstance.currentUpgradeFromCategoryPrev = self.emnCategory
//        self.sideMenuViewController.contentViewController = upgradeVC
        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpgradeVC") as! UpgradeViewController
        Singleton.sharedInstance.currentUpgradeFrom = .Home
        
        //        self.sideMenuViewController.contentViewController = upgradeVC
        self.presentViewController(upgradeVC, animated: true, completion: nil)
    }
}

extension ArtistPageViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		NSLog("log")
        let video = videos[indexPath.row]
        
        if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
            self.showGoPremiumAlert()
            return
        }
        if Singleton.sharedInstance.isWatching == true {
            Singleton.sharedInstance.isWatchingBackground = true
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ArtistVideoCell
        performSegueWithIdentifier("watchVideoSegue", sender: cell)
	}
	
	/*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
	return 2
	}*/
	
	/*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
	return 2
	}*/
	
	
	
}

extension ArtistPageViewController: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if scrollView == collectionView {
			loadOnScreenCellsThumbnails()
		}
	}
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if scrollView == collectionView && !decelerate { // scrollview is stopped
			loadOnScreenCellsThumbnails()
		}
	}
	
	func loadOnScreenCellsThumbnails() {
		for indexPath in collectionView.indexPathsForVisibleItems() {
			let video = videos[indexPath.row]
			if let _ = video.thumbnail {
				// thumbnail was already downloaded
			} else {
				downloadImageForItem(video, indexPath: indexPath)
			}
		}
	}
	
}
