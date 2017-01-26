//
//  MyProfileController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit


class ProfileViewController: PortraitViewController {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var btnWatching: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var lblPlaylistTitle: UILabel!
    @IBOutlet weak var imgProfileBorder: UIImageView!
    @IBOutlet weak var lblUserPoints: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var imgLogoSolo: UIImageView!
    
	
	let wsManager = WebserviceManager()
    
    var videos = [Video]()
	var playlists = [Playlist]()
    
	var userImageView: UIImageView!
	var backgroundImageView : UIImageView!
	var userInfoHeader: UserProfileHeader!
    
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var array_playlist = [Playlist]();
    var playlist_type = "Fav"
    var userPlaylistName : String!
	
	override func viewDidAppear(animated: Bool) {
        
		super.viewDidAppear(animated)
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        
        
        self.collectionView.reloadData();
        
        NSLog("Log")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.title = "Profile";
		noDataLabel.hidden = true
        
        let menuIcon = UIImage(named: "back")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(ProfileViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = menuButton;
        
        
//        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "showEdit:");
//        self.navigationItem.rightBarButtonItem = editButton;
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let imageWithShape = UIImage(named: "profile_mask")!
        let mask = CALayer()
        mask.contents = imageWithShape.CGImage
        mask.frame = imgLogoSolo.layer.bounds
        imgLogoSolo.layer.mask = mask
	}
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        setupUserInfo()
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ArtistPageViewController {
			destination.emnCategory = sender as! EMNCategory // items[indexPath.row]
			destination.isTitleHidden = false
		} else if let destination = segue.destinationViewController as? MyProfileInfoEditController {
            destination.user = Singleton.sharedInstance.user;
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {

		return true
	}
	
	@IBAction func editProfilePressed(sender: UIBarButtonItem) {

		
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
	
	@IBAction func cancelMenuViewControllerInProfile(segue: UIStoryboardSegue) {
		// DO-NOT DELETE! Needed as an exit-segue
	}
	
	func downloadImageForItem(item: Playlist, indexPath: NSIndexPath) {
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
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {

        self.collectionView.reloadData()

    }
    func showMenu(sender:AnyObject){
//        self.presentLeftMenuViewController(self)
//        self.sideMenuViewController.hideContentViewController()
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func showEdit(sender:AnyObject){
        self.performSegueWithIdentifier("editProfileTableSegue", sender: sender);
    }
    
    func downloadVideoImageForItem(item: Video, indexPath: NSIndexPath) {
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



extension ProfileViewController: UINavigationControllerDelegate {
	// TO-DO: VALIDAR QUE IMAGEPICKER REALMENTE HAGA USO DE ESTE DELEGADO
}
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
//        textField.borderStyle = UITextBorderStyle.None
        return true
    }
}
extension ProfileViewController: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ArtistVideoCell
        if(self.videos.count > 0){
            let video = videos[indexPath.row];
            cell.videoNameLabel.text = video.name;
            cell.artistNameLabel.text = video.artistName;
            cell.videoInfoLabel.text = "\(video.views) views";
            cell.detailButton.addTarget(self, action: #selector(ProfileViewController.watchVideoPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.detailButton.tag = indexPath.row
            cell.thumbnailImageView.image = nil
            cell.video = video
            cell.isPremiumVideo = false
            if (video.isEMG == true && Singleton.sharedInstance.user.subscriber() == false) {
                cell.imgPremium.image = UIImage(named: "premium_label")
                cell.isPremiumVideo = true
            }
            if let thumbnail = video.thumbnail {
                cell.thumbnailImageView.image = thumbnail
            } else {
                cell.activityIndicator.startAnimating()
                if collectionView.dragging == false && collectionView.decelerating == false {
                    downloadVideoImageForItem(video, indexPath: indexPath)
                }
            }
        }else{
            let item = playlists[indexPath.row]
            cell.artistNameLabel.text = item.name
            cell.videoNameLabel.text = "Created by ?"
            cell.videoInfoLabel.text = "Followers ?"
            cell.detailButton.addTarget(self, action: #selector(ProfileViewController.showPlaylistPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.thumbnailImageView.image = nil
            if let thumbnail = item.thumbnail {
                cell.thumbnailImageView.image = thumbnail
            } else {
                cell.activityIndicator.startAnimating()
                if collectionView.dragging == false && collectionView.decelerating == false {
                    downloadImageForItem(item, indexPath: indexPath)
                }
            }
        }
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header: UserProfileHeader!
		if kind == UICollectionElementKindSectionHeader {
			header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! UserProfileHeader
			userImageView = header.profilePictureImageView
			backgroundImageView = header.backgroundImageView
			//in the next secction we modify the profile photo by using a mask of the proper shape
			let imageWithShape = UIImage(named: "profile_mask")!
			let mask = CALayer()
			mask.contents = imageWithShape.CGImage
			mask.frame = userImageView.layer.bounds
			userImageView.layer.mask = mask
			//---------------------------------------------------
			userInfoHeader = header
            print("Collection view for supplementary elemnt of kind");
			setupUserInfo()
		}
		return header
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count > 0 ? videos.count : playlists.count;
	}
    func watchVideoPressed(sender:UIButton) {
//        let cell = sender.superview?.superview as? ArtistVideoCell
        let video = videos[sender.tag]
        
        if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
            self.showGoPremiumAlert()
            return
        }
        if Singleton.sharedInstance.isWatching == true {
            Singleton.sharedInstance.isWatchingBackground = true
        }
        if let cell = sender.superview?.superview as? ArtistVideoCell {
//            performSegueWithIdentifier("watchVideoSegue", sender: cell)
            var vc: UIViewController
            if let item = self.videos[sender.tag] as? Video{
                let className = NSStringFromClass(WatchingViewController).componentsSeparatedByString(".").last!
                vc = self.storyboard?.instantiateViewControllerWithIdentifier(className) as! WatchingViewController
                (vc as! WatchingViewController).playlist = [item.ooyalaId];
                (vc as! WatchingViewController).addVideoToDict(item);
                (vc as! WatchingViewController).fromSearch = true;
                (vc as! WatchingViewController).from = .Home;
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
        NSLog("log")
    }
	func showPlaylistPressed(sender: UIButton) {
		if let cell = sender.superview?.superview as? ArtistVideoCell {
			gotoPlaylist(cell)
		}
	}
	
	func gotoPlaylist(cell: UICollectionViewCell) {
        if(self.videos.count > 0){
            
        }else{
            if reachabilityHandler.verifyInternetConnection() == true {
                let indexPath = collectionView.indexPathForCell(cell)!
                let item = playlists[indexPath.row]
                wsManager.downloadImage2(item.imageURL, completionHandler: { (image) -> Void in
                    item.image = image ?? UIImage(named: "coverArt_grey_box")!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("showUserPlaylistSegue", sender: item)
                    })
                })
            }
            
        }
	}
	func setupUserInfo() {
        if self.videos.count == 0 {
            noDataLabel.hidden = false
        }
        let user = Singleton.sharedInstance.user
        print("Current User : \(user)")
        self.lblPlaylistTitle.text = self.userPlaylistName
		self.lblFullName.text =
            (Singleton.sharedInstance.user.firstName! + " " + Singleton.sharedInstance.user.lastName!).uppercaseString //"Paul David Hewson".uppercaseString
		self.lblUserPoints.text = (Singleton.sharedInstance.user.points! + " POINTS")  //.uppercaseString
        if(Singleton.sharedInstance.user.avatarImage != nil){
            self.imgLogoSolo.image = Singleton.sharedInstance.user.avatarImage;
        }else{
            if(Singleton.sharedInstance.user.avatarUrlString != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    let avatarUrl = NSURL(string: Singleton.sharedInstance.user.avatarUrlString!);
                    wsManager.downloadImage2(avatarUrl, completionHandler: { (image) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imgLogoSolo.image = image ?? UIImage(named: "logo_small")!
                            Singleton.sharedInstance.user.avatarImage = image;
                        });
                    });
                }
                
            }
        }
        if(Singleton.sharedInstance.user.coverImage != nil){
            self.backImage.image = Singleton.sharedInstance.user.coverImage;
        }else{
            if(Singleton.sharedInstance.user.coverPhotoUrlString != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    let coverUrl = NSURL(string: Singleton.sharedInstance.user.coverPhotoUrlString!);
                    wsManager.downloadImage2(coverUrl, completionHandler: { (image) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.backImage.image = image ?? UIImage(named: "graffiti.jpg")!
                            Singleton.sharedInstance.user.coverImage = image;
                        });
                    });
                }
                
            }
        }
        

	}
    func subScription(){
        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("Upgrade") as! UINavigationController
        self.sideMenuViewController.contentViewController = upgradeVC
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

extension ProfileViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(self.videos.count <= 0){
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            gotoPlaylist(cell)
        }else{
            let video = videos[indexPath.row]
            
            if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
                self.showGoPremiumAlert()
                return
            }
            if Singleton.sharedInstance.isWatching == true {
                Singleton.sharedInstance.isWatchingBackground = true
            }
            let watchingVC : WatchingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WatchingViewController") as! WatchingViewController;
            watchingVC.video = self.videos[indexPath.row];
            watchingVC.fromProfile = true;
            watchingVC.from = .MyPlaylist;
            
            var vs1 = [String](), vs2 = [String]()
            var total = 0
            for (index, video) in videos.enumerate() {
                if index < indexPath.row {
                    vs1 += [video.ooyalaId]
                } else {
                    if total <= 20 {
                        vs2 += [video.ooyalaId]
                        total += 1
                    }
                }
                watchingVC.addVideoToDict(video)
            }
            for v in vs1 {
                if vs2.count < 20 {
                    vs2 += [v]
                }else {
                    break
                }
            }
            watchingVC.playlist = vs2
            
            self.navigationController?.pushViewController(watchingVC, animated: true);
        }
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 70)
	}
	
}

extension ProfileViewController: UIScrollViewDelegate {
	
	func scrollViewDidEndDeceleaddrating(scrollView: UIScrollView) {
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
            if(self.videos.count > 0){
                let item = videos[indexPath.row]
                if let _ = item.thumbnail {
                    // thumbnail was already downloaded
                } else {
                    downloadVideoImageForItem(item, indexPath: indexPath)
                }
            }else{
                let item = playlists[indexPath.row]
                if let _ = item.thumbnail {
                    // thumbnail was already downloaded
                } else {
                    downloadImageForItem(item, indexPath: indexPath)
                }
            }
		}
	}
	
}
