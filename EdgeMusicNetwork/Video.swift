//
//  Video.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/6/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import Foundation

class Video: EMNCategory {
    
	var mediaId: String
	var duration: Int
	var videoDescription: String
	var added: NSDate?
	var views: Int
	var tags: String?
	var ooyalaId: String
	var artistName: String
	var genre: String
    var points: String
    var fbLink : NSURL?
    var itunesUrlString : String?
    var amazonUrlString : String?
    var isEMG = false
    
	
	init(id: String, name: String, thumbnailURL: String, mediaId: String, duration: Int, description: String, views: Int, ooyalaId: String, artistName: String, genre: String,
        points: String, tag: String
        ) {
		self.mediaId = mediaId
		self.duration = duration
		self.videoDescription = description
		self.views = views
		self.ooyalaId = ooyalaId
		self.artistName = artistName
		self.genre = genre
        self.points = points
        self.tags = tag
		super.init(id: id, name: name, thumbnailURL: thumbnailURL, imageURL: "")
	}
    override var description: String {
        return "id: \(id) - name: \(name) - mediaId: \(mediaId) - duration: \(duration) - views: \(views) - ooyalaId: \(ooyalaId)"
    }
    func isEMGTag() -> Bool{
        var emgTag = false;
        if (self.tags != nil && self.tags?.characters.count > 0){			
			
            if ((self.tags?.rangeOfString("UMG")) != nil || (self.tags?.rangeOfString("umg")) != nil) {
                emgTag = true
            }
            let tagsArray = self.tags?.characters.split{$0 == " "}.map(String.init)
            
            if(tagsArray?.count > 0 && tagsArray?.last == "UMG"){
                emgTag = true
            }
            if(tagsArray?.count > 0 && tagsArray?.last == "umg"){
                emgTag = true
            }
        }
        return emgTag
    }
}

