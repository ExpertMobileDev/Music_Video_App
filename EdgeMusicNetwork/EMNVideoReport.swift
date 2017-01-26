//
//  EMNVideoReport.swift
//  emn
//
//  Created by Jason Cox on 9/28/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//
import Darwin
import Foundation

enum VideoWatchFrom
{
    case MyPlaylist
    case Search
    case Mood
    case Channel
    case Playlist
    case Home
    case Recommended
}

class EMNVideoReport: NSObject
{
    var user : EMNUser;
    var video: Video;
    var quarterSeconds: Int;
    var currentQuarterSeconds: Int;
    var lastSentQuarterSeconds: Int?
    var finishedWatching: Bool;
    var from: VideoWatchFrom;
    var category: EMNCategory?;
    var sentToServer: Bool;
    var sendingReportToServer: Bool;
    var searchQuery: String?;
    
    init(user: EMNUser, video: Video, from: VideoWatchFrom)
    {
        self.finishedWatching = false;
        self.user = user;
        self.video = video;
        self.currentQuarterSeconds = 0;
        self.quarterSeconds = 0;
        self.lastSentQuarterSeconds = 0;
        self.from = from;
        self.category = nil;
        self.sentToServer = false;
        self.sendingReportToServer = false;
    }
    
    func secondsWatched() -> Int
    {
        return (self.quarterSeconds/4)-1;
    }
    
    func addQuarterSecond()
    {
        self.currentQuarterSeconds += 1;
        if(self.currentQuarterSeconds >= self.quarterSeconds){
            self.quarterSeconds += 1;
        }
    }
    
    func fromAsString() -> String?
    {
        switch self.from
        {
        case .Channel:
            return "channel";
        case .Mood:
            return "mood";
        case .MyPlaylist:
            return "favorites";
        case .Playlist:
            return "playlist";
        case .Search:
            return "search";
        case .Recommended:
            return "recommended";
        default:
            return "home";
        }
    }
    
    func shouldSendToServer() -> Bool
    {
        //This means that it hasn't been sent yet
        if(self.lastSentQuarterSeconds == 0 && self.currentQuarterSeconds > 8){
            return true;
        }
        //this will send it if the user has watched more of the video than has already been
        //reported.
        if(self.currentQuarterSeconds >= self.lastSentQuarterSeconds)
        {
            return true;
        }
        return false;
    }

    func didSendToServer()
    {
        self.lastSentQuarterSeconds = self.currentQuarterSeconds;
        self.currentQuarterSeconds = 0;
    }
    
    func asQueryString() -> String
    {
        var fromString = "";
        var categoryString = "";
        var categoryIdString = "";
        if(self.category != nil){
            categoryString = EMNUtils.encodeString(self.category!.name);
            categoryIdString = EMNUtils.encodeString(self.category!.id);
        }
        var secondsString = "0";
        if(self.secondsWatched() > 0){
            secondsString = String(self.secondsWatched());
        }
        var searchString = "";

        if(self.from == .Search){
            if(Singleton.sharedInstance.currentSearchQuery != nil){
                searchString = EMNUtils.encodeString(Singleton.sharedInstance.currentSearchQuery!);
            }
        }
        fromString = EMNUtils.encodeString(self.fromAsString()!);
        
        var userZipString = "";
        if(Singleton.sharedInstance.user.zipCode != nil){
            userZipString = EMNUtils.encodeString(Singleton.sharedInstance.user.zipCode!);
        }
        let platformString = "Apple";
        let versionString = EMNUtils.encodeString(Singleton.sharedInstance.version!);
        let modelString = EMNUtils.encodeString(Singleton.sharedInstance.model!);
        let videoIdString = EMNUtils.encodeString(self.video.id);
        if self.user.id != nil {
            let userIdString = EMNUtils.encodeString(self.user.id!);
            return "user_id=\(userIdString)&user_zip=\(userZipString)&video_id=\(videoIdString)&from_string=\(fromString)&category=\(categoryString)&category_id=\(categoryIdString)&seconds=\(secondsString)&platform=\(platformString)&model=\(modelString)&version=\(versionString)&searchString=\(searchString)";
        } else {
            return "user_zip=\(userZipString)&video_id=\(videoIdString)&from_string=\(fromString)&category=\(categoryString)&category_id=\(categoryIdString)&seconds=\(secondsString)&platform=\(platformString)&model=\(modelString)&version=\(versionString)&searchString=\(searchString)";
        }
        
    }
}