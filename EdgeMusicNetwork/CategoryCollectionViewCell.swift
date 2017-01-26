//
//  CategoryCollectionViewCell.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/10/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var categoryName: UILabel!
	
	override func prepareForReuse() {
		categoryName.text = ""
		activityIndicator.stopAnimating()
		thumbnailImageView.image = nil
	}
	
}
