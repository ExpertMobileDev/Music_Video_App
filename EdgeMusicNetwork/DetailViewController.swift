//
//  DetailViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class DetailViewController: PortraitViewController, UIWebViewDelegate
{
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dataInfoWebView: UIWebView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var url: NSURL!
    @IBOutlet weak var btnWatching: UIButton!
	
	var optionSelectedString : String!
	
	
	func dismissCurrentView() {
        self.navigationController?.popToRootViewControllerAnimated(true);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        //titleLabel.text = optionSelectedString.uppercaseString
        //self.title = optionSelectedString.uppercaseString;
		
		//we create a NSURL var to show a page on the web view; before passing the url variable, we check the optionSelectedString to know which html file put into the webview
		dataInfoWebView.scalesPageToFit = true
        self.title = optionSelectedString;
        url = NSURL(string: "http://www.edgemusicnetwork.com")
        //var htmlFileString = " "
        if optionSelectedString == "FAQs" {
            let urlFAQsFile = NSBundle.mainBundle().URLForResource("faqs", withExtension:"html")
            let FAQrequest = NSURLRequest(URL: urlFAQsFile!)
            dataInfoWebView.loadRequest(FAQrequest)
        } else if optionSelectedString == "Terms of Service" {
            let urlTermsFile = NSBundle.mainBundle().URLForResource("termsandconditions", withExtension:"html")
            let termsrequest = NSURLRequest(URL: urlTermsFile!)
            dataInfoWebView.loadRequest(termsrequest)
        } else if optionSelectedString == "Privacy Policy" {
            let urlPrivacyFile = NSBundle.mainBundle().URLForResource("privacypolicy", withExtension:"html")
            let Privacyrequest = NSURLRequest(URL: urlPrivacyFile!)
            dataInfoWebView.loadRequest(Privacyrequest)
        } else if optionSelectedString == "About" {
            let urlAboutFile = NSBundle.mainBundle().URLForResource("about", withExtension:"html")
            let Aboutrequest = NSURLRequest(URL: urlAboutFile!)
            dataInfoWebView.loadRequest(Aboutrequest)
        } else if optionSelectedString == "How It Works" {
            let urlHowToFile = NSBundle.mainBundle().URLForResource("howto", withExtension:"html")
            let HowTorequest = NSURLRequest(URL: urlHowToFile!)
            dataInfoWebView.loadRequest(HowTorequest)
        }
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		if optionSelectedString == "Contact Support" {

		}
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
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
    func webViewDidStartLoad(webView: UIWebView){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
	
}
