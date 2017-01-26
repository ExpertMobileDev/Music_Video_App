//
//  StretchyHeaderFlowLayout.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/2/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class StretchyHeaderFlowLayout: UICollectionViewFlowLayout {
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		//println("[SFFL] layoutAttributesForElementsInRect \(NSStringFromCGRect(rect))")
		
		let items = super.layoutAttributesForElementsInRect(rect)!// as! [UICollectionViewLayoutAttributes]
		
		let collectionView = self.collectionView!
		let insets: UIEdgeInsets = collectionView.contentInset // {0, 0, 0, 0}
		let offset: CGPoint = collectionView.contentOffset
		let minY: CGFloat = -insets.top
		
		//println("[SFFL] collection size: \(NSStringFromCGSize(collectionViewContentSize())), collection frame: \(NSStringFromCGRect(collectionView.frame))")
		//println("[SFFL] collection offset: \(NSStringFromCGPoint(offset)), offset.y: \(offset.y) pts, minY: \(minY) pts")
		
		if offset.y < minY { // pulling from the top
			let delta = fabs(offset.y - minY) // positive delta
			var betaHeader: CGFloat = 0 // delta * 0.50
			//let betaCell = delta * 0.10
			//println("[SFFL] stretching top by \(delta) pts")
			for item in items {
				//let numberOfCellsBefore = numberOfCellsBeforeSection(item.indexPath.section)
				var frame = item.frame
				//println("[SFFL] element \(item.indexPath.section) - \(item.indexPath.row), initial frame: \(NSStringFromCGRect(item.frame))")
				//println("[SFFL] item: \(item), kind: \(item.representedElementKind), category: \(item.representedElementCategory.rawValue)")
				betaHeader = delta * 0.50
				if let kind = item.representedElementKind where kind == UICollectionElementKindSectionHeader {
					let headerSize = headerReferenceSize
					frame.size.height = max(minY, headerSize.height + betaHeader)
					frame.origin.y = frame.origin.y - delta + (betaHeader * CGFloat(item.indexPath.section)) //+ (betaCell * CGFloat(numberOfCellsBefore))
				//} else if item.representedElementCategory == UICollectionElementCategory.Cell {
				//	frame.size.height = itemSize.height + betaCell
				//	frame.origin.y = frame.origin.y - delta + (betaHeader * CGFloat(item.indexPath.section + 1)) + (betaCell * CGFloat(numberOfCellsBefore)) + (betaCell * CGFloat(item.indexPath.row))
				}
				item.frame = frame
				//println("[SFFL] element \(item.indexPath.section) - \(item.indexPath.row), final frame: \(NSStringFromCGRect(item.frame))")
			}
		} /*else {
			var maxScreenOffset = collectionViewContentSize().height - collectionView.frame.size.height;
			//println("[SFFL] maxScreenOffset: \(maxScreenOffset) pts");
			
			if offset.y > fabs(maxScreenOffset) { // pulling from the bottom
				let delta = offset.y - maxScreenOffset // positive delta
				var betaHeader:CGFloat = 0 // delta * 0.50
				let betaCell = delta * 0.10
				//println("[SFFL] stretching bottom by \(delta) pts")
				for item in items {
					let numberOfSectionsAfter = numberOfSectionsAfterSection(item.indexPath.section)
					let numberOfCellsAfter = numberOfCellsAfterIndexPath(item.indexPath)
					var frame = item.frame
					//println("[SFFL] element \(item.indexPath.section) - \(item.indexPath.row), initial frame: \(NSStringFromCGRect(item.frame))")
					//println("[SFFL] item: \(item), kind: \(item.representedElementKind), category: \(item.representedElementCategory.rawValue)")
					betaHeader = delta * 0.50
					if let kind = item.representedElementKind where kind == UICollectionElementKindSectionHeader {
						let headerSize = headerReferenceSize
						frame.size.height = max(minY, headerSize.height + betaHeader)
						frame.origin.y = frame.origin.y + delta - (betaHeader * CGFloat(numberOfSectionsAfter + 1)) - (betaCell * CGFloat(numberOfCellsAfter))
					} else if item.representedElementCategory == UICollectionElementCategory.Cell {
						frame.size.height = itemSize.height + betaCell
						frame.origin.y = frame.origin.y + delta - (betaHeader * CGFloat(numberOfSectionsAfter)) - (betaCell * CGFloat(numberOfCellsAfter))
					}
					item.frame = frame;
					//println("[SFFL] element \(item.indexPath.section) - \(item.indexPath.row), final frame: \(NSStringFromCGRect(item.frame))")
				}
			} else {
				for item in items {
					if item.representedElementCategory == UICollectionElementCategory.Cell {
						var frame = item.frame
						var delta = offset.y - frame.origin.y
						//println("[SFFL] cell \(item.indexPath.section) - \(item.indexPath.row), \(NSStringFromCGRect(frame))")
						//println("[SFFL] offset: \(offset.y), delta \(delta)")
						// delta > 0  means item is on top of screen and about to go out of visible area OR item is out of visible aerea if newHeight is = 0
						// delta < 0 means item is below offscreen, still in visible area
						if delta > 0 {
							var newHeight = max(0, self.itemSize.height - delta)
							if newHeight > 0 {
								//println("[SFFL] dissapeaing cell item.indexPath.section, item.indexPath.row");
								frame.origin.y += fabs(delta)
								frame.size.height = newHeight
								item.frame = frame
								//println("[SFFL] final frame item.indexPath.section, item.indexPath.row, NSStringFromCGRect(frame)");
							} else {
								// no frame change needed
							}
						}
					}
				}
				
			}
		}*/
		
		return items
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		return true
	}
	
}
