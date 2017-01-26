//
//  MenuOptionCell.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/22/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class MenuOptionCell: UITableViewCell {
	
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var menuImageView: UIImageView!
	@IBOutlet weak var menuLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
		
}
