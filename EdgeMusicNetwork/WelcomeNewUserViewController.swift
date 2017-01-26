//
//  WelcomeNewUserViewController.swift
//  emn
//
//  Created by Jason Cox on 9/19/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import MediaPlayer

class WelcomeNewUserViewController: PortraitViewController
{
    private var moviePlayer : MPMoviePlayerController!
    
    override func viewDidLoad() {
        let skip = "Skip";
        let skipButton = UIBarButtonItem(title: skip, style: .Plain, target: self, action: #selector(WelcomeNewUserViewController.dismissWelcome));
        self.navigationItem.rightBarButtonItem = skipButton;
        self.title = "Welcome"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        self.playVideo();
        super.viewDidLoad();
    }
    
    func dismissWelcome(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer);
        moviePlayer.stop();
//        let startWatchingVC = self.storyboard?.instantiateViewControllerWithIdentifier("StartWatchingController") as! StartWatchingController;
//        self.navigationController?.pushViewController(startWatchingVC, animated: true);
        Singleton.sharedInstance.userSignedUpFlag = true;
        
        self.navigationController?.popToRootViewControllerAnimated(false);
    }
    
    private func playVideo() {
        let path = NSBundle.mainBundle().pathForResource("trial", ofType:"mp4");
        if(path != nil){
            let url = NSURL(fileURLWithPath: path!);
            if let moviePlayer = MPMoviePlayerController(contentURL: url) {
                self.moviePlayer = moviePlayer
                moviePlayer.view.frame = self.view.bounds
                moviePlayer.prepareToPlay()
                moviePlayer.scalingMode = .AspectFit
                self.view.addSubview(moviePlayer.view)
            } else {
                print("Ops, something wrong when playing video.m4v")
            }
        }else{

            let url:NSURL = NSURL(string: "https://www.edgemusic.com/videos/welcome.m4v")!
            moviePlayer = MPMoviePlayerController(contentURL: url)
            moviePlayer.view.frame = self.view.bounds
            moviePlayer.movieSourceType = MPMovieSourceType.File
            moviePlayer.scalingMode = .AspectFit
            self.view.addSubview(moviePlayer.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WelcomeNewUserViewController.dismissWelcome), name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer);
            moviePlayer.prepareToPlay()
            moviePlayer.play()
        }
    }
}