//
//  VideoCatalogTableViewCell.swift
//  EdgeMusicNetwork
//
//  Created by Angel Jonathan GM on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

@IBDesignable class ArtistVideoCell: UICollectionViewCell {
	
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var videoNameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var videoInfoLabel: UILabel!
	@IBOutlet weak var detailButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imgPremium: UIImageView!
    var isPremiumVideo = false
    var video : Video!
	
	@IBInspectable var image: UIImage? {
		didSet {
			thumbnailImageView.image = image
		}
	}
	@IBInspectable var videoName: String? {
		didSet {
			videoNameLabel.text = videoName
		}
	}
	@IBInspectable var artistName: String? {
		didSet {
			artistNameLabel.text = artistName
		}
	}
	@IBInspectable var videoInfo: String? {
		didSet {
			videoInfoLabel.text = videoInfo
		}
	}
	/*@IBInspectable var cellColor: UIColor? {
		didSet {
			self.backgroundColor = cellColor
		}
	}*/
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	func setup() {
		let bundle = NSBundle(forClass: self.dynamicType)
		let separator = "."
		let className = NSStringFromClass(ArtistVideoCell).componentsSeparatedByString(separator).last!
		let nib = UINib(nibName: className, bundle: bundle)
		
		let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
		view.frame = bounds
		view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		addSubview(view)
	}
	
	override func prepareForReuse() {
		thumbnailImageView.image = nil
		videoNameLabel.text = ""
        imgPremium.image = nil
		artistNameLabel.text = ""
		videoInfoLabel.text = ""
		activityIndicator.stopAnimating()
	}
	
}
