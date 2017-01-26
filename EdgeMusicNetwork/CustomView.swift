//
//  CustomView.swift
//  emn
//
//  Created by RobertoAlberta on 5/5/16.
//  Copyright © 2016 Angel Jonathan GM. All rights reserved.
//

import UIKit

class CustomView: UIView {
    var imgThumbnail : UIImageView!
    var lblPlaylistName : UILabel!
    var btnOverall : UIButton!
    var btnEdit : UIButton!
    var btnDelete : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        let frameSize = frame.size
        let imgRect = CGRectMake((frameSize.width - 82) / 2, (frameSize.height - 94) / 2, 82, 94)
        let lblRect = CGRectMake(20, frameSize.height * 3 / 4 + 5, frameSize.width - 40, 25)
        let btnOverallRect = CGRectMake(0, 0, frameSize.width, frameSize.height)
        let btnEditRect = CGRectMake(frameSize.width - 28, 10, 20, 20)
        let btnDeleteRect = CGRectMake(frameSize.width - 56, 10, 20, 20)
        
        self.imgThumbnail = UIImageView(frame: imgRect)
        self.lblPlaylistName = UILabel(frame: lblRect)
        self.lblPlaylistName.textAlignment = .Center
        self.lblPlaylistName.textColor = UIColor.darkGrayColor()
        self.lblPlaylistName.font = UIFont.systemFontOfSize(18)
        self.btnOverall = UIButton(frame: btnOverallRect)
        self.btnEdit = UIButton(frame: btnEditRect)
        self.btnEdit.setImage(UIImage(named: "dark_edit"), forState: .Normal)
        self.btnDelete = UIButton(frame: btnDeleteRect)
        self.btnDelete.setImage(UIImage(named: "dark_delete"), forState: .Normal)
        
        self.addSubview(imgThumbnail)
        self.addSubview(lblPlaylistName)
        self.addSubview(btnOverall)
        self.addSubview(btnEdit)
        self.addSubview(btnDelete)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding.")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
