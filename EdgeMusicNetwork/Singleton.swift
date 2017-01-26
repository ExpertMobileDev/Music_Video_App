//
//  Singleton.swift
//  EdgeMusicNetwork
//
//  Created by Developer on 7/28/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

let sharedManager : Singleton = Singleton()
enum UpgradeFrom {
    case Home
    case Watching
    case Menu
    case Artist
}
class Singleton: NSObject {
    
    private var menuEnabled = false
    private var menuItemSelected = false
    var dontHideContentViewFromMenu = false; //This is for hitting done on fullscreen from player
    private var menuItemName :UIViewController?
    private var image : UIImage?
    
    let wsManager = WebserviceManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var videoReports: [EMNVideoReport];
    
    var userSignedUpFlag = false;
    var userLoggedInFlag = false;
    var userWatchNowFlag = false;
    var userDataNeededToLoad = false;
    var isEmptyUser = false;
    var isLoadPremiumVideo = true;
    
    var unPauseWhenBackground = false;
    var unPauseCount = 0;

    var user : EMNUser!
    var model: String!
    var version: String!
    var platform: String!
    var iapManager: IAPManager?
    var currentReport: EMNVideoReport?;
    var currentSearchQuery: String?;
    
    var currentUpgradeFrom:UpgradeFrom = .Home
    var currentUpgradeFromCategoryPrev:EMNCategory!
    var currentUpgradeFromWatchingPlaylist:[String]!
    var currentUpgradeFromWatchingVideo:Video!
    var recommendedVideosFromWatching:[String]!
    var currentHomeFromBack = false
    var currentScreenMode : String = "Portrait"
    var currentArtistMode : String = "Portrait"
    var currentDeviceReload = false
    
    var userPlaylists : [NSDictionary]!
    
    var updatePasswordFromMenu = false
    
    var isWatching = false
    var watchingVC:WatchingViewController?
    var isWatchingBackground = false
    
    var player: PlayerViewController?;
    
    var userFavPlaylist : Playlist!
    
    override init()
    {
        self.videoReports = [];
        self.userPlaylists = [];
        self.model = UIDevice.currentDevice().model;
        self.version = UIDevice.currentDevice().systemVersion;
        self.platform = "Apple";
        self.iapManager = IAPManager()
        self.iapManager?.initialize()
        super.init();
    }
    
    class var sharedInstance : Singleton {
        return sharedManager
    }
    
    func addTimerForVideo(video: Video, from: VideoWatchFrom)
    {
        //var newReport = false;
        if let videoReport = self.reportForVideo(video)
        {
            print("Found report: \(videoReport) for video: \(video)");
            self.currentReport = videoReport;
        }else{
            print("Creating report for video: \(video)");
            let videoReport = EMNVideoReport(user: Singleton.sharedInstance.user, video: video, from: from);
            self.videoReports.append(videoReport);
            self.currentReport = videoReport;
            //newReport = true;
        }
    }
    
    func addOoyalaSecondToCurrentReport()
    {
        if(self.currentReport != nil){
            
            self.currentReport?.addQuarterSecond();
            //let secondsWatched = self.currentReport?.secondsWatched();
            //print("Inrementing seconds for video: \(self.currentReport!.video.name) to \(secondsWatched)");
        }
    }
    
    func reportForVideo(video: Video) -> EMNVideoReport?
    {
        for videoReport: EMNVideoReport in self.videoReports
        {
            if(video.id == videoReport.video.id){
                print("Video id: \(video.id) is equal to report video id: \(videoReport.video.id)");
                return videoReport;
            }else{
                print("Video id: \(video.id) is NOT equal to report video id: \(videoReport.video.id)");
            }
        }
        return nil;
    }
    
    func removeVideoReportForVideo(video: Video)
    {
        if let videoReport = self.reportForVideo(video)
        {
            videoReport.finishedWatching = true;
        }
    }
    
    func sendReportsInQueue()
    {
        print("[SINGLETON] Sending reports: \(self.videoReports) in queue.");
        if (Singleton.sharedInstance.currentReport != nil ) {
            self.sendReport(Singleton.sharedInstance.currentReport!);
        }
        
//        for report: EMNVideoReport in self.videoReports
//        {
//            if(report == self.currentReport){
////                print("[SINGLETON] Ignoring report: \(report) because it is current report.");
//                self.sendReport(report);
//                continue;
//            }
//            if(report.sendingReportToServer == true){
//                print("[SINGLETON] Ignoring report: \(report) because it is already being sent.");
//                continue;
//            }
//            if(report.shouldSendToServer() == true){
//                self.sendReport(report);
//            }else{
//                print("[SINGLETON] Ignoring report: \(report) because it should NOT be sent.");
//            }
//        }
    }
    func sendReport(report: EMNVideoReport)
    {
        if reachabilityHandler.verifyInternetConnection() == true {
            report.sendingReportToServer = true;
            let queryString = report.asQueryString();
            print("[SINGLETON] Sending report for \(queryString)");
            wsManager.reportVideoWatched(report, completionHandler: { (success, message: String?) -> Void in
                if(success){
                    report.didSendToServer();
                    report.sendingReportToServer = false;
                    
                }else{
                    report.sendingReportToServer = false;
                }
            })
        }
        
    }
    
}
