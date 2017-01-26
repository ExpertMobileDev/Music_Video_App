//
//  Channel.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/26/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import Foundation

class Channel: EMNCategory {
	
	/*init(id: String, name: String, thumbnailURL: NSURL?, imageURL: NSURL?) {
		super.init(id: id, name: name)
		self.thumbnailURL = thumbnailURL
		self.imageURL = imageURL
	}*/

	override init(id: String, name: String, thumbnailURL: String, imageURL: String) {
		super.init(id: id, name: name, thumbnailURL: thumbnailURL, imageURL: imageURL)
	}

}
