//
//  TrialLeftViewController.swift
//  emn
//
//  Created by Jason Cox on 9/19/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import MediaPlayer

class TrialLeftViewController: PortraitViewController
{
    private var moviePlayer : MPMoviePlayerController!
    
    override func viewDidLoad() {
        let cancel = "Cancel";
        let cancelButton = UIBarButtonItem(title: cancel, style: .Plain, target: self, action: #selector(TrialLeftViewController.dismissTrial));
        self.navigationItem.rightBarButtonItem = cancelButton;
        self.title = "All-Access"
        self.playVideo();
        super.viewDidLoad();
    }
    
    func dismissTrial(){
        moviePlayer.stop();
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer);        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
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
            let url:NSURL = NSURL(string: "https://www.edgemusic.com/videos/trial.m4v")!
            moviePlayer = MPMoviePlayerController(contentURL: url)
            moviePlayer.view.frame = self.view.bounds
            moviePlayer.movieSourceType = MPMovieSourceType.File
            moviePlayer.scalingMode = .AspectFit
            self.view.addSubview(moviePlayer.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TrialLeftViewController.dismissTrial), name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer);
            moviePlayer.prepareToPlay()
            moviePlayer.play()
        }
    }
}