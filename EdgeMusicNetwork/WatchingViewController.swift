//
//  WatchingViewController.swift
//  EdgeMusicNetwork
//
//  Created by Angel Jonathan GM on 6/16/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import MediaPlayer
import GoogleInteractiveMediaAds

class WatchingViewController: UIViewController
{
	private var isExpanded = true
	private var wsManager = WebserviceManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var fromSearch = false;
    var fromProfile = false;
    var isFavorite = false;
    var isFirstLoad = false;
    var isPremiumPrev = false;
    var from: VideoWatchFrom?;
    var emnCategory: EMNCategory?
    var player:EdgeOOPlayer?;
    var adsManager:OOIMAManager?;
    
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader:IMAAdsLoader?
    var adsM : IMAAdsManager?
    
	@IBOutlet weak var videoView: UIView!
	@IBOutlet weak var videoActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var collapseExpandButton: UIButton!
    @IBOutlet weak var thumbUpToggleButton: UIButton!
	@IBOutlet weak var videoNameLabel: UILabel!
	@IBOutlet weak var videoInfoLabel: UILabel!
	@IBOutlet weak var videoDescriptionTextview: UITextView!
	@IBOutlet weak var videoDescriptionView: UIView!
	@IBOutlet weak var videoViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoInfoLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var recomendationsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addPlaylistButton: UIButton!
    @IBOutlet weak var vwAddPlaylist: UIView!
    @IBOutlet weak var userlist_collectionView: UICollectionView!
    @IBOutlet weak var vwCreatePlaylist: UIView!
    @IBOutlet weak var txtPlaylistName: UITextField!
    
    
    var playingAd: Bool = false;
	
	let PCODE = "p1YTAyOkAHioMfsu3I8Rnv04telJ"
	let PLAYERDOMAIN = "http://www.ooyala.com"

    let LIVERAIL_ID = "66684"
	
    var playlistIndex = 0;
    
    var isFromUpgrade = false
    
	var history = [[String]]()
    var basic_history = [[String]]()
	var playlist = [String]()
    var basic_playlist = [String]()
	var recommendedVideosPlaylist = [String]()
	var videos = [String: Video]()
    var video : Video! 
	var customInlineIOS7ViewController: InlineIOS7ViewController?
	var playerViewController : PlayerViewController!
    var iapImageView:UIImageView!
    var adPlugin : OOManagedAdsPlugin!
    var showingShare: Bool = false;
    var showingAddPlaylist: Bool = false;
    var userplaylists = [NSDictionary]()
    var userFavoriteId : String!
    
    let kTestAppAdTagUrl =
    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&" +
        "iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&" +
        "output=vast&unviewed_position_start=1&" +
    "cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=";
	
	override func viewDidLoad()
    {
		super.viewDidLoad()
        self.playingAd = false;
        
        
        let shareIcon = UIImage(named: "btn_share");
        let shareButton = UIBarButtonItem(image: shareIcon, style: .Plain, target: self, action: #selector(WatchingViewController.shareVideo(_:)));
        self.navigationItem.rightBarButtonItem = shareButton;
        
        self.thumbUpToggleButton.hidden = true;
        self.thumbUpToggleButton.enabled = false;
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		videoView.subviews[0].removeFromSuperview() // we remove the image inside the videoView before set up the Ooyala video
        
        self.userlist_collectionView.alpha = 0
//        self.userlist_collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "playlistCell")
		expandCollapse(animated: false)
        self.spliteFavFromUserList()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
		let player = EdgeOOPlayer(pcode: PCODE, domain: OOPlayerDomain(string: PLAYERDOMAIN))
        self.player = player;
//        self.player.isShowingAdWithCustomControls = false
        
        /*
        var options = OOOptions();
        options.showPromoImage = true;
        */
        //Create the IMA Ad Manager
        
            //[[OOIMAManager alloc] initWithOoyalaPlayer:ooyalaPlayerViewController.player];
        
        playerViewController = PlayerViewController(player: player)
        customInlineIOS7ViewController = InlineIOS7ViewController(controlsType: .Inline, player: player, overlay: nil, delegate: playerViewController);
        
        //customInlineIOS7ViewController!.view!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4);
        
		addChildViewController(playerViewController)
//		videoView.addSubview(playerViewController.view)
        videoView.insertSubview(playerViewController.view, belowSubview: self.vwAddPlaylist)
        self.vwAddPlaylist.alpha = 0
        
        self.vwAddPlaylist.layer.cornerRadius = 8;
        self.vwAddPlaylist.clipsToBounds = true;
        
		playerViewController.view.frame = videoView.bounds
        
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WatchingViewController.playerStatus(_:)), name: nil, object: playerViewController.player)
		
        playerViewController.setInlineViewController(customInlineIOS7ViewController)
		//setupPlayingVideoInfo(playlist[0])
//        playerViewController.hideControls()
        playerViewController.showControls()
//        let controlls : ControlsViewController = playerViewController.getControls() as ControlsViewController

        
        //Reset interface
        videoNameLabel.text = "";
        videoDescriptionTextview.text = "";
        videoInfoLabel.text = "";
        videoDescriptionTextview.text = "";
        videoDescriptionTextview.text = "";
        
        //Setup Ads
        if Singleton.sharedInstance.isLoadPremiumVideo == false {
            self.adsManager = OOIMAManager(ooyalaPlayer:self.player);
//            self.adsManager?.adUrlOverride = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/7521029/pb_preroll_ad&ciu_szs&impl=s&cmsid=949&vid=FjbGRjbzp0DV_5-NtXBVo5Rgp3Sj0R5C&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]"
        }
        self.get_basic_playlists()
        
        
        
        Singleton.sharedInstance.player = playerViewController;
        
        if Singleton.sharedInstance.isLoadPremiumVideo == false {
            playVideos(basic_playlist)
        } else {
            playVideos(playlist)
        }
        
        
        //playVideo(playlist[self.playlistIndex]);
        
        
	}
    func setUpContentPlayer() {
        
    }
    func setUpAdsLoader() {
//        IMASettings
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader!.delegate = self
    }
    func requestAds() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: videoView, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
//        let request = IMAAdsRequest(
//            adTagUrl: kTestAppAdTagUrl,
//            adDisplayContainer: adDisplayContainer,
//            contentPlayhead: contentPlayhead,
//            userContext: nil)
//        
//        adsLoader!.requestAdsWithRequest(request)
        let request = IMAAdsRequest(adTagUrl: self.kTestAppAdTagUrl, adDisplayContainer: adDisplayContainer, userContext: nil)
        adsLoader!.requestAdsWithRequest(request)
    }
    func get_basic_playlists() {
        if(self.playlist.count > 0) {
            for embedCode in self.playlist {
                if let video = videos[embedCode] {
                    video.isEMG = video.isEMGTag()
                    if video.isEMG == false {
                        self.basic_playlist.append(embedCode)
                    }
                }
            }
        }
        NSLog("Log")
    }
	override func viewWillAppear(animated: Bool)
    {
		super.viewWillAppear(animated)
        if(self.fromSearch == true){
            print("Changing dont hide content view from menu to true");
            Singleton.sharedInstance.dontHideContentViewFromMenu = true;
        }
        if(self.fromSearch == true)
        {
            let menuIcon = UIImage(named: "hamburger_menu")
            let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(WatchingViewController.showMenu(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }else{
            let backIcon = UIImage(named: "back")
            let backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action:#selector(WatchingViewController.goBack))
            self.navigationItem.leftBarButtonItem = backButton
        }
        self.showingShare = false;
        print("View will appear");
        if(self.video != nil){
            self.isFavorite = Singleton.sharedInstance.user.indexOfFavoriteVideo(self.video) != nil ? true : false;
            self.updateLikeInterface();
        }
//        if (self.player?.isPlaying() == true && Singleton.sharedInstance.isWatchingBackground == true){
//            NSLog("log")
//            Singleton.sharedInstance.isWatchingBackground = false
//        }
        if (Singleton.sharedInstance.watchingVC != nil && Singleton.sharedInstance.isWatchingBackground == true ) {
            NSLog("log")
            Singleton.sharedInstance.watchingVC?.player?.pause()
            Singleton.sharedInstance.watchingVC = nil
            Singleton.sharedInstance.isWatchingBackground = false
            
//            self.userlist_collectionView.reloadData()
        }
        
        let user = Singleton.sharedInstance.user;
        if(user != nil){
            self.spliteFavFromUserList()
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
        
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        //Force portrait when we come out of fullscreen
        let value = UIInterfaceOrientation.Portrait.rawValue;
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents();
        self.becomeFirstResponder();
        
        if Singleton.sharedInstance.isLoadPremiumVideo == true {
            self.collectionView.reloadData()
        }
//        self.collectionView.reloadData()
	}
	
	override func viewWillDisappear(animated: Bool)
    {
        if(self.showingShare == false){
            print("Removing current report");
//            Singleton.sharedInstance.currentReport = nil;
//            Singleton.sharedInstance.sendReportsInQueue();
        }
		super.viewWillDisappear(animated)
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
		//NSNotificationCenter.defaultCenter().removeObserver(self)
        
        UIApplication.sharedApplication().endReceivingRemoteControlEvents();
        self.resignFirstResponder();
        
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
		if fromInterfaceOrientation.isPortrait {
			playerViewController.setFullscreen(true)
		} else {
			playerViewController.setFullscreen(false)
		}
		self.view.setNeedsLayout()
	}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let destination = segue.destinationViewController as? ShareViewController {
            destination.video = video;
            destination.fromProfile = self.fromProfile;
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if(event?.type == .RemoteControl){
            if(event?.subtype == .RemoteControlStop){
                self.player?.pause();
            }
            if(event?.subtype == .RemoteControlPause){
                self.player?.pause();
            }
            if(event?.subtype == .RemoteControlPlay){
                self.player?.play();
            }
            if(event?.subtype == .RemoteControlNextTrack){
                self.player?.nextVideo();
            }
            if(event?.subtype == .RemoteControlPreviousTrack){
                self.player?.previousVideo();
            }
            if(event?.subtype == .RemoteControlTogglePlayPause){
                if(self.player?.isPlaying() == true){
                    self.player?.pause();
                }else{
                    self.player?.play();
                }
            }
        }
        
    }
    func spliteFavFromUserList() {
        self.userplaylists = [NSDictionary]()
        if (Singleton.sharedInstance.userPlaylists.count > 0){
            for index in 0..<Singleton.sharedInstance.userPlaylists.count{
                let dict = Singleton.sharedInstance.userPlaylists[index] as NSDictionary;
                let item = dict.objectForKey("user_playlist") as! NSDictionary;
                let name = item.objectForKey("name") as! String
                if (name == "Favorites") {
                    self.userFavoriteId = item.objectForKey("id") as! String
                }
                else {
                    self.userplaylists.append(item)
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.userlist_collectionView.reloadData()
            })
        } else {
            
            wsManager.createUserPlaylistURL("Favorites", completionHandler: { (success, message, root) in
                NSLog("Log");
            })
            
//            wsManager.createUserPlaylistURL("Favorites", completionHandler: { (root) -> Void in
//                NSLog("Log");
//            })
//            wsManager.createUserPlaylistURL("Favorites", completionHandler: { (playlistId) -> Void in
//                if playlistId.characters.count > 0 {
//                    self.userFavoriteId = playlistId;
//                }
//            })
        }
    }
    func subScription(index: Int){
        let upgradeVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpgradeVC") as! UpgradeViewController
        Singleton.sharedInstance.currentUpgradeFrom = .Home
        
        //        self.sideMenuViewController.contentViewController = upgradeVC
        self.presentViewController(upgradeVC, animated: true, completion: nil)
    }
    func showGoPremiumAlert(index: Int) {
        let alert = UIAlertController(title: "Go Premium", message:"Watch premium videos and earn double points by upgrading your account.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "Go Premium", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.subScription(index)
        }
        
        // Add the actions
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // Present the controller
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    @IBAction func shareVideo(sender: UIBarButtonItem)
    {
        if(self.video != nil){
            self.showingShare = true;
            self.performSegueWithIdentifier("showShareSegue", sender: sender);
        }
    }
    
    @IBAction func actionCreatePlaylist(sender: UIButton) {
        if (self.txtPlaylistName.text != nil) {
            self.vwCreatePlaylist.alpha = 0
            let playlistName = self.txtPlaylistName.text
            self.view.endEditing(true)
            
            wsManager.createUserPlaylistURL(playlistName!, completionHandler: { (success, message, root) in
                if success == true {
                    let items = root as [NSDictionary]
                    if items.count > 0 {
                        Singleton.sharedInstance.userPlaylists = items
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.txtPlaylistName.text = "";
                            self.spliteFavFromUserList()
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: "Error", message: message!, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })
            
//            wsManager.createUserPlaylistURL(playlistName!, completionHandler: { (root) -> Void in
//                
//                let items = root as [NSDictionary]
//                if items.count > 0 {
//                    Singleton.sharedInstance.userPlaylists = items
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.txtPlaylistName.text = "";
//                        self.spliteFavFromUserList()
//                    })
//                }
//                
//            })
            
        }
        
    }
    @IBAction func actionPlaylist(button: UIButton) {
        if (button.tag == 1) {
            self.userlist_collectionView.alpha = 1
        }
        if (button.tag == 2) {
            self.vwCreatePlaylist.alpha = 1
            
        }
        self.vwAddPlaylist.alpha = 0
    }
    @IBAction func actionAddPlaylist(sender: AnyObject) {
        self.vwAddPlaylist.alpha = 1;
    }
    @IBAction func toggleLike(sender: UIButton)
    {
        if(self.video != nil){
            isFavorite = !isFavorite;
            if(isFavorite == true){
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.addVideoToUserPlaylist(Singleton.sharedInstance.user, video: video);
                }
                Singleton.sharedInstance.user.addVideoToFavorites(video);
            }else{
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.removeVideoFromUserPlaylist(Singleton.sharedInstance.user, video: video);
                }
                Singleton.sharedInstance.user.removeVideoFromFavorites(video);
            }
            self.updateLikeInterface();            
        }
    }
    
    private func updateLikeInterface()
    {
        let thumbUp : UIImage = UIImage(named: "blue_fav_small")!;
        let filledThumbUp : UIImage = UIImage(named: "blue_fav_full")!;
        if(isFavorite == false){
            //turn it off
            thumbUpToggleButton.setImage(thumbUp, forState: .Normal);
            thumbUpToggleButton.setImage(filledThumbUp, forState: .Selected);
        }else{
            thumbUpToggleButton.setImage(filledThumbUp, forState: .Normal);
            thumbUpToggleButton.setImage(thumbUp, forState: .Selected);
        }
        self.thumbUpToggleButton.hidden = false;
        self.thumbUpToggleButton.enabled = true;
    }
	@IBAction func expandCollapsePressed(sender: UIButton)
    {
		expandCollapse(animated: true)
	}
	
    /* NOTIFICATIONS */
	func playerStatus(notification: NSNotification)
    {
        if(notification.name == "adStarted"){
            if(Singleton.sharedInstance.user.subscriber() == true){
                print("Skipping ad");
                self.playerViewController!.player.skipAd();
                return;
            }
            
            self.playingAd = true;
            //If an ad started, remove the current report
            //which will allow it to be sent to the server
//            Singleton.sharedInstance.currentReport = nil;
        }
        if(notification.name == "adCompleted"){
            self.playingAd = false;
//            Singleton.sharedInstance.currentReport = nil;
        }
        
        customInlineIOS7ViewController!.changeTimerForVideo()
		if notification.name == OOOoyalaPlayerTimeChangedNotification {
            if(Singleton.sharedInstance.currentReport != nil && self.playingAd == false){
                Singleton.sharedInstance.addOoyalaSecondToCurrentReport();
            }
            return;
		}
        
		
		print("[WVC] notification: \(notification.name)")
        
        if(notification.name == "stateChanged" && Singleton.sharedInstance.unPauseWhenBackground == true){
            print("[WVC] Unpausing play for background");
            self.player?.play();
            let delay = 1.8 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                Singleton.sharedInstance.unPauseWhenBackground = false;
            }
            return;
        }
		
		if let op = notification.object as? OOOoyalaPlayer {
			let ooyalaVideo = op.currentItem
            if notification.name == OOOoyalaPlayerCurrentItemChangedNotification {
                NSLog("Item Change!");
                if let video = videos[ooyalaVideo.embedCode] {
                    if isFirstLoad == false{
                        setupPlayingVideoInfo(ooyalaVideo.embedCode)
                        isFirstLoad = true
                    }else{
                        self.video = video
                        updateVideoInfo(video)
                    }
                }else{
                    print("[WVC] failed to find video information")
                    self.player?.nextVideo()
                }
                if (Singleton.sharedInstance.currentReport != nil){
                    let videoSecs = Singleton.sharedInstance.currentReport?.quarterSeconds
                    let videoDuration = Singleton.sharedInstance.currentReport?.video.duration
                    let testValue = float_t(float_t(videoSecs!) / float_t(videoDuration! * 4))
                    let percentageWatched : float_t = testValue * 100
                    if percentageWatched >= 25 {
                        Singleton.sharedInstance.sendReportsInQueue();
                    }
                }
            } else if notification.name == OOOoyalaPlayerPlayStartedNotification {
                NSLog("Player start!");
//                self.insertAd();
            } else if notification.name == OOOoyalaPlayerPlayCompletedNotification {
                NSLog("Player completed!");
                self.player?.nextVideo()
            }
        
		}
        if(notification.name == "playStarted" && self.playingAd == false)
        {
            //MARK
            Singleton.sharedInstance.addTimerForVideo(self.video, from: self.from!);
            Singleton.sharedInstance.currentReport?.currentQuarterSeconds = 0;
            Singleton.sharedInstance.currentReport?.quarterSeconds = 0;
            if(self.emnCategory != nil){
                Singleton.sharedInstance.currentReport?.category = self.emnCategory!;
            }
            Singleton.sharedInstance.currentReport?.from = self.from!;
        }
	}
	
	/* Methods */
	func addVideoToDict(video: Video)
    {
		if let _ = videos[video.ooyalaId] {
			// do nothing, video already in list
		} else {
			videos[video.ooyalaId] = video
		}
	}
	
	func downloadImageForItem(item: Video, indexPath: NSIndexPath)
    {
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
        
    func showMenu(sender:AnyObject)
    {
        Singleton.sharedInstance.isWatching = true
        Singleton.sharedInstance.watchingVC = self
        Singleton.sharedInstance.player = nil;        
        self.presentLeftMenuViewController(self)
        self.sideMenuViewController.hideContentViewController()
    }
	
	func expandCollapse(animated animated: Bool)
    {
        var constant1: CGFloat = 0
        var constant2: CGFloat = 0
        if isExpanded {
            isExpanded = false
            collapseExpandButton.setImage(UIImage(named: "button_collapse"), forState: UIControlState.Normal)
            constant1 = 61
            constant2 = 0
        } else {
            isExpanded = true
            collapseExpandButton.setImage(UIImage(named: "button_expand"), forState: UIControlState.Normal)
//            videoInfoLabel.sizeToFit();
//            videoDescriptionTextview.sizeToFit();
//            constant = videoInfoLabel.frame.size.height + 10 + videoDescriptionTextview.frame.size.height + 10;
            constant1 = 129;
//            videoDescriptionTextview.sizeToFit()
            constant2 = 60
        }
//        if(constant > 250){
//            constant = 250;
//        }
        videoInfoLabelHeightConstraint.constant = constant2;
        videoViewHeightConstraint.constant = constant1;
        
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded() // it's videoDescriptionView.superview
            })
        } else {
            self.view.layoutIfNeeded()
        }
	}
	
	func loadRecommendationForVideo(video: Video)
    {
        if reachabilityHandler.verifyInternetConnection() == true {
            recomendationsActivityIndicator.startAnimating()
            wsManager.getRecommendationsFromVideo(video.id, completionHandler: { (videos) -> Void in
                self.recommendedVideosPlaylist = [String]()
                for video in videos {
                    self.recommendedVideosPlaylist += [video.ooyalaId]
                    self.addVideoToDict(video)
                }
                //println("[WVC] new history has: \(videoIds.count)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.recomendationsActivityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                })
            })
        }
		
	}
/* test row */
	func organizePlaylist(playlist: [String], indexOfSelectedItem: Int) -> [String]
    {
		var vs1 = [String](), vs2 = [String]()
		var total = 0
		for (index, ooyalaId) in playlist.enumerate() {
			if total <= 20 {
				if index < indexOfSelectedItem {
					vs1 += [ooyalaId]
				} else {
					vs2 += [ooyalaId]
				}
				total += 1
			} else {
				break
			}
		}
		return vs2 + vs1
	}
    func organizeBasicPlaylist(playlist: [String], indexOfSelectedItem: Int) -> [String]
    {
        var vs1 = [String](), vs2 = [String]()
        var total = 0
        for (index, ooyalaId) in playlist.enumerate() {
            if total <= 20 {
                if let video = self.videos[ooyalaId] {
                    video.isEMG = video.isEMGTag()
                    if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true) {
                        continue
                    } else {
                        if index < indexOfSelectedItem {
                            
                            vs1 += [ooyalaId]
                        } else {
                            vs2 += [ooyalaId]
                        }
                        total += 1
                    }
                } else {
                    continue
                }
            } else {
                break
            }
            
        }
        return vs2 + vs1
    }
	/*
	func playVideo(video: Video)
    {
		//load video
        if(Singleton.sharedInstance.user.subscriber() == true){
            print("SKIPPING ADS by unsetting the adset code FROM PLAY VIDEO");
            ooyalaPlayerViewController.player.setEmbedCode(video.ooyalaId, adSetCode: "632d6b243d554e35b373da1dca2fafc3");
        }else{
            ooyalaPlayerViewController.player.setEmbedCode(video.ooyalaId) //[playlist.first!])
        }
        
		//play video
        ooyalaPlayerViewController.player.play();
        //insert ad
        insertAd();
	}
*/

	func playVideos(playlist: [String])
    {
        /*
        if(Singleton.sharedInstance.user.subscriber() == true){
            print("SKIPPING ADS by unsetting the adset code FROM PLAY VIDEOS");
            ooyalaPlayerViewController.player.setEmbedCodes(playlist, adSetCode: "632d6b243d554e35b373da1dca2fafc3");
        }else{
            ooyalaPlayerViewController.player.setEmbedCodes(playlist) //[playlist.first!])
        }
        */
        self.player?.settingNewPlaylist = true;
        self.player?.playlist = playlist;
        self.player?.playlistIndex = 0;
        playerViewController.player.play();
//        insertAd();
	}
	
	func setupPlayingVideoInfo(ooyalaId: String)
    {
		if let video = videos[ooyalaId] {
            self.video = video
			updateVideoInfo(video)
			loadRecommendationForVideo(video)
		} else {
			print("[WVC] failed to find video information")
            isPremiumPrev = false
		}
	}
	
	func updateVideoInfo(video: Video)
    {
        self.title = video.artistName;
		videoNameLabel.text = video.name
        
        isFavorite = Singleton.sharedInstance.user?.indexOfFavoriteVideo(video) == nil ? false : true;
        self.updateLikeInterface();
        
		videoDescriptionTextview.text = "Artist: " + video.artistName + "\r\n"
        videoInfoLabel.text = "\(video.views) views | \(video.points) points"
		if !video.genre.isEmpty {
			videoDescriptionTextview.text = "\(videoDescriptionTextview.text)Genre: " + video.genre + "\r\n";
		}
        if(videoDescriptionTextview.text.characters.count > 100){
            videoDescriptionTextview.text = "\(videoDescriptionTextview.text)" + video.videoDescription + "\r\n\r\n\r\n\r\n\r\n";
        }else{
            videoDescriptionTextview.text = "\(videoDescriptionTextview.text)" + video.videoDescription + "\r\n\r\n";
        }
		videoDescriptionTextview.scrollRangeToVisible(NSMakeRange(0, 1))// scrollRectToVisible(CGRectZero, animated: false)
        
        //Send the reporting queue now that we have a new video playing (This sends the last video info)
//        if(Singleton.sharedInstance.currentReport != nil && Singleton.sharedInstance.currentReport?.quarterSeconds > 0 && isPremiumPrev == true){
//            Singleton.sharedInstance.sendReportsInQueue();
//        }
//        isPremiumPrev = true
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            let albumArt = MPMediaItemArtwork(image: video.thumbnail ?? UIImage(named: "coverArt")!)
            let songInfo = [
                MPMediaItemPropertyTitle: video.name,
                MPMediaItemPropertyArtist: video.artistName,
                MPMediaItemPropertyArtwork: albumArt
            ]
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo;
        }
        
	}
    
    func goBack()
    {
        print("Going back");
        Singleton.sharedInstance.isWatching = true
        Singleton.sharedInstance.watchingVC = self
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func insertAd()
    {
        if(self.adPlugin != nil){
            
            print("[AD CODE!!!!] Inserting ad");
            let time = NSNumber(double: playerViewController.player.playheadTime());
//            let vastUrl = NSURL(string: "http://www.google.com/adsense/start/?show_no_account_dialog=true#?modal_active=none");
//            let vastUrl = NSURL(string: "http://xd-team.ooyala.com.s3.amazonaws.com/ads/VastAd_Preroll.xml");
            let vastUrl = NSURL(string: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/7521029/pb_preroll_ad&ciu_szs&impl=s&cmsid=949&vid=FjbGRjbzp0DV_5-NtXBVo5Rgp3Sj0R5C&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]")
            let ad : OOVASTAdSpot = OOVASTAdSpot(time: time, clickURL: nil, trackingURLs: nil, vastURL: vastUrl);
            adPlugin.insertAd(ad);
        }
    }
}

extension WatchingViewController: UICollectionViewDataSource
{
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell
        if collectionView == self.collectionView {
            let videoOoyalaId = recommendedVideosPlaylist[indexPath.row]
            let video = videos[videoOoyalaId]! //videos[indexPath.row]
            let customcell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!  ArtistVideoCell
            customcell.backgroundView?.backgroundColor = UIColor.orangeColor()// UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
            customcell.backgroundColor = UIColor.greenColor()
            customcell.videoNameLabel.text  = video.name
            customcell.artistNameLabel.text = video.artistName
            customcell.videoInfoLabel.text  = "\(video.views) views"
            customcell.thumbnailImageView.image = nil
            customcell.video = video
            customcell.isPremiumVideo = false
            if (video.isEMG == true && Singleton.sharedInstance.user.subscriber() == false) {
                customcell.imgPremium.image = UIImage(named: "premium_label")
                customcell.isPremiumVideo = true
            }
            if let thumbnail = video.thumbnail {
                customcell.thumbnailImageView.image = thumbnail
            } else {
                customcell.activityIndicator.startAnimating()
                if collectionView.dragging == false && collectionView.decelerating == false {
                    downloadImageForItem(video, indexPath: indexPath)
                }
            }
            
            cell = customcell
        } else {
            let customcell = collectionView.dequeueReusableCellWithReuseIdentifier("playlistCell", forIndexPath: indexPath) as! PlaylistCell
            let playlistItem = self.userplaylists[indexPath.row]
//            let item = playlistItem.objectForKey("user_playlist")
            customcell.lblPlaylistName.text = playlistItem.objectForKey("name") as? String
            
            
            cell = customcell
        }
		
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header = UICollectionReusableView()
		if kind == UICollectionElementKindSectionHeader {
			header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) 
		}
		return header
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return recommendedVideosPlaylist.count
        }
        if collectionView == self.userlist_collectionView {
            return self.userplaylists.count
        }
		return 0
	}
    
    func removingFullScreen() -> Void
    {
        Singleton.sharedInstance.dontHideContentViewFromMenu = true;
    }
	
}

extension WatchingViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            let videoOoyalaId = recommendedVideosPlaylist[indexPath.row]
            let video = videos[videoOoyalaId]!
            NSLog("log")
            if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == true){
                self.showGoPremiumAlert(indexPath.row)
                return
            }else if (Singleton.sharedInstance.isLoadPremiumVideo == false && video.isEMG == false) {
                self.from = .Recommended;
                basic_history += [basic_playlist]
                basic_playlist = organizeBasicPlaylist(recommendedVideosPlaylist, indexOfSelectedItem: indexPath.row)
                setupPlayingVideoInfo(basic_playlist.first!)
                playVideos(basic_playlist);
            } else {
                self.from = .Recommended;
                history += [playlist]
                playlist = organizePlaylist(recommendedVideosPlaylist, indexOfSelectedItem: indexPath.row)
                setupPlayingVideoInfo(playlist.first!)
                playVideos(playlist);
            }
        }else {
            NSLog("Log");
            let playlistItem = self.userplaylists[indexPath.row]
            //            let item = playlistItem.objectForKey("user_playlist")
            let playlistId = playlistItem.objectForKey("id") as? String
            self.userlist_collectionView.alpha = 0
            if(self.video != nil && playlistId != nil) {
                wsManager.addVideoToUserPlaylistNew(playlistId!, video: self.video)
            }
            
        }
        
        //self.player?.playlist = playlist;
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let size = collectionView.bounds.size
        
		return CGSize(width: size.width, height: 70)
	}
}
extension WatchingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
//        textField.borderStyle = UITextBorderStyle.None
        return true
    }
}
extension WatchingViewController: IMAAdsLoaderDelegate {
    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
//        adsManager = adsLoadedData.adsManager
//        adsManager!.delegate = self
        
        // Create ads rendering settings and tell the SDK to use the in-app browser.
//        let adsRenderingSettings = IMAAdsRenderingSettings()
//        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
//        adsManager!.initializeWithAdsRenderingSettings(adsRenderingSettings)
        NSLog("AdsLoader")
    }
    
    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
        NSLog("Error loading ads: \(adErrorData.adError.message)")
//        contentPlayer!.play()
    }
    
    
}
extension WatchingViewController: IMAAdsManagerDelegate {
    func adsManager(adsManager: IMAAdsManager!, didReceiveAdEvent event: IMAAdEvent!) {
        if (event.type == IMAAdEventType.LOADED) {
            // When the SDK notifies us that ads have been loaded, play them.
            //            adsManager.start()
            NSLog("AdsManager")
        }
    }
    
    func adsManager(adsManager: IMAAdsManager!, didReceiveAdError error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        NSLog("AdsManager error: \(error.message)")
        //        contentPlayer!.play()
    }
    func adsManagerDidRequestContentPause(adsManager: IMAAdsManager!) {
        // The SDK is going to play ads, so pause the content.
//        contentPlayer!.pause()
        NSLog("AdsManager")
    }
    
    func adsManagerDidRequestContentResume(adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now), so resume the content.
//        contentPlayer!.play()
    }
}
extension WatchingViewController: UIScrollViewDelegate {
	
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
			let videoOoyalaId = recommendedVideosPlaylist[indexPath.row]
			let video = videos[videoOoyalaId]!
			if let _ = video.thumbnail {
				// thumbnail was already downloaded
			} else {
				downloadImageForItem(video, indexPath: indexPath)
			}
		}
	}
	
}
