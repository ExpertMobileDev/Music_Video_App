//
//  SubmenuOptionView.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/8/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class SubmenuOptionView: UIButton {
	
	var isActive: Bool = false {
		didSet {
			setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: isActive ? 1.0 : 0.50), forState: UIControlState.Normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	private func setup() {
		setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5), forState: UIControlState.Normal)
	}
	
	func setTitle(title: String) {
		setTitle(title, forState: UIControlState.Normal)
	}
	
}
