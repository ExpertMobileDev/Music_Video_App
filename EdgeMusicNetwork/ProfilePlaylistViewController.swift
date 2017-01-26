//
//  ProfilePlaylistViewController.swift
//  emn
//
//  Created by RobertoAlberta on 4/29/16.
//  Copyright © 2016 Angel Jonathan GM. All rights reserved.
//

import UIKit

class ProfilePlaylistViewController: PortraitViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var btnWatching: UIButton!
    @IBOutlet weak var scPlaylists: UIScrollView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var lblPlaylistTitle: UILabel!
    @IBOutlet weak var imgProfileBorder: UIImageView!
    @IBOutlet weak var lblUserPoints: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var imgLogoSolo: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var scTextContent: UIScrollView!
    @IBOutlet weak var vwCreatePlaylist: UIView!
    @IBOutlet weak var txtPlaylistName: UITextField!
    
    var isScrollView = false;
    let wsManager = WebserviceManager()
    
    var videos = [Video]()
    var playlists = [Playlist]()
    var cellArray = [CustomView]()
    var currentCustomView = CustomView()
    var userImageView: UIImageView!
    var backgroundImageView : UIImageView!
    var userInfoHeader: UserProfileHeader!
    
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var array_playlist = [Playlist]();
    var playlist_type = "Fav"
    var playlist_name = "My Playlist"
    var userPlaylist : Playlist!
    var isSetup = false;
    
    var keyHeight = CGFloat();
    var currentEditMode = false
    var isFav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile & Playlist";
        let menuIcon = UIImage(named: "back")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: "showMenu:")
        self.navigationItem.leftBarButtonItem = menuButton;
        
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "showEdit:");
        self.navigationItem.rightBarButtonItem = editButton;
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        let imageWithShape = UIImage(named: "profile_mask")!
        let mask = CALayer()
        mask.contents = imageWithShape.CGImage
        mask.frame = imgLogoSolo.layer.bounds
        imgLogoSolo.layer.mask = mask
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGesture.delegate = self
        longPressGesture.delaysTouchesBegan = true;
//        longPressGesture.minimumPressDuration = 3.0
        self.scPlaylists.addGestureRecognizer(longPressGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        currentEditMode = false
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        
        self.scPlaylists.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.scPlaylists.layer.borderWidth = 1.0
        self.setupUserInfo()
        
        if isSetup == false {
            self.arrangePlaylists()
            self.buildScrollView()
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .Ended) {
            return;
        }
        let p = gestureRecognizer.locationInView(self.scPlaylists)
        let scVwSize = self.scPlaylists.bounds
        let sc_item_size = CGSizeMake(scVwSize.width / 2, scVwSize.width / 2)
        let row = Int(p.x / sc_item_size.width)
        let column = Int(p.y / sc_item_size.height)
        let index = 2 * column + row
        if self.isFav == false {
            if index == 0 || index > self.array_playlist.count {
                return
            } else {
                self.userPlaylist = array_playlist[index - 1]
                let cutomView = self.getCustomViewbyIndex(index)
                cutomView.btnDelete.alpha = 1
                cutomView.btnEdit.alpha = 1
                self.lblPlaylistTitle.text = self.userPlaylist.name
//                self.lblPlaylistTitle.textColor = UIColor.redColor()
            }
        }else {
            if index > 0 && index < array_playlist.count{
                self.userPlaylist = array_playlist[index]
                let cutomView = self.getCustomViewbyIndex(index)
                cutomView.btnDelete.alpha = 1
                cutomView.btnEdit.alpha = 1
                self.lblPlaylistTitle.text = self.userPlaylist.name
//                self.lblPlaylistTitle.textColor = UIColor.redColor()
            }
        }
//        let k = self.isFav == false ? index - 1 : index;
//        if (k >= 0 && k <= array_playlist.count) {
//            self.userPlaylist = array_playlist[k]
//            self.btnDelete.alpha = 1
//            self.btnEdit.alpha = 1
//            self.lblPlaylistTitle.text = self.userPlaylist.name
//            self.lblPlaylistTitle.textColor = UIColor.redColor()
//        }
    }
    func getCustomViewbyIndex(index : Int) -> CustomView {
        var customView = CustomView()
        if (self.cellArray.count > 0) {
            for (var i = 0; i<self.cellArray.count;i++){
                let item = self.cellArray[i]
                if (item.tag == index) {
                    customView = item
                    return customView
                }
            }
        }
        return customView
    }
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        keyHeight = keyboardRectangle.height
    }
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self)
        self.sideMenuViewController.hideContentViewController()
    }
    
    func showEdit(sender:AnyObject){
        self.performSegueWithIdentifier("editProfileTableSegue", sender: sender);
//        if currentEditMode == false {
//            for vw in self.scPlaylists.subviews {
////                vw.layer.borderWidth = 3.0
//                vw.layer.borderColor = UIColor.redColor().CGColor
//            }
//            self.navigationItem.rightBarButtonItem?.title = "Normal"
//            currentEditMode = true
//        } else {
//            for vw in self.scPlaylists.subviews {
//                vw.layer.borderColor = UIColor.whiteColor().CGColor
//            }
//            self.navigationItem.rightBarButtonItem?.title = "Edit"
//            currentEditMode = false
//        }
        
    }
    func clearBounds() {
        for vw in self.scPlaylists.subviews {
            vw.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    func buildScrollView() {
        for vw in self.scPlaylists.subviews {
            vw.removeFromSuperview()
            //            vw = nil
            vw.alpha = 0
            self.cellArray = [CustomView]();
        }
        self.scPlaylists.alpha = 1
        self.vwCreatePlaylist.alpha = 0
//        self.noDataLabel.hidden = true
        self.scPlaylists.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        let scVwSize = self.scPlaylists.bounds
        let sc_item_size = CGSizeMake(scVwSize.width / 2, scVwSize.width / 2)
        var vertical_items = 0
        var itemCount = array_playlist.count
        if self.isFav == false {
            itemCount = array_playlist.count + 2;
        } else {
            itemCount = array_playlist.count + 1;
        }
//        var itemCount = array_playlist.count > 0 ? array_playlist.count + 1 : array_playlist.count + 2;
//        if self.isFav == false {
//            itemCount++;
//        }
        for i in 0  ..< itemCount {
            let rowIx = i % 2
            let columnIx = i / 2
            vertical_items = columnIx + 1
            let itemRect = CGRectMake(sc_item_size.width * CGFloat(rowIx), sc_item_size.height * CGFloat(columnIx), sc_item_size.width, sc_item_size.height)
//            let itemCell = UIView(frame: itemRect);
            let itemCell = CustomView(frame: itemRect)
            if (i == 0) {
                
//                let bgImageCell = UIImageView(frame: itemCell.bounds)
//                bgImageCell.image = UIImage()
                
//                let lblRect = CGRectMake(20, sc_item_size.height * 3 / 4 + 5, sc_item_size.width - 40, 25)
//                let lblFav = UILabel(frame: lblRect)
//                lblFav.textColor = UIColor.blackColor()
//                lblFav.text = "Favorites"
//                lblFav.textAlignment = NSTextAlignment.Center
//                lblFav.font = UIFont.systemFontOfSize(19)
//                
//                let imgRect = CGRectMake(sc_item_size.width / 3, sc_item_size.height / 3, sc_item_size.width / 3, sc_item_size.height / 3)
//                let imgFav = UIImageView(frame: imgRect)
//                //                imgFav.backgroundColor = UIColor.redColor()
//                imgFav.image = UIImage(named: "blue_fav_large")
//                
//                let btnRect = itemCell.bounds
//                let btnFav = UIButton(frame: btnRect)
//                btnFav.addTarget(self, action: "buttonFavList", forControlEvents: .TouchUpInside)
                
//                itemCell.addSubview(bgImageCell)
//                itemCell.addSubview(lblFav)
//                itemCell.addSubview(imgFav)
//                itemCell.addSubview(btnFav)
                
                
                itemCell.lblPlaylistName.text = "Favorites"
                let imgFav = UIImage(named: "blue_fav_large")
                itemCell.imgThumbnail.image = UIImage(named: "blue_fav_large")
                let imgSize = imgFav?.size
                let imgWidth = itemCell.bounds.width / 3
                let imgHeight = imgWidth * ((imgSize?.height)! / (imgSize?.width)!)
                itemCell.imgThumbnail.frame = CGRectMake((itemCell.bounds.width - imgWidth) / 2, (itemCell.bounds.height - imgHeight) / 2, imgWidth, imgHeight)
                itemCell.btnOverall.addTarget(self, action: #selector(ProfilePlaylistViewController.buttonFavList), forControlEvents: .TouchUpInside)
                itemCell.tag = 0
                itemCell.btnDelete.alpha = 0
                itemCell.btnEdit.alpha = 0
                itemCell.btnDelete.tag = 0
                itemCell.btnEdit.tag = 0
                
            } else if (i == itemCount - 1) {
                
//                let bgImageCell = UIImageView(frame: itemCell.bounds)
//                bgImageCell.image = UIImage()
//                
//                let imgRect = CGRectMake(sc_item_size.width / 3, sc_item_size.height / 3, sc_item_size.width / 3, sc_item_size.height / 3)
//                let imgFav = UIImageView(frame: imgRect)
//                //                imgFav.backgroundColor = UIColor.blueColor()
//                imgFav.image = UIImage(named: "blue_add_large")
//                
//                let btnRect = itemCell.bounds
//                let btnFav = UIButton(frame: btnRect)
//                btnFav.addTarget(self, action: "buttonAdd", forControlEvents: .TouchUpInside)
//                
//                itemCell.addSubview(bgImageCell)
//                itemCell.addSubview(imgFav)
//                itemCell.addSubview(btnFav)
                let imgAdd = UIImage(named: "blue_add_large")
                itemCell.imgThumbnail.image = UIImage(named: "blue_add_large")
                let imgSize = imgAdd?.size
                let imgWidth = itemCell.bounds.width / 3
                let imgHeight = imgWidth * ((imgSize?.height)! / (imgSize?.width)!)
                itemCell.imgThumbnail.frame = CGRectMake((itemCell.bounds.width - imgWidth) / 2, (itemCell.bounds.height - imgHeight) / 2, imgWidth, imgHeight)
                itemCell.btnOverall.addTarget(self, action: #selector(ProfilePlaylistViewController.buttonAdd), forControlEvents: .TouchUpInside)
                itemCell.tag = i
                itemCell.btnDelete.alpha = 0
                itemCell.btnEdit.alpha = 0
                itemCell.btnDelete.tag = i
                itemCell.btnEdit.tag = i
            } else {
                
                let k = self.isFav == false ? i - 1 : i;
                let playlist_item = self.array_playlist[k]
                
//                let bgImageCell = UIImageView(frame: itemCell.bounds)
//                bgImageCell.image = UIImage()
//                let lblRect = CGRectMake(20, sc_item_size.height * 3 / 4 + 5, sc_item_size.width - 40, 25)
//                let lblFav = UILabel(frame: lblRect)
//                lblFav.textColor = UIColor.blackColor()
//                lblFav.textAlignment = NSTextAlignment.Center
//                lblFav.font = UIFont.systemFontOfSize(19)
//                lblFav.text = playlist_item.name
//                
//                let logo_Img = UIImage(named: "logo_small")
//                let imgSize = logo_Img?.size
//                let imgWidth = sc_item_size.width / 3
//                let imgHeight = imgWidth * ((imgSize?.height)! / (imgSize?.width)!)
//                
//                let imgRect = CGRectMake(sc_item_size.width / 3, sc_item_size.height / 2 - imgHeight / 2, imgWidth, imgHeight)
//                let imgFav = UIImageView(frame: imgRect)
//                //                imgFav.backgroundColor = UIColor.redColor()
//                imgFav.image = logo_Img
//                
//                let btnRect = itemCell.bounds
//                let btnFav = UIButton(frame: btnRect)
//                btnFav.tag = k
//                btnFav.addTarget(self, action: "buttonPlaylist:", forControlEvents: .TouchUpInside)
//                
//                itemCell.addSubview(bgImageCell)
//                itemCell.addSubview(imgFav)
//                itemCell.addSubview(lblFav)
//                itemCell.addSubview(btnFav)
                
                
                itemCell.lblPlaylistName.text = playlist_item.name
                let imgLogo = UIImage(named: "logo_small")
                let imgSize = imgLogo?.size
                let imgWidth = itemCell.bounds.width / 3
                let imgHeight = imgWidth * ((imgSize?.height)! / (imgSize?.width)!)
                itemCell.imgThumbnail.frame = CGRectMake((itemCell.bounds.width - imgWidth) / 2, (itemCell.bounds.height - imgHeight) / 2, imgWidth, imgHeight)
                itemCell.imgThumbnail.image = UIImage(named: "logo_small")
                itemCell.tag = i
                itemCell.btnOverall.tag = k
                itemCell.btnOverall.addTarget(self, action: #selector(ProfilePlaylistViewController.buttonPlaylist(_:)), forControlEvents: .TouchUpInside)
                itemCell.btnDelete.alpha = 0
                itemCell.btnEdit.alpha = 0
                itemCell.btnDelete.tag = k
                itemCell.btnEdit.tag = k
                itemCell.btnEdit.addTarget(self, action: #selector(ProfilePlaylistViewController.actionEdit(_:)), forControlEvents: .TouchUpInside)
                itemCell.btnDelete.addTarget(self, action: #selector(ProfilePlaylistViewController.actionDelete(_:)), forControlEvents: .TouchUpInside)
            }
            cellArray += [itemCell];
            itemCell.layer.borderWidth = 0.5
            itemCell.layer.borderColor = UIColor.darkGrayColor().CGColor
            self.scPlaylists.addSubview(itemCell)
        }
        isSetup = true;
        self.scPlaylists.contentSize = CGSizeMake(scVwSize.width, sc_item_size.height * CGFloat(vertical_items))
    }
    func buttonFavList() {
        NSLog("Log");
        self.lblPlaylistTitle.text = "My Playlist"
        wsManager.getUserFavoriteVideos(completionHandler: { (items) -> Void in
            self.videos = items
            Singleton.sharedInstance.user.favorites = items;
            Singleton.sharedInstance.user.retrievedFavorites = true;
            if (Singleton.sharedInstance.userFavPlaylist != nil) {
                self.userPlaylist = Singleton.sharedInstance.userFavPlaylist
            }
            self.playlist_type = "Fav"
            self.playlist_name = "My Playlist"
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("showPlaylistDetail", sender: self)
                /**if self.currentEditMode == false {
                    self.performSegueWithIdentifier("showPlaylistDetail", sender: self)
                } else {
                    self.performSegueWithIdentifier("showEditPlaylist", sender: self)
                }**/
                
            })
            
            
        });
        
        
    }
    func buttonAdd() {
        NSLog("Log");
        currentEditMode = false
        self.vwCreatePlaylist.alpha = 1
        
        /**if currentEditMode == false {
            self.vwCreatePlaylist.alpha = 1
        } else {
            for vw in self.scPlaylists.subviews {
                vw.layer.borderColor = UIColor.whiteColor().CGColor
            }
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            currentEditMode = false
        }**/
        
    }
    func buttonPlaylist(sender : UIButton) {
        NSLog("Log");
//        let playlist = self.isFav == false ? self.array_playlist[sender.tag + 1] : self.array_playlist[sender.tag]
//        let playlist = self.array_playlist[sender.tag]
        let playlist = self.array_playlist[sender.tag];
        self.lblPlaylistTitle.text = playlist.name
        wsManager.getVideoListFromPlaylist(playlist.id) { (videos) -> Void in
            self.videos = videos
            self.playlist_type = "Custom"
            self.playlist_name = playlist.name
            self.userPlaylist = playlist
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("showPlaylistDetail", sender: self)
                /**if self.currentEditMode == false {
                    self.performSegueWithIdentifier("showPlaylistDetail", sender: self)
                } else {
                    self.performSegueWithIdentifier("showEditPlaylist", sender: self)
                }**/
                
            })
            
        }
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? PlaylistVC {
            var vs = [String]()
            for i in 0  ..< videos.count{
                let video = videos[i]
                vs += [video.ooyalaId];
                destination.addVideoToDict(video)
            }
            destination.playlist = vs
            destination.playlist_type = self.playlist_type
            destination.userPlaylist = self.userPlaylist
            destination.recommendedVideosPlaylist = vs
        }
        if let destination = segue.destinationViewController as? ProfileViewController{
            destination.playlist_type = self.playlist_type
            destination.videos = self.videos
            destination.userPlaylistName = self.playlist_name
        } else {
            let destination = segue.destinationViewController as? PlaylistEditViewController
            destination?.userPlaylist = self.userPlaylist
            destination?.playlist_type = self.playlist_type
            destination?.playlistName = self.playlist_name
            destination?.videos = self.videos
        }
    }
    func setupUserInfo() {
        self.lblFullName.text =
            (Singleton.sharedInstance.user.firstName! + " " + Singleton.sharedInstance.user.lastName!).uppercaseString //"Paul David Hewson".uppercaseString
        self.lblUserPoints.text = (Singleton.sharedInstance.user.points! + " POINTS")  //.uppercaseString
        if(Singleton.sharedInstance.user.avatarImage != nil){
            self.imgLogoSolo.image = Singleton.sharedInstance.user.avatarImage;
        }else{
            if(Singleton.sharedInstance.user.avatarUrlString != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    let avatarUrl = NSURL(string: Singleton.sharedInstance.user.avatarUrlString!);
                    wsManager.downloadImage2(avatarUrl, completionHandler: { (image) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imgLogoSolo.image = image ?? UIImage(named: "logo_small")!
                            Singleton.sharedInstance.user.avatarImage = image;
                        });
                    });
                }
                
            }
        }
        if(Singleton.sharedInstance.user.coverImage != nil){
            self.backImage.image = Singleton.sharedInstance.user.coverImage;
        }else{
            if(Singleton.sharedInstance.user.coverPhotoUrlString != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    let coverUrl = NSURL(string: Singleton.sharedInstance.user.coverPhotoUrlString!);
                    wsManager.downloadImage2(coverUrl, completionHandler: { (image) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.backImage.image = image ?? UIImage(named: "graffiti.jpg")!
                            Singleton.sharedInstance.user.coverImage = image;
                        });
                    });
                }
                
            }
        }
        
        
    }
    func arrangePlaylists() {
        self.array_playlist = [];
        self.isFav = false;
        for item in Singleton.sharedInstance.userPlaylists {
            let objectItem = item.objectForKey("user_playlist") as! NSDictionary
            let list_name = objectItem.objectForKey("name") as! String
            let category = Playlist(id: objectItem["id"] as? String ?? "", name: objectItem["name"] as? String ?? "", thumbnailURL: objectItem["thumbnail"] as? String ?? "", imageURL: objectItem["image"] as? String ?? "")
            if list_name == "Favorites" {
                //                itemFav = objectItem
                self.array_playlist.insert(category, atIndex: 0)
                Singleton.sharedInstance.userFavPlaylist = category
                self.isFav = true;
            } else {
                self.array_playlist.append(category)
            }
        }
        NSLog("Log");
    }
    func deletePlaylistFromList(playlist : Playlist) {
        if (self.array_playlist.contains(playlist)) {
            let index = self.array_playlist.indexOf(playlist)
            self.array_playlist.removeAtIndex(index!)
            
        }
    }
    func actionDelete(sender: UIButton) {
        
        let alertConfirm = UIAlertController(title: "Delete Playlist?", message: "", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Yes", style: .Default) { UIAlertAction in
            if (self.isFav == false) {
                let customview = self.getCustomViewbyIndex(sender.tag + 1)
                customview.btnDelete.alpha = 0
                customview.btnEdit.alpha = 0
            } else {
                let customview = self.getCustomViewbyIndex(sender.tag)
                customview.btnDelete.alpha = 0
                customview.btnEdit.alpha = 0
            }
            self.userPlaylist = self.array_playlist[sender.tag]
//            self.lblPlaylistTitle.textColor = UIColor.whiteColor()
            self.wsManager.deletePlaylist(self.userPlaylist.id) { (result,root) -> Void in
                NSLog("Log");
                if result == "Success" {
                    //                self.deletePlaylistFromList(self.userPlaylist)
                    let items = root as [NSDictionary]
                    
                    Singleton.sharedInstance.userPlaylists = items
                    self.arrangePlaylists()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.vwCreatePlaylist.alpha = 0
                        self.txtPlaylistName.text = "";
                        self.lblPlaylistTitle.text = "My Playlist"
                        self.buildScrollView()
                        self.showDeleteResultAlert("Result", message: "Removed playlist successfully.", okTitle: "OK")
                        
                    })
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showDeleteResultAlert("Result?", message: "Failed to remove playlist", okTitle: "OK")
                    })
                    
                }
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alertConfirm.addAction(okAction)
        alertConfirm.addAction(cancelAction)
        
        self.presentViewController(alertConfirm, animated: true, completion: nil)
        
    }
    func showDeleteResultAlert(title : String, message : String, okTitle: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: okTitle, style: .Cancel, handler: nil)
        alertVC.addAction(okAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    func actionEdit(sender: UIButton) {
        currentEditMode = true
        self.vwCreatePlaylist.alpha = 1
        if (self.isFav == false) {
            let customview = self.getCustomViewbyIndex(sender.tag + 1)
            customview.btnDelete.alpha = 0
            customview.btnEdit.alpha = 0
        } else {
            let customview = self.getCustomViewbyIndex(sender.tag)
            customview.btnDelete.alpha = 0
            customview.btnEdit.alpha = 0
        }
        
        self.userPlaylist = self.array_playlist[sender.tag]
//        self.lblPlaylistTitle.textColor = UIColor.whiteColor()
    }
    @IBAction func goWatching(sender: AnyObject) {
        if Singleton.sharedInstance.watchingVC != nil {
            Singleton.sharedInstance.watchingVC?.fromSearch = false
            if Singleton.sharedInstance.watchingVC?.player?.isPlaying() == false {
                Singleton.sharedInstance.watchingVC?.player?.play()
            }
            self.navigationController?.pushViewController(Singleton.sharedInstance.watchingVC!, animated: true)
        } else {
            let alert = UIAlertController(title: "Unknown Error!", message:"There happens unknown error.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            // Add the actions
            alert.addAction(okAction)
            
            // Present the controller
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var btnSubmit: UIButton!
    @IBAction func actionCreatePlaylist(sender: UIButton) {
        if (self.txtPlaylistName.text != nil) {
            if self.currentEditMode == false {
                let playlistName = self.txtPlaylistName.text
                self.view.endEditing(true)
                wsManager.createUserPlaylistURL(playlistName!, completionHandler: { (success, message, root) in
                    if success == true {
                        let items = root as [NSDictionary]
                        if items.count > 0 {
                            Singleton.sharedInstance.userPlaylists = items
                            self.arrangePlaylists()
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.vwCreatePlaylist.alpha = 0
                                self.txtPlaylistName.text = "";
                                self.buildScrollView()
                            })
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.vwCreatePlaylist.alpha = 0
                            self.txtPlaylistName.text = "";
                            self.lblPlaylistTitle.text = "My Playlist"
                            self.showDeleteResultAlert("Error", message: message!, okTitle: "OK")
                        })
                    }
                })
                
            } else {
                let playlistName = self.txtPlaylistName.text
                self.view.endEditing(true)
                self.wsManager.renamePlaylist(self.userPlaylist.id,playlistName : playlistName!) { (result,root) -> Void in
                    NSLog("Log");
                    if result == "Success" {
                        //                self.deletePlaylistFromList(self.userPlaylist)
                        let items = root as [NSDictionary]
                        if items.count > 0 {
                            Singleton.sharedInstance.userPlaylists = items
                            self.arrangePlaylists()
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.vwCreatePlaylist.alpha = 0
                                self.txtPlaylistName.text = "";
                                self.lblPlaylistTitle.text = "My Playlist"
                                self.currentEditMode = true
                                self.buildScrollView()
                                self.showDeleteResultAlert("Result?", message: "Rename playlist successfully.", okTitle: "OK")
                                
                            })
                        }
                        
                    } else {
                        self.currentEditMode = true
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.vwCreatePlaylist.alpha = 0
                            self.txtPlaylistName.text = "";
                            self.lblPlaylistTitle.text = "My Playlist"
                            self.showDeleteResultAlert("Result?", message: "Failed to rename playlist", okTitle: "OK")
                        })
                    }
                }
            }
            
            
        } else {
            let alertVC = UIAlertController(title: "Playlist Title?", message: "Please enter playlist name.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil);
            alertVC.addAction(cancelAction);
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionCancel(sender: UIButton) {
        self.vwCreatePlaylist.alpha = 0
        self.currentEditMode = false        
        self.txtPlaylistName.text = ""
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
        
        self.buildScrollView()
        
    }
    func navigateScrollViewPopup(){
        let deviceSize = UIScreen.mainScreen().bounds.size
        let vwFrame = self.vwCreatePlaylist.frame
        if (keyHeight < 10) {
            keyHeight = 260
        }
        let offset = vwFrame.origin.y + self.txtPlaylistName.frame.origin.y + self.txtPlaylistName.frame.size.height - (deviceSize.height - keyHeight)
        let contentHeight = self.btnSubmit.frame.origin.y + self.btnSubmit.frame.size.height + 50 + keyHeight
        if (offset > 0) {
            self.scTextContent.setContentOffset(CGPointMake(0, offset), animated: true)
        }
        self.scTextContent.contentSize = CGSizeMake(self.scTextContent.frame.width, contentHeight)
    }
    func navigateScrollViewDismiss(){
//        self.scTextContent.setContentOffset(CGPointMake(0, 0), animated: true)
        self.scTextContent.contentSize = CGSizeMake(self.scTextContent.frame.width, self.scTextContent.frame.height)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProfilePlaylistViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        self.navigateScrollViewPopup()
        return
    }
    func textFieldDidEndEditing(textField: UITextField) {
        
        return
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.navigateScrollViewDismiss()
        textField.resignFirstResponder();
        //        textField.borderStyle = UITextBorderStyle.None
        return true
    }
}