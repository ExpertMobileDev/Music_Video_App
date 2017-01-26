//
//  PortraitViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/10/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class PortraitViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
	}
	
    
	override func shouldAutorotate() -> Bool {
		return false
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Portrait
	}
	
}
