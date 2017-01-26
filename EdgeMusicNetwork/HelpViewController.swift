//
//  HelpController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class HelpViewController: PortraitViewController {
	
	private var slideMenuAnimator = SlideMenuAnimator()
	private let textCellIdentifier = "TextCell"
	private let helpOptionsArray = [  "FAQs" ]
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		print("Here we are in help ")
	}
	
	@IBOutlet weak var helpOptionsTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		helpOptionsTableView.tableFooterView = UIView()
		slideMenuAnimator.enterSegue = "helpToMenuSegue"
		slideMenuAnimator.exitSegue = "menuToHelpSegue"
		slideMenuAnimator.sourceViewController = self

        
        let menuIcon = UIImage(named: "hamburger_menu")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(HelpViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = menuButton
        
        /*
        var backIcon = UIImage(named: "back")
        var backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: nil, action:nil)
        self.navigationItem.backBarButtonItem = backButton
        */
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
	}
	
	@IBAction func cancelMenuViewControllerInHelp(segue: UIStoryboardSegue) {
		// DO-NOT DELETE! Needed as an exit-segue
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destination = segue.destinationViewController as? DetailViewController {
			let indexPath = helpOptionsTableView.indexPathForCell(sender as! UITableViewCell)
			destination.optionSelectedString = helpOptionsArray[indexPath!.row]
		}
	}
	    
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self)
        self.sideMenuViewController.hideContentViewController()
    }
	
}

extension HelpViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) 
		let row = indexPath.row
		cell.textLabel?.text = helpOptionsArray[row]
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return helpOptionsArray.count
	}
	
}

extension HelpViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
}
