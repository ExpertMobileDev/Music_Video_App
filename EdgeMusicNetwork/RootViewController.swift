//
//  RootViewController.swift
//  emn
//
//  Created by Jason Cox on 9/13/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class RootViewController: RESideMenu, RESideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        self.delegate = self;
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent
        self.contentViewShadowColor = UIColor.blackColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        self.animationDuration = 0.23;
        
        self.fadeMenuView = true;
        self.contentViewShadowEnabled = true;
        self.contentViewInPortraitOffsetCenterX = 75;
        self.backgroundImage = UIImage(named: "bg_welcome");
        self.parallaxEnabled = true;
        self.bouncesHorizontally = true;
        
        self.contentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Watching");
        self.leftMenuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MenuViewController");
        
    }
    
    // MARK: RESide Delegate Methods
    func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        Singleton.sharedInstance.dontHideContentViewFromMenu = false;
        print("[ROOTVIEWCONTROLLER] This will show the menu")
    }
    
}
