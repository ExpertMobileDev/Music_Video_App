//
//  LoginViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/2/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: PortraitViewController{
	
	private var isKeyboardVisible = false
	@IBOutlet weak var userNameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginHighLightButton: UIButton!
	@IBOutlet weak var userPlaceHolderView: UIView!
	@IBOutlet weak var passwordPlaceHolderView: UIView!
    @IBOutlet weak var fbLoginButton:UIButton!
    @IBOutlet weak var scScrollView: UIScrollView!
    
	@IBOutlet weak var scrollViewBottomLayoutConstraint: NSLayoutConstraint!
	
	let wsManager = WebserviceManager()
	let textValidationManager = TextFieldValidationsManager()
	let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var fbLoginResult: FBSDKLoginManagerLoginResult!
    var fbUserObject: NSDictionary!
    
    var firstFbCall: Bool = true;
    
   /* override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if let touch = touches.first as? UITouch {
            // ...
            println("TOUCH EVENT")
            self.view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
		userNameTextField.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
		passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
		
		loginHighLightButton.setImage(nil, forState: UIControlState.Highlighted)
		
        //Test
//        self.userNameTextField.text = "digitalmaster909%40hotmail.com"
//        self.passwordTextField.text = "rihoguk1990526"
        
//        userNameTextField.text = "fiero@emn.com"
//		passwordTextField.text = "password"
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("user") != nil) {
            let dictUser = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSDictionary
            let user_email = dictUser.objectForKey("email") as! String
            let user_password = dictUser.objectForKey("password") as! String
            self.userNameTextField.text = user_email
            self.passwordTextField.text = user_password
        }
        
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(LoginViewController.didTapOutside))
        self.view.addGestureRecognizer(tapRecognizer)
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
        
//        let fbButtonRect = self.fbLoginButton.frame
//        let h = fbButtonRect.origin.y + fbButtonRect.height
//        let contentSize = CGSizeMake(self.scScrollView.frame.width, fbButtonRect.origin.y + fbButtonRect.height)
//        self.scScrollView.contentSize = contentSize
//        //Facebook login
//        if (FBSDKAccessToken.currentAccessToken() != nil)
//        {
//            // User is already logged in, do work such as go to next view controller.
//            self.returnUserData();
//        }
	}
	
    func didTapOutside(){
        self.view.endEditing(true)
    }
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
        
        if(Singleton.sharedInstance.userSignedUpFlag == true){
            //Came from user signup!!! Show root view controller
            Singleton.sharedInstance.userSignedUpFlag = false;
            let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController;
            self.presentViewController(rootViewController, animated: true, completion: nil);
            return;
        }
        
        if(Singleton.sharedInstance.userLoggedInFlag == true){
            Singleton.sharedInstance.userLoggedInFlag = false;
            //Came from user signup!!! Show root view controller
            let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController;
            self.presentViewController(rootViewController, animated: true, completion: nil);
            return;
        }
//        if(Singleton.sharedInstance.userWatchNowFlag == true){
//            Singleton.sharedInstance.userLoggedInFlag = false;
//            let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController;
//            self.presentViewController(rootViewController, animated: true, completion: nil)
//            return;
//        }
        self.navigationController?.navigationBarHidden = true;
		let modalViews: [AnyObject]!  = UIApplication.sharedApplication().keyWindow?.subviews
		
		if let myViews = modalViews {
			if myViews.count > 1 {
				for mview in myViews {
					mview.removeFromSuperview()
				}
			}
        }
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
		
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
	}
	@IBAction func loginToEdge(sender: UIButton) {
		let userTexFieldState = textValidationManager.isContentValid(userNameTextField.text!)
		let passwordTexFieldState = textValidationManager.isContentValid(passwordTextField.text!)
		
		if userTexFieldState == TextFieldValidationResult.OK && passwordTexFieldState == TextFieldValidationResult.OK {
			if reachabilityHandler.verifyInternetConnection() == true {
				
				wsManager.login(userNameTextField.text!, password: passwordTextField.text!) { (user, success, message: String?) -> Void in
					if success {
                        
                        NSUserDefaults.standardUserDefaults().setObject(self.userNameTextField.text, forKey: "user_email")
                        user?.password = self.passwordTextField.text
                        let dictUser = user?.asDictionary()
                        NSUserDefaults.standardUserDefaults().setObject(dictUser, forKey: "user")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //MARK MARK MARK
                            if(user?.subscriber() == true){
                                let initialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("RootViewController")
                                self.modalTransitionStyle = .CrossDissolve
                                self.presentViewController(initialViewController, animated: true, completion: nil)
                            }else{
                                let startWatchingVc = self.storyboard?.instantiateViewControllerWithIdentifier("StartWatchingController") as! StartWatchingController;
                                self.navigationController?.pushViewController(startWatchingVc, animated: true);
                            }
                        });
					} else {
						//println("[WSM] failed to login")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var msg: String
                            if let message = message {
                                msg = message
                                self.presentViewController(self.alertControlerManager.alertForServerError("Login info", errorMessage: msg), animated: true, completion: nil)
                            } else {
                                self.presentViewController(self.alertControlerManager.alertForServerError("Login info", errorMessage: "Something went wrong. Please try again"), animated: true, completion: nil)
                            }
                        });
					}
				}
				
			} else {
				self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
			}
			
		} else {
			
			if userTexFieldState == TextFieldValidationResult.EMPTY {
				self.presentViewController(alertControlerManager.alertForEmptyTextField("Username and Password are required"), animated: true, completion: nil)
                return;
			}
			if passwordTexFieldState == TextFieldValidationResult.EMPTY {
				self.presentViewController(alertControlerManager.alertForEmptyTextField("Username and Password are required"), animated: true, completion: nil)
                return;
			}
			if userTexFieldState == TextFieldValidationResult.NOT_MINIMUM {
				self.presentViewController(alertControlerManager.alertForLessThanMinCharacters("Username is not long enough"), animated: true, completion: nil)
                return;
			}
			if passwordTexFieldState == TextFieldValidationResult.NOT_MINIMUM {
				self.presentViewController(alertControlerManager.alertForLessThanMinCharacters("Password is not long enough"), animated: true, completion: nil)
                return;
			}
			if userTexFieldState == TextFieldValidationResult.NOT_MAXIMUM {
				self.presentViewController(alertControlerManager.alertForMaxCharacters("Username is too long"), animated: true, completion: nil)
                return;
			}
			if passwordTexFieldState == TextFieldValidationResult.NOT_MAXIMUM {
				self.presentViewController(alertControlerManager.alertForMaxCharacters("Password is too long"), animated: true, completion: nil)
                return;
			}
		}
	}
	
	@IBAction func dontHaveAccountButton(sender: UIButton) {
        self.performSegueWithIdentifier("showRegisterTableViewSegue", sender: sender);
	}
	
	@IBAction func facebookLoginButton(sender: UIButton) {
        
        self.firstFbCall = false;
        if(self.fbUserObject != nil){
            self.edgeFacebookLogin();
            return;
        }
        
        //if(self.fbLoginResult != nil){

          //  return;
        //}
        
        print("Facebook login pressed");
        let loginManager = FBSDKLoginManager();
        loginManager.logInWithReadPermissions(["email", "public_profile","user_birthday"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                // Process error
                
                loginManager.logOut()
                
            } else if result.isCancelled {
                // Handle cancellations
                loginManager.logOut()
            } else {
                //Result has user info in it. 
                print("Got successful login");
                self.fbLoginResult = result;
                self.returnUserData();
            }
        });
    }
	
	@IBAction func forgotPasswordPressed(sender: UIButton) {
		alertToEnterTextField()
	}
	
	func alertToEnterTextField () {
		
		var alertViewControllerTextField: UITextField?
        //alertViewControllerTextField!.keyboardType = .EmailAddress;
        
		let promptController = UIAlertController(title: "Enter your email", message: nil, preferredStyle: .Alert)
		let ok = UIAlertAction(title: "Confirm", style: .Default, handler: { (action) -> Void in
			
			var forgotPasswordEmailString : String!
			forgotPasswordEmailString = alertViewControllerTextField?.text
			
			if self.textValidationManager.isContentValid(forgotPasswordEmailString) == .OK {
				if self.textValidationManager.isValidEmail(forgotPasswordEmailString) == true {
					
					if self.reachabilityHandler.verifyInternetConnection() == true {
						
						self.wsManager.forgotPassword(forgotPasswordEmailString, completionHandler: { (success, message: String?) -> Void in
							if success {
								dispatch_async(dispatch_get_main_queue(), { () -> Void in
									let alertC = self.alertControlerManager.alertForSuccesfulSentEmail(nil)
									self.presentViewController(alertC, animated: true, completion: nil)
								})
							} else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    if let message = message {
                                        self.presentViewController(self.alertControlerManager.alertForServerError("Forgot password info", errorMessage: message), animated: true, completion: nil)
                                    } else {
                                        self.presentViewController(self.alertControlerManager.alertForServerError("Forgot password info", errorMessage: "Something went wrong. Please try again"), animated: true, completion: nil)
                                    }
                                });
							}
						})
                    }else{
                        self.presentViewController(self.alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
                    }
				} else {
					let alert =  self.alertControlerManager.alertForCustomMessage("Forgot password info", errorMessage: "Please enter your email in the format someone@example.com", handler: { (AA:UIAlertAction!) -> Void in
						self.alertToEnterTextField()
					})
					self.presentViewController( alert, animated: true, completion:nil)
				}
			} else {
				var errorMessageString = " "
				if self.textValidationManager.isContentValid(forgotPasswordEmailString) == .EMPTY {
					errorMessageString = self.textValidationManager.errorMessageForIssueInTextField("empty",texfieldName:"Forgot password info")
				} else if self.textValidationManager.isContentValid(forgotPasswordEmailString) == .NOT_MINIMUM {
					errorMessageString = self.textValidationManager.errorMessageForIssueInTextField("minlength",texfieldName:"Forgot password info")
				} else if self.textValidationManager.isContentValid(forgotPasswordEmailString) == .NOT_MAXIMUM {
					errorMessageString = self.textValidationManager.errorMessageForIssueInTextField("maxlength",texfieldName:"Forgot password info")
				}
				let alert =  self.alertControlerManager.alertForCustomMessage("", errorMessage: errorMessageString, handler: { (AA:UIAlertAction!) -> Void in
					self.alertToEnterTextField()
				})
				self.presentViewController( alert, animated: true, completion:nil)
			}
			
		})
		let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
		}
		promptController.addAction(ok)
		promptController.addAction(cancel)
		promptController.addTextFieldWithConfigurationHandler { (textField) -> Void in
			alertViewControllerTextField = textField
			alertViewControllerTextField?.placeholder = "someone@example.com"
		}
		presentViewController(promptController, animated: true, completion: nil)
	}
	
	func responseForSendingEmail (){
		let alertController = UIAlertController(title: "Success!", message:
			"Email sent to retrive password!", preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func handleCancel(alertView: UIAlertAction!){
	}
	
	func keyboardDidShow(notification: NSNotification) {
		if isKeyboardVisible {
			return
		}
		let info = notification.userInfo as! [String: AnyObject]
		let aValue = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
		let keyboardRect = aValue.CGRectValue()
		//keyboardRect = view.convertRect(keyboardRect, fromView: nil)
		scrollViewBottomLayoutConstraint.constant = keyboardRect.size.height
		
		isKeyboardVisible = true
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if !isKeyboardVisible {
			return
		}
		scrollViewBottomLayoutConstraint.constant = 0
		isKeyboardVisible = false
	}
	
    @IBAction func toggleNavigationBar(sender: AnyObject) {
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true) //or animated: false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showRegister"){
            let registerVC : RegisterViewController = segue.destinationViewController as! RegisterViewController;
            registerVC.fbUserObject = self.fbUserObject;
        }
        if(segue.identifier == "showRegisterTableViewSegue"){
            let registerTableVC : RegisterTableViewController = segue.destinationViewController as! RegisterTableViewController;
            registerTableVC.fbUserObject = self.fbUserObject;
        }
        if(segue.identifier == "showRegisterFBSegue"){
            let registerTableVC : RegisterTableViewController = segue.destinationViewController as! RegisterTableViewController;
            registerTableVC.fbUserObject = self.fbUserObject;
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    func edgeFacebookLogin()
    {
        if(self.firstFbCall == true){
            self.firstFbCall = false;
            print("seetting first fb call to false")
            return;
        }

        let result = self.fbUserObject
        let email = result.valueForKey("email") as! String
        let id = result.valueForKey("id") as! String
        //var err: NSError?
        let dictionaryData: NSData =  try! NSJSONSerialization.dataWithJSONObject(self.fbUserObject, options:NSJSONWritingOptions(rawValue: 0))
        
        let fbUserJson = NSString(data: dictionaryData, encoding: NSUTF8StringEncoding) as? String;
        let fbJson = fbUserJson!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
        if reachabilityHandler.verifyInternetConnection() == true {
            self.wsManager.fbLogin(email, facebook_id: id, fb_profile: fbJson!, completionHandler: { (user, success, message: String?) -> Void in
                if success {
                    NSUserDefaults.standardUserDefaults().setObject(self.userNameTextField.text, forKey: "user_email")
//                    let dictUser = user?.asDictionary()
//                    NSUserDefaults.standardUserDefaults().setObject(dictUser, forKey: "user")
//                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //MARK MARK MARK
                        if(user?.subscriber() == true){
                            let initialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("RootViewController")
                            self.modalTransitionStyle = .CrossDissolve
                            self.presentViewController(initialViewController, animated: true, completion: nil)
                        }else{
                            let startWatchingVc = self.storyboard?.instantiateViewControllerWithIdentifier("StartWatchingController") as! StartWatchingController;
                            self.navigationController?.pushViewController(startWatchingVc, animated: true);
                        }
                    })
                } else {
                    
                    //println("[WSM] failed to login")
//                    var msg: String
                    if let message = message {
                        self.registerFBUser(message)
                    } else {
                        self.presentViewController(self.alertControlerManager.alertForServerError("Login info", errorMessage: "Something went wrong. Please try again"), animated: true, completion: nil)
                    }
                    //self.presentViewController(self.alertControlerManager.alertForServerError(msg), animated: true, completion: nil)
                }
            });
        }else{
            self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
        }
        
    }
    func registerFBUser(str:String){
        let message = str
        if(self.fbUserObject != nil){
            let firstName = self.fbUserObject .objectForKey("first_name") as! String
            let lastName = self.fbUserObject.objectForKey("last_name") as! String
            let email = self.fbUserObject.objectForKey("email") as! String
            let id = self.fbUserObject.objectForKey("id") as! String
            let user = EMNUser(firstName: firstName, lastName: lastName, email: email, password: id)
            let gender = self.fbUserObject.objectForKey("gender") as! String
            user.gender = gender
            let dictionaryData: NSData =  try! NSJSONSerialization.dataWithJSONObject(self.fbUserObject, options:NSJSONWritingOptions(rawValue: 0))
            let fbUserJson = NSString(data: dictionaryData, encoding: NSUTF8StringEncoding)
            
            if(fbUserJson != nil){
                user.fbDataJson = fbUserJson as? String;
            }
            if self.reachabilityHandler.verifyInternetConnection() == true {
                Singleton.sharedInstance.user = user;
                self.wsManager.registerUser(user, completionHandler: { (success, message: String?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if success {
                            Singleton.sharedInstance.userSignedUpFlag = true;
                            self.performSegueWithIdentifier("showWelcomeFromHomeVC", sender: nil);
                        } else {
                            //println("[WSM] failed to register")
                            var msg1: String
                            if let message = message {
                                msg1 = message
                            } else {
                                msg1 = "Something went wrong. Please try again"
                            }
                            self.presentViewController(self.alertControlerManager.alertForServerError("Register info", errorMessage: msg1), animated: true, completion: nil)
                        }
                    })
                })
            }else{
                self.presentViewController(self.alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
            }
            
        }else{
            var msg = message
            if msg.rangeOfString("Facebook account does not exist") != nil
            {
                let email = self.fbUserObject.objectForKey("email") as! String
                msg = "Facebook account for e-mail: \(email) does not exist. Click 'I dont have an account' below to create one.";
            }
            
            if(msg.rangeOfString("Please click the link below to sign-in") != nil)
            {
                msg = "Email is already in the system. Hit back and sign in with your password.";
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(self.alertControlerManager.alertForServerError("Login info", errorMessage: msg), animated: true, completion: nil)
            });
        }
    }
    func returnUserData()
    {
//        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,address,picture,cover,birthday"])
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "email,first_name,last_name,gender,address,picture,cover,birthday"] )
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            } else {
                self.fbUserObject = result as! NSDictionary;
                self.edgeFacebookLogin();
            }
        })
    }
}

extension LoginViewController: UITextFieldDelegate {
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		if textField == userNameTextField {
			userPlaceHolderView.layer.borderColor = UIColor(red: 89/255, green: 189/255, blue: 211/255, alpha: 1).CGColor
			userPlaceHolderView.layer.borderWidth = CGFloat(Float(2.5))
		} else if textField == passwordTextField {
			passwordPlaceHolderView.layer.borderColor = UIColor(red: 89/255, green: 189/255, blue: 211/255, alpha: 1).CGColor
			passwordPlaceHolderView.layer.borderWidth = CGFloat(Float(2.5))
		}
		
		let placeholder = NSAttributedString(string: textField.attributedPlaceholder!.string, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()/*UIColor(red: 89/255, green: 189/255, blue: 211/255, alpha: 1)*/])
		textField.attributedPlaceholder = placeholder
		
		return true
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		if textField == userNameTextField {
			userPlaceHolderView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
			userPlaceHolderView.layer.borderWidth = CGFloat(Float(0))
            
		}
		else if textField == passwordTextField {
			passwordPlaceHolderView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
			passwordPlaceHolderView.layer.borderWidth = CGFloat(Float(0))
		}
		
		let placeholder = NSAttributedString(string: textField.attributedPlaceholder!.string, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])//lightGrayColor()])
		textField.attributedPlaceholder = placeholder
		
		return true
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == userNameTextField){
            passwordTextField.becomeFirstResponder();
        }else{
            textField.resignFirstResponder();
        }
		textField.borderStyle = UITextBorderStyle.None
		return true
	}
	
}
/*
let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController")
self.presentViewController(homeViewController!, animated: true, completion: nil)
*/