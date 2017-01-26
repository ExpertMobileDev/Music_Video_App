//
//  StartWatchingController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/2/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class StartWatchingController: PortraitViewController {
	
	// var loggedInBool : Bool = false
	
	@IBOutlet weak var highLightStartWatchingButton: UIButton!
    @IBOutlet weak var screenshotImgView: UIImageView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var pageControl: UIPageControl!
    
    var fromNewUser = false;
    var fromWatchNow = false;
	var pageControlBeingUsed = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		highLightStartWatchingButton.setImage(nil, forState: UIControlState.Highlighted)
		
		let width = view.bounds.width - 40
		var frame = CGRectMake(0, 0, width, scrollView.bounds.height)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        self.title = "About EMN";

		let texts = ["Discover new music, stream the latest music videos by top indie & major artists", "Enjoy our handpicked playlists & channels by our expert DJ curators", "A unique music video experience designed just for you.          Watch. Listen. Love"]
		
		for text in texts {
			let textView = UITextView(frame: frame)
			textView.editable = false
			textView.backgroundColor = UIColor.clearColor()
			textView.font = UIFont(name: "Gotham-Book", size: 24)
			textView.textColor = UIColor.whiteColor()
			textView.textAlignment = NSTextAlignment.Center
			textView.text = text
			
			frame.origin.x += width
			scrollView.addSubview(textView)
		}    
		
		scrollView.contentSize = CGSize(width: width * 3, height: scrollView.bounds.height)
        
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
        screenshotImgView.hidden = true
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
	}
    
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

	}
	
	@IBAction func changePage(sender: UIPageControl) {
		let x = scrollView.frame.size.width * CGFloat(pageControl.currentPage)
		pageControlBeingUsed = true
		let frame = CGRect(origin: CGPoint(x: x, y: 0), size: scrollView.frame.size)
		scrollView.scrollRectToVisible(frame, animated: true)
		updatePageToPosition(x)
	}
	
	@IBAction func startWatchingButton(sender: UIButton) {
        if(fromNewUser == true){
            Singleton.sharedInstance.userSignedUpFlag = true;
        }else{
            if(fromWatchNow == true){
                Singleton.sharedInstance.userWatchNowFlag = true;
                Singleton.sharedInstance.userDataNeededToLoad = true;
            }else{
                Singleton.sharedInstance.userLoggedInFlag = true;
            }
        }
        
        self.navigationController?.popToRootViewControllerAnimated(false);
	}
	
    func pushToHomeScreen(){
        let initialViewController = storyboard!.instantiateViewControllerWithIdentifier("RootViewController") 
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }

	func updatePageToPosition(x: CGFloat) {
		let pageWidth = scrollView.frame.size.width
		let page = floor(x / pageWidth)
		pageControl.currentPage = Int(page)
	}
	
}

extension StartWatchingController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		if pageControlBeingUsed {
			return
		}
		updatePageToPosition(scrollView.contentOffset.x)
	}
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		pageControlBeingUsed = false
	}
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		pageControlBeingUsed = false
	}
}
