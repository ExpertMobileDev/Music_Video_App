//
//  SearchResultCell.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/28/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
	
	@IBOutlet weak var searchResultLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}
	
	override func prepareForReuse() {
		searchResultLabel.text = ""
	}
	
}
