//
//  MenuTableViewCell.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/4/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

@objc protocol MenuOptionViewDelegate {
	
	func menuSelected(menuView: MenuOptionView)
	
}

@IBDesignable class MenuOptionView: UIView {
	
	var view: UIView!
	
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var menuImageView: UIImageView!
	@IBOutlet weak var menuLabel: UILabel!
	@IBOutlet var delegate: AnyObject?
	
	@IBInspectable var image: UIImage? {
		didSet {
			menuImageView.image = selected ? imageSelected ?? image : image
		}
	}
	@IBInspectable var imageSelected: UIImage? {
		didSet {
			menuImageView.image = selected ? imageSelected ?? image : image
		}
	}
	@IBInspectable var text: String? {
		get {
			return menuLabel.text
		}
		set {
			menuLabel.text = newValue
		}
	}
	@IBInspectable var backgroundImage: UIImage? {
		get {
			return backgroundImageView.image
		}
		set {
			backgroundImageView.image = newValue
			backgroundImageView.hidden = !selected
		}
	}
	@IBInspectable var selected: Bool = false {
		didSet {
			menuImageView.image = selected ? imageSelected ?? image : image
			backgroundImageView.hidden = !selected
			menuLabel.font = UIFont(name: selected ? "Gotham-Black" : "Gotham-Book", size: 15)
		}
	}
	
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
		let className = NSStringFromClass(MenuOptionView).componentsSeparatedByString(separator).last!
		let nib = UINib(nibName: className, bundle: bundle)
		view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
		view.frame = bounds
		view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		addSubview(view)
	}
	
	@IBAction func touched(sender: UITapGestureRecognizer) {
		selected = !selected
		(delegate as? MenuOptionViewDelegate)?.menuSelected(self)
	}
	
}
