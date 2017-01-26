//
//  AlertControllerManager.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import StoreKit

class AlertControllerManager: NSObject {
	
	func alertForCustomMessage(errorTitle: String ,errorMessage: String, handler: (UIAlertAction!)->Void) -> UIAlertController {
		let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: handler))
		return alert
	}
    func alertForInAppPurchaseMessage() -> UIAlertController {
        let alert = UIAlertController(title: "Purchase", message:"Item purchase successed!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    func alertForCancelSubscriptionMessage() -> UIAlertController {
        let alert = UIAlertController(title: "Subscription", message:"Subscription cancelled!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    func alertForCancelSubscriptionFailedMessage() -> UIAlertController {
        let alert = UIAlertController(title: "Subscription", message:"Failed to cancel subscription!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
	func alertForServerError(errorTitle: String ,errorMessage: String) -> UIAlertController {
		let alert = UIAlertController(title: errorTitle , message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
    func alertForPremiumLoadError() -> UIAlertController {
        let alert = UIAlertController(title: "Go Premium", message:"Watch premium videos and earn double points by upgrading your account.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Go Premium", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
	func alertForEmptyTextField (fieldWithError: String) -> UIAlertController {
		let alert = UIAlertController(title: fieldWithError, message:" ", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
	
	func alertForMaxCharacters(fieldWithError: String) -> UIAlertController {
		let alert = UIAlertController(title: fieldWithError, message:"Text is too long (maximum is 64 characters)", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
	
	func alertForLessThanMinCharacters(fieldWithError: String) -> UIAlertController {
		let alert = UIAlertController(title: fieldWithError, message:"Text is too short (minimum is 6 characters)", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
    func alertForUpgrade () -> UIAlertController {
        let alert = UIAlertController(title: "Account Upgrade", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Basic", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            NSLog("Basic")
        }))
        alert.addAction(UIAlertAction(title: "Preminum", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            NSLog("Preminum")
        }))
        alert.addAction(UIAlertAction(title: "Downgrade", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            NSLog("Downgrade")
        }))
        return alert
    }
	func alertForFailInInternetConnection () -> UIAlertController {
		let alert = UIAlertController(title: "Internet'connection needed", message:"To use this App please connect to Internet", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
	
	func alertForNotEmailString () -> UIAlertController {
		let alert = UIAlertController(title: "Invalid email", message:"Please enter your email in the format someone@example.com", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
	
	
	func alertForSuccesfulSentEmail (handler: ((UIAlertAction!)->Void)?)  -> UIAlertController {
		let alert = UIAlertController(title: "Email Sent", message:
			"The email with the recorvery instructions has been sent", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: handler))
		
		return alert
	}
	
	func alertForSuccesfulCreatedAccount (handler: ((UIAlertAction!)->Void)?)  -> UIAlertController {
		let alert = UIAlertController(title: "Account Created", message:
			"Your account has been created successfully", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: handler))
		
		return alert
	}
	
	func alertForSuccesfulSavedChanges (handler: ((UIAlertAction!)->Void)?)  -> UIAlertController {
		let alert = UIAlertController(title: "Profile Updated", message:
			"Your information has been updated successfully", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: handler))
		
		return alert
	}
	
}
