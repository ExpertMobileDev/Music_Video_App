//
//  VideoChannelsViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/10/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class EMNCategoryViewController: PortraitViewController {
	
	private let interitemSpacing: CGFloat = 0
	private let numberOfColumns: CGFloat = 2
	private var wsManager: WebserviceManager!
	private let showArtistPageSegueID = "showArtistPageSegue"
    private var isLoading = false
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var noDataLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var isPlaylist = false
	var items = [EMNCategory]()
	var refreshControl = UIRefreshControl()
	var categoryType: EMNCategoryType!
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
	override func viewDidLoad() {
		super.viewDidLoad()
		noDataLabel.hidden = true
        isLoading = false
		wsManager = WebserviceManager()
		
		refreshControl.addTarget(self, action:#selector(EMNCategoryViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
		collectionView.alwaysBounceVertical = true
		collectionView.addSubview(refreshControl)
	}
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isLoading = false
    }
	func downloadImageForItem(item: EMNCategory, indexPath: NSIndexPath) {
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.downloadImage2(item.thumbnailURL, completionHandler: { (image) -> Void in
                item.thumbnail = image ?? (item as? Playlist != nil ? UIImage(named: "coverArt_grey_box")!: UIImage(named: "coverArt")!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? CategoryCollectionViewCell { // cell is nil for cells not visible in screen
                        cell.activityIndicator.stopAnimating()
                        cell.thumbnailImageView.image = item.thumbnail
                    }
                })
            })
        }
		
	}
	
	func refreshData() {
        if reachabilityHandler.verifyInternetConnection() == true {
            activityIndicator.startAnimating()
            wsManager.getItemsInEMNCategory(categoryType, completionHandler: { (items) -> Void in
                if let items = items as? [Channel] {
                    self.items = items
                } else if let items = items as? [Mood] {
                    self.items = items
                } else if let items = items as? [Playlist] {
                    self.items = items
                    self.isPlaylist = true
                } else  if let items = items as? [EMNCategory] {
                    print("[EMNCategoryViewController] Items fell through: \(items)");
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.noDataLabel.hidden = !(items.count == 0)
                })
            })
        }
		
	}
	
}

extension EMNCategoryViewController: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
		let item = items[indexPath.row]
		
		cell.categoryName.text = isPlaylist ? item.name.uppercaseString : ""
        cell.categoryName.lineBreakMode = .ByWordWrapping;
        cell.categoryName.numberOfLines = 0;
		cell.thumbnailImageView.image = nil
		if let thumbnail = item.thumbnail {
			cell.thumbnailImageView.image = thumbnail
		} else {
			cell.activityIndicator.startAnimating()
			if collectionView.dragging == false && collectionView.decelerating == false {
				downloadImageForItem(item, indexPath: indexPath)
			}
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
}

extension EMNCategoryViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if UIDevice.currentDevice().orientation.isLandscape == true {
            Singleton.sharedInstance.currentScreenMode = "Landscape"
        } else if UIDevice.currentDevice().orientation.isPortrait == true {
            Singleton.sharedInstance.currentScreenMode = "Portrait"
        } else {
            Singleton.sharedInstance.currentScreenMode = "Other"
        }
        if reachabilityHandler.verifyInternetConnection() == true {
            if !self.isLoading {
                self.isLoading = true
                let item = items[indexPath.row]
                activityIndicator.startAnimating()
                wsManager.downloadImage2(item.imageURL, completionHandler: { (image) -> Void in
                    //item.image = image
                    item.image = image ?? (item as? Playlist != nil ? UIImage(named: "coverArt_grey_box")!: UIImage(named: "coverArt")!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityIndicator.stopAnimating()
                        //                    self.parentViewController?.performSegueWithIdentifier(self.showArtistPageSegueID, sender: item)
                        if let destination = self.storyboard?.instantiateViewControllerWithIdentifier("ArtistPageViewController") as? ArtistPageViewController {
                            destination.emnCategory = item // sender => items[indexPath.row]
                            destination.isTitleHidden = item as? Playlist == nil
                            destination.from = .Home;
                            self.navigationController?.pushViewController(destination, animated: true)
                        }
                        
                    })
                })
            }
        }
        
	}
}

extension EMNCategoryViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return interitemSpacing
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let size = collectionView.bounds.size
		let availableWidth = size.width - (numberOfColumns - 1) * interitemSpacing
		let a = floor(availableWidth / numberOfColumns)
		return CGSize(width: a, height: a)
	}
	
}

extension EMNCategoryViewController: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if scrollView == collectionView {
			loadOnScreenCellsThumbnails()
		}
	}
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if scrollView == collectionView && !decelerate { // scrollview is stopped
			loadOnScreenCellsThumbnails()
		}
	}
	
	func loadOnScreenCellsThumbnails() {
		for indexPath in collectionView.indexPathsForVisibleItems() {
			let item = items[indexPath.row]
			if let _ = item.thumbnail {
				// thumbnail was already downloaded
			} else {
				downloadImageForItem(item, indexPath: indexPath)
			}
		}
	}
	
}

extension EMNCategoryViewController: NSURLSessionDelegate {
	
}
