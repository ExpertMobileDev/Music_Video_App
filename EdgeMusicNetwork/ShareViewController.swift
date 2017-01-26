//
//  ShareViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/22/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import Social

class ShareViewController: PortraitViewController {
    
    var user : EMNUser!
    var video : Video!
    
    var fromProfile = false;
    var isFavorite = false;
    
    let reachabilityHandler = ReachabilityHandler()
    
    @IBOutlet weak var addToChannelButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    @IBOutlet weak var buySongButton: UIButton!
    @IBOutlet weak var buyFromiTunesButton: UIButton!
    @IBOutlet weak var buyFromAmazonButton: UIButton!
    
    @IBOutlet weak var amazonButtonLeadingConstraint: NSLayoutConstraint!
    
    private var wsManager = WebserviceManager()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        if(Singleton.sharedInstance.user.indexOfFavoriteVideo(self.video) != nil){
            self.addToChannelButton.setTitle("REMOVE FROM FAVORITES", forState: UIControlState.Normal);
        }else{
            self.addToChannelButton.setTitle("ADD TO FAVORITES", forState: UIControlState.Normal);
        }
        
        self.buyFromAmazonButton.hidden = true;
        self.buyFromAmazonButton.enabled = false;
        self.buyFromiTunesButton.hidden = true;
        self.buyFromiTunesButton.enabled = false;
        if(self.video.itunesUrlString != nil && self.video.itunesUrlString?.characters.count > 0){
            //Add itunes button
            print("SHOWING ITUNES");
            buyFromiTunesButton.enabled = true;
            buyFromiTunesButton.hidden = false;
        }
        if(self.video.amazonUrlString != nil && self.video.amazonUrlString?.characters.count > 0){
            print("SHOWING AMAZON");
            //Add itunes button
            buyFromAmazonButton.enabled = true;
            buyFromAmazonButton.hidden = false;
         }
		// Do any additional setup after loading the view.
	}
	
	@IBAction func cancelPressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
    @IBAction func addToChannelsPressed(sender: UIButton) {
        if(Singleton.sharedInstance.user.indexOfFavoriteVideo(self.video) == nil){
            if reachabilityHandler.verifyInternetConnection() == true {
                wsManager.addVideoToUserPlaylist(Singleton.sharedInstance.user, video: self.video);
            }
            Singleton.sharedInstance.user.addVideoToFavorites(video);
        }else{
            if reachabilityHandler.verifyInternetConnection() == true {
                wsManager.removeVideoFromUserPlaylist(Singleton.sharedInstance.user, video: self.video);
            }            
            Singleton.sharedInstance.user.removeVideoFromFavorites(video);
        }
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func sharePressed(sender: UIButton) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            fbShare.setInitialText("I just listened to   \(video.name)  video on Edge Music")
            let url = NSURL(string: "https://edgemusic.com")!
            fbShare.addURL(url)
            
            self.presentViewController(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func copyLinkPressed(sender: UIButton) {
        let linkCopiedString = video.fbLink != nil ? video.fbLink?.absoluteString : "https://www.edgemusic.com";
        print("\(linkCopiedString)")
        UIPasteboard.generalPasteboard().string = linkCopiedString
        let alert = UIAlertController(title: "", message: "Link has been copied!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func buyThisSongPressed(sender: UIButton) {
        
        //let url = NSURL(string: buySongLinkString)!
        //UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func buyFromiTunesStore(sender: UIButton){
        print("Buying from itunes: \(self.video.itunesUrlString!)");
        UIApplication.sharedApplication().openURL(NSURL(string: self.video.itunesUrlString!)!);
        
    }
    @IBAction func buyFromAmazonStore(sender: UIButton){
        print("Buying from amazon: \(self.video.amazonUrlString!)");
        UIApplication.sharedApplication().openURL(NSURL(string: self.video.amazonUrlString!)!);
    }
}
