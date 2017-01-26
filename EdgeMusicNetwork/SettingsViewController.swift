//
//  SettingsController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: PortraitViewController, MFMailComposeViewControllerDelegate {
    
    private var slideMenuAnimator = SlideMenuAnimator()
    private let wsManager = WebserviceManager()
    private let textCellIdentifier = "TextCell"
    private let settingsOptionsArray = [ "Terms of Service" , "Privacy Policy", "About", "How It Works", "Contact Support"]
    
    private var currentInextPath: NSIndexPath!
    
    var mailController : MFMailComposeViewController?;
    
    var user: EMNUser!
    
	var mail: Bool = false
    
    @IBOutlet weak var settingsOptionsTableView: UITableView!
    @IBOutlet weak var btnWatching: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About";
        settingsOptionsTableView.tableFooterView = UIView()
        slideMenuAnimator.enterSegue = "settingsToMenuSegue"
        slideMenuAnimator.exitSegue = "menuToSettingsSegue"
        slideMenuAnimator.sourceViewController = self;
        
        if MFMailComposeViewController.canSendMail() == true {
            self.mailController = MFMailComposeViewController();
            self.mailController!.mailComposeDelegate = self;
        }

        let menuIcon = UIImage(named: "hamburger_menu")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(SettingsViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = menuButton
        
        /*
        var backIcon = UIImage(named: "back")
        var backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: nil, action:nil)
        self.navigationItem.backBarButtonItem = backButton
        */
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
    }
    
    func goToDetailViewControllerWithAboutInfo (index: NSIndexPath) {
        //println("In go to detailviewcontrolleraboutinfo. DOING NOTHING");
        self.performSegueWithIdentifier("showSettingsDetail", sender: nil);
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
    func legalActionSheetOptions() {
        let myDetailView : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        // 2
        let option1Action = UIAlertAction(title: "Terms of service", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            myDetailView.optionSelectedString = "Terms"
            //self.presentViewController(myDetailView, animated: true, completion: nil)
            self.navigationController?.pushViewController(myDetailView, animated: true);
            print("Terms of Service selected")
        })
        let option2Action = UIAlertAction(title: "Privacy policy", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            myDetailView.optionSelectedString = "Privacy"
            self.navigationController?.pushViewController(myDetailView, animated: true);
            print("Privacy Selected")
        })
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Legal acion sheet cancelled")
        })
        // 4
        optionMenu.addAction(option1Action)
        optionMenu.addAction(option2Action)
        optionMenu.addAction(cancelAction)
        // 5
        self.navigationController?.pushViewController(myDetailView, animated: true);
    }
    
    
    @IBAction func cancelMenuViewControllerInSettings(segue: UIStoryboardSegue) {
        // DO-NOT DELETE! Needed as an exit-segue
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? DetailViewController {
            destination.optionSelectedString = settingsOptionsArray[currentInextPath!.row]
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {

//        if(settingsOptionsArray[currentInextPath!.row] == "Reset Password"){
//            return false;
//        }
        if(settingsOptionsArray[currentInextPath!.row] == "Contact Support"){
            return false;
        }
        
        return true;
    }
    
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self);
        self.sideMenuViewController.hideContentViewController()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        print("Mail composeController did finish");
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled");
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail failed: \(error!.localizedDescription)")
        default:
            break;
        }
        mail = true
        self.mailController?.dismissViewControllerAnimated(true, completion: {
            self.mailController = nil;
            self.mailController = MFMailComposeViewController();
            self.mailController!.mailComposeDelegate = self;
        });
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) 
        let row = indexPath.row
        cell.textLabel?.text = settingsOptionsArray[row]
        return cell
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.currentInextPath = indexPath;
//        if settingsOptionsArray[indexPath.row] == "Reset Password"{
//            let myDetailView : UpdatePasswordController = self.storyboard?.instantiateViewControllerWithIdentifier("UpdatePasswordController") as! UpdatePasswordController
//                self.navigationController?.pushViewController(myDetailView, animated: true);
//        }
        
        if(settingsOptionsArray[indexPath.row] == "Contact Support"){
            if MFMailComposeViewController.canSendMail() == true {
                self.mailController!.mailComposeDelegate = self;
                let recipientsArray = ["JIRA+Support@edgemusicnetwork.com"];
                self.mailController!.setToRecipients(recipientsArray);
                self.mailController!.setSubject("EMN Mobile iOS App");
                self.mailController!.setMessageBody("", isHTML: true);
                self.presentViewController(self.mailController!, animated: true, completion: nil);
            }
        }  else{
            goToDetailViewControllerWithAboutInfo(indexPath)
        }

        
    }
    
}