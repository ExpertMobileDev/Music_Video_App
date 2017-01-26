//
//  SlideMenuAnimator.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/12/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class SlideMenuAnimator: UIPercentDrivenInteractiveTransition {
	
	//private let visibleWidthForSlidingOutView: CGFloat = 50
	private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
	private var exitPanGesture: UIPanGestureRecognizer!
	private var interactive = false
	private var presenting = false
	
	var enterSegue: String!
	var exitSegue: String!
	var sourceViewController: UIViewController! {
		didSet {
			enterPanGesture = UIScreenEdgePanGestureRecognizer()
			enterPanGesture.addTarget(self, action: #selector(SlideMenuAnimator.handleOnStagePan(_:)))
			enterPanGesture.edges = UIRectEdge.Left
			sourceViewController.view.addGestureRecognizer(enterPanGesture)
		}
	}
	var menuViewController: UIViewController! {
		didSet {
			exitPanGesture = UIPanGestureRecognizer()
			exitPanGesture.addTarget(self, action: #selector(SlideMenuAnimator.handleOffStagePan(_:)))
			menuViewController.view.addGestureRecognizer(exitPanGesture)
		}
	}
}

extension SlideMenuAnimator: UIViewControllerAnimatedTransitioning {
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let container = transitionContext.containerView()
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		
		let duration = transitionDuration(transitionContext)
		let frame = container!.frame
		
		toVC.view.userInteractionEnabled = false
		fromVC.view.userInteractionEnabled = false
		
		if presenting {
			container!.addSubview(toVC.view)
			container!.addSubview(fromVC.view)
			
			toVC.view.frame = CGRect(x: 0, y: 0, width: frame.size.width - visibleWidthForSlidingOutView, height: frame.size.height)
		} else {
			container!.addSubview(fromVC.view)
			container!.addSubview(toVC.view)
			
			toVC.view.frame = CGRect(origin: CGPoint(x: frame.size.width - visibleWidthForSlidingOutView, y: 0), size: frame.size)
		}
		
		UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: presenting ? UIViewAnimationOptions.CurveEaseIn : UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			if self.presenting {
				fromVC.view.frame = CGRect(origin: CGPoint(x: frame.size.width - visibleWidthForSlidingOutView, y: 0), size: frame.size)
			} else {
				toVC.view.frame = frame
			}
			}, completion: { (success: Bool) -> Void in
				if transitionContext.transitionWasCancelled() {
					transitionContext.completeTransition(false)
					UIApplication.sharedApplication().keyWindow!.addSubview(fromVC.view)
					//println("[SMA] transitionWasCancelled (" + (self.presenting ? "" : "not ") + "presenting)")
					fromVC.view.userInteractionEnabled = true
					toVC.view.userInteractionEnabled = true
				} else {
					transitionContext.completeTransition(true)
					UIApplication.sharedApplication().keyWindow!.addSubview(toVC.view)
					//println("[SMA] completeTransition (" + (self.presenting ? "" : "not ") + "presenting)")
					fromVC.view.userInteractionEnabled = true
					toVC.view.userInteractionEnabled = true
				}
		})
		
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.5
	}
	
	func handleOffStagePan(pan: UIPanGestureRecognizer) {
		let translation = pan.translationInView(pan.view!)
		let d = translation.x / CGRectGetWidth(pan.view!.bounds) * -0.5
		switch pan.state {
		case UIGestureRecognizerState.Began:
			interactive = true
			menuViewController.performSegueWithIdentifier(exitSegue, sender: self)
		case UIGestureRecognizerState.Changed:
			updateInteractiveTransition(d)
		default:
			interactive = false
			if d > 0.2 {
				finishInteractiveTransition()
			} else {
				cancelInteractiveTransition()
			}
		}
	}
	
	func handleOnStagePan(pan: UIPanGestureRecognizer) {
		let translation = pan.translationInView(pan.view!)
		let d = translation.x / CGRectGetWidth(pan.view!.bounds) * 0.5
		switch pan.state {
		case UIGestureRecognizerState.Began:
			interactive = true
			sourceViewController.performSegueWithIdentifier(enterSegue, sender: self)
		case UIGestureRecognizerState.Changed:
			updateInteractiveTransition(d)
		default:
			interactive = false
			if d > 0.2 {
				finishInteractiveTransition()
			} else {
				cancelInteractiveTransition()

			}
		}
	}
	
}

extension SlideMenuAnimator: UIViewControllerTransitioningDelegate {
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		presenting = false
		return self
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.presenting = true
		return self
	}
	
	func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactive ? self : nil
	}
	
	func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactive ? self : nil
	}
	
}

