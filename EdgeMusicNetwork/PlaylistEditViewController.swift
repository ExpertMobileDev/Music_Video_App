//
//  PlaylistEditViewController.swift
//  emn
//
//  Created by RobertoAlberta on 5/2/16.
//  Copyright © 2016 Angel Jonathan GM. All rights reserved.
//

import UIKit


class PlaylistEditViewController: PortraitViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var userPlaylist : Playlist!
    var videos = [Video]()
    var playlist_type : String!
    var playlistName : String!
    let wsManager = WebserviceManager()
    let reachabilityHandler = ReachabilityHandler()
    private var longPressGesture: UILongPressGestureRecognizer!
    var picker :UIImagePickerController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblPlaylistName: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var indicatorLarge: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Playlist";
        let menuIcon = UIImage(named: "back")
        let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(PlaylistEditViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = menuButton;
        
        self.picker = UIImagePickerController();
        self.picker.delegate = self
        self.lblPlaylistName.text = self.playlist_type
        if self.playlist_type == "Fav" {
            if(Singleton.sharedInstance.user.coverImage != nil){
                self.imgThumbnail.image = Singleton.sharedInstance.user.coverImage;
            }else{
                if(Singleton.sharedInstance.user.coverPhotoUrlString != nil){
                    if reachabilityHandler.verifyInternetConnection() == true {
                        let coverUrl = NSURL(string: Singleton.sharedInstance.user.coverPhotoUrlString!);
                        wsManager.downloadImage2(coverUrl, completionHandler: { (image) -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.imgThumbnail.image = image ?? UIImage(named: "graffiti.jpg")!
                                Singleton.sharedInstance.user.coverImage = image;
                            });
                        });
                    }
                    
                }
            }
        } else {
            let rightIcon = UIBarButtonItem(title: "Delete", style: .Plain, target: self, action: #selector(PlaylistEditViewController.deleteItem))
            self.navigationItem.rightBarButtonItem = rightIcon
            if let thumbnail = userPlaylist.thumbnail {
                imgThumbnail.image = thumbnail
            } else {
                self.indicatorLarge.alpha = 1
                self.indicatorLarge.startAnimating()
                wsManager.downloadImage2(userPlaylist.thumbnailURL, completionHandler: { (image) -> Void in
                    self.userPlaylist.thumbnail = image ?? UIImage(named: "coverArt")!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.indicatorLarge.stopAnimating()
                        self.indicatorLarge.alpha = 0
                        self.imgThumbnail.image = self.userPlaylist.thumbnail
                    })
                })
            }
        }
        
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(PlaylistEditViewController.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        self.collectionView.reloadData()
    }
    @IBAction func actionUploadThumnail(sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        picker.modalPresentationStyle = .Popover
        presentViewController(picker, animated: true, completion: nil)
    }
    func showMenu(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    func deleteItem() {
        if self.playlist_type == "Fav" {
            
        } else {
            
        }
    }
    func downloadImageForItem(item: Video, indexPath: NSIndexPath)
    {
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.downloadImage2(item.thumbnailURL, completionHandler: { (image) -> Void in
                //item.thumbnail = image
                item.thumbnail = image ?? UIImage(named: "coverArt")!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? CustomPlaylistCell { // cell is nil for cells not visible in screen
                        cell.activityIndicator.alpha = 0
                        cell.activityIndicator.stopAnimating()
                        cell.imgPlyalist.image = item.thumbnail
                    }
                })
            })
        }
        
    }
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break
            }
            if #available(iOS 9.0, *) {
                collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.Changed:
            if #available(iOS 9.0, *) {
                collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.Ended:
            if #available(iOS 9.0, *) {
                collectionView.endInteractiveMovement()
            } else {
                // Fallback on earlier versions
            }
        default:
            if #available(iOS 9.0, *) {
                collectionView.cancelInteractiveMovement()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera) {
            // Access the uncropped image from info dictionary
            let imageToSave1: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage //same but with different way
            UIImageWriteToSavedPhotosAlbum(imageToSave1, nil, nil, nil)
            //self.dismissViewControllerAnimated(true, completion: nil)
        }
        if(info[UIImagePickerControllerOriginalImage] != nil){
            Singleton.sharedInstance.user.coverImage = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        self.imgThumbnail.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if(self.imgThumbnail.image != nil) {
            if self.playlist_type == "Fav" {
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.saveCover(self.imgThumbnail.image!, completionHandler: nil);
                }
            }else{
                
            }
        }
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*dfadsgffdghdfgh
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PlaylistEditViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos.count;
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomPlaylistCell
        let video = self.videos[indexPath.row]
        if let thumbnail = video.thumbnail {
            cell.imgPlyalist.image = thumbnail
        } else {
            cell.activityIndicator.alpha = 1
            cell.activityIndicator.startAnimating()
            if collectionView.dragging == false && collectionView.decelerating == false {
                downloadImageForItem(video, indexPath: indexPath)
            }
        }
        cell.lblPlaylistName.text = video.name
        return cell
    }
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let temp = self.videos.removeAtIndex(sourceIndexPath.item)
        self.videos.insert(temp, atIndex: destinationIndexPath.item)
    }
}
extension PlaylistEditViewController : UICollectionViewDelegate {
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        NSLog("did selected method");
//    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
}
//extension PlaylistEditViewController : LXReorderableCollectionViewDataSource {
//    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
//        let video = self.videos[fromIndexPath.item]
//        
//        self.videos.removeAtIndex(fromIndexPath.item)
//        self.videos.insert(video, atIndex: toIndexPath.item)
//    }
//    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        
//        return true
//    }
//    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
//        
//        if (fromIndexPath.item == toIndexPath.item) {
//            return false
//        }
//        
//        return true
//    }
//}
//extension PlaylistEditViewController : LXReorderableCollectionViewDelegateFlowLayout {
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        NSLog("did begin drag");
//    }
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        NSLog("did end drag");
//    }
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        NSLog("will begin drag");
//    }
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        NSLog("will end drag");
//    }
//}
