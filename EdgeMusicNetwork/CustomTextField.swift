//
//  CustomTextFieldController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/25/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
	
	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return self.newBounds(bounds)
	}
	
	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return self.newBounds(bounds)
	}
	
	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return self.newBounds(bounds)
	}
	
	private func newBounds(bounds: CGRect) -> CGRect {
		let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		var newBounds = bounds
		newBounds.origin.x += padding.left
		newBounds.origin.y += padding.top
		newBounds.size.height -= (padding.top * 2) - padding.bottom
		newBounds.size.width -= (padding.left * 2) - padding.right
		
		return newBounds
	}
	
}
