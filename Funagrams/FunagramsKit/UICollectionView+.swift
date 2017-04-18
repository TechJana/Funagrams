//
//  UICollectionView+.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit

public enum AutoScrollDirection: Int {
    case invalid = 0
    case towardsOrigin = 1
    case awayFromOrigin = 2
}

@objc public protocol DrapDropCollectionViewDelegate {
    func dragDropCollectionViewDidMoveCellFromInitialIndexPath(_ initialIndexPath: IndexPath, toNewIndexPath newIndexPath: IndexPath)
    @objc optional func dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath(_ indexPath: IndexPath)
    @objc optional func dragDropCollectionViewDraggingDidEndForCellAtIndexPath(_ indexPath: IndexPath)
}

extension UICollectionView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public func getRasterizedImageCopyOfCell(_ cell: UICollectionViewCell) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    public func autoScroll(_ direction: AutoScrollDirection, currentLongPressTouchLocation: CGPoint, draggingView: UIView?) {
        var increment: CGFloat
        var newContentOffset: CGPoint
        if (direction == AutoScrollDirection.towardsOrigin) {
            increment = -50.0
        } else {
            increment = 50.0
        }
        newContentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + increment)
        if ((direction == AutoScrollDirection.towardsOrigin && newContentOffset.y < 0) || (direction == AutoScrollDirection.awayFromOrigin && newContentOffset.y > self.contentSize.height - self.frame.height)) {
            Helper.dispatchOnMainQueueAfter(0.3, closure: { () -> () in
                //self.isAutoScrolling = false
            })
        } else {
            UIView.animate(withDuration: 0.3
                , delay: 0.0
                , options: UIViewAnimationOptions.curveLinear
                , animations: { () -> Void in
                    self.setContentOffset(newContentOffset, animated: false)
                    if (draggingView != nil) {
                        var draggingFrame = draggingView!.frame
                        draggingFrame.origin.y += increment
                        draggingView!.frame = draggingFrame
                    }
            }) { (finished) -> Void in
                Helper.dispatchOnMainQueueAfter(0.0, closure: { () -> () in
                    let updatedTouchLocationWithNewOffset = CGPoint(x: currentLongPressTouchLocation.x, y: currentLongPressTouchLocation.y + increment)
                    let scroller = self.shouldAutoScroll(updatedTouchLocationWithNewOffset, currentTouchLocation: currentLongPressTouchLocation)
                    if scroller.shouldScroll {
                        self.autoScroll(scroller.direction, currentLongPressTouchLocation: updatedTouchLocationWithNewOffset, draggingView: draggingView)
                    } else {
                        //self.isAutoScrolling = false
                    }
                })
            }
        }
    }
    
    public func shouldAutoScroll(_ previousTouchLocation: CGPoint, currentTouchLocation: CGPoint) -> (shouldScroll: Bool, direction: AutoScrollDirection) {
        let previousTouchLocation = self.convert(previousTouchLocation, to: self.superview)
        
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            if !Double(currentTouchLocation.x).isNaN && !Double(currentTouchLocation.y).isNaN {
                if Helper.distanceBetweenPoints(previousTouchLocation, secondPoint: currentTouchLocation) < CGFloat(20.0) {
                    let scrollDirection = flowLayout.scrollDirection
                    var scrollBoundsSize: CGSize
                    let scrollBoundsLength: CGFloat = 50.0
                    var scrollRectAtEnd: CGRect
                    switch scrollDirection {
                    case UICollectionViewScrollDirection.horizontal:
                        scrollBoundsSize = CGSize(width: scrollBoundsLength, height: self.frame.height)
                        scrollRectAtEnd = CGRect(x: self.frame.origin.x + self.frame.width - scrollBoundsSize.width , y: self.frame.origin.y, width: scrollBoundsSize.width, height: self.frame.height)
                    case UICollectionViewScrollDirection.vertical:
                        scrollBoundsSize = CGSize(width: self.frame.width, height: scrollBoundsLength)
                        scrollRectAtEnd = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height - scrollBoundsSize.height, width: self.frame.width, height: scrollBoundsSize.height)
                    }
                    let scrollRectAtOrigin = CGRect(origin: self.frame.origin, size: scrollBoundsSize)
                    if scrollRectAtOrigin.contains(currentTouchLocation) {
                        return (true, AutoScrollDirection.towardsOrigin)
                    } else if scrollRectAtEnd.contains(currentTouchLocation) {
                        return (true, AutoScrollDirection.awayFromOrigin)
                    }
                }
            }
        }
        return (false, AutoScrollDirection.invalid)
    }
    
    public func shouldSwapCells(_ previousTouchLocation: CGPoint, currentTouchLocation: CGPoint, draggedCellIndexPath: IndexPath?) -> (shouldSwap: Bool, newIndexPath: IndexPath?) {
        var shouldSwap = false
        var newIndexPath: IndexPath?
        if !Double(currentTouchLocation.x).isNaN && !Double(currentTouchLocation.y).isNaN {
            if Helper.distanceBetweenPoints(previousTouchLocation, secondPoint: currentTouchLocation) < CGFloat(20.0) {
                if let newIndexPathForCell = self.indexPathForItem(at: currentTouchLocation) {
                    if newIndexPathForCell != draggedCellIndexPath! as IndexPath {
                        shouldSwap = true
                        newIndexPath = newIndexPathForCell
                    }
                }
            }
        }
        return (shouldSwap, newIndexPath)
    }

    public func swapDraggedCellWithCellAtIndexPath(_ newIndexPath: IndexPath, draggedCellIndexPath: IndexPath?, draggingDelegate: DrapDropCollectionViewDelegate?) -> IndexPath {
        self.moveItem(at: draggedCellIndexPath! as IndexPath, to: newIndexPath as IndexPath)
        let draggedCell = self.cellForItem(at: newIndexPath as IndexPath)!
        draggedCell.alpha = 0
        draggingDelegate?.dragDropCollectionViewDidMoveCellFromInitialIndexPath(draggedCellIndexPath!, toNewIndexPath: newIndexPath)
        
        return newIndexPath
    }
}
