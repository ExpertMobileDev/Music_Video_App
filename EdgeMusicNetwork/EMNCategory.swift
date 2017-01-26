//
//  Channel.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/26/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

enum EMNCategoryType: Int {
	case Channel
	case Mood
	case Playlist
	//case Unknown
}

class EMNCategory: NSObject {
	
	var id: String
	var name: String
	var thumbnailURL: NSURL?
	var thumbnail: UIImage!
	var imageURL: NSURL?
	var image: UIImage!
    var apiUrlString: String?
	
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
	
	init(id: String, name: String, thumbnailURL: String, imageURL: String) {
		self.id = id
		self.name = name
		self.thumbnailURL = thumbnailURL.isEmpty ? nil : NSURL(string: thumbnailURL)
		self.imageURL = imageURL.isEmpty ? nil : NSURL(string: imageURL)
	}
	
	override func isEqual(object: AnyObject?) -> Bool {
		if let o = object as? EMNCategory {
			return id == o.id
		}
		return false
	}
    override var description: String {
        return "id: \(id) - name: \(name) - thumbnail: \(thumbnailURL) - image: \(imageURL)"
    }
}

