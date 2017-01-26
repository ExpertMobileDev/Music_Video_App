//
//  VideoCatalogTableViewCell.swift
//  EdgeMusicNetwork
//
//  Created by Angel Jonathan GM on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

@IBDesignable class ArtistVideoTableCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var videoInfoLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPremium: UIImageView!
    var isPremiumVideo = false
    var video : Video!
    
    @IBInspectable var videoImage: UIImage? {
        didSet {
            thumbnailImageView.image = videoImage
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
      
    override func prepareForReuse() {
        thumbnailImageView.image = nil
        imgPremium.image = nil
        videoNameLabel.text = ""
        artistNameLabel.text = ""
        videoInfoLabel.text = ""
        activityIndicator.stopAnimating()
    }
    
}
