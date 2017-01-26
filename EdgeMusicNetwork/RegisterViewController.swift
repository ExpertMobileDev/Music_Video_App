//
//  RegisterViewController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/2/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class RegisterViewController: PortraitViewController
{
	
    var fbUserObject: NSDictionary!;
    
	private var isKeyboardVisible = false
	
	@IBOutlet weak var userNameTextField        : UITextField!
	@IBOutlet weak var firstNameTextField       : UITextField!
	@IBOutlet weak var lastNameTextField        : UITextField!
	@IBOutlet weak var passwordTextField        : UITextField!
	@IBOutlet weak var reEnterPasswordTextField : UITextField!
	@IBOutlet weak var registerButton           : UIButton!
	@IBOutlet weak var scrollViewBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var userNameBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var firstNameBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var lastNameBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var passwordBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var reEnterPasswordBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var emailErrorMessageLabel: UILabel!
	@IBOutlet weak var firstNameErrorMessageLabel: UILabel!
	@IBOutlet weak var lastNameErrorMessageLabel: UILabel!
	@IBOutlet weak var passwordErrorMessageLabel: UILabel!
	@IBOutlet weak var reEnterPasswordErrorMessageLabel: UILabel!
	@IBOutlet weak var emailErrorMessageTopLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var firstNameErrorMessageTopLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var lastNameErrorMessageTopLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var passwordErrorMessageTopLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var reEnterPasswordErrorMessageTopLayoutConstraint: NSLayoutConstraint!
	
	let wsManager = WebserviceManager()
	let textValidationManager = TextFieldValidationsManager()
	let alertControlerManager = AlertControllerManager()
	let reachabilityHandler = ReachabilityHandler()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.title = "Register";
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")        
        
		emailErrorMessageLabel.hidden = true
		firstNameErrorMessageLabel.hidden = true
		lastNameErrorMessageLabel.hidden = true
		passwordErrorMessageLabel.hidden = true
		reEnterPasswordErrorMessageLabel.hidden = true
		registerButton.setImage(nil, forState: UIControlState.Highlighted)
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(RegisterViewController.didTapOutside))
        self.view.addGestureRecognizer(tapRecognizer)
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        if let userData: AnyObject = self.fbUserObject
        {
            self.firstNameTextField.text = userData.objectForKey("first_name")  as? String;
            self.lastNameTextField.text = userData.objectForKey("last_name") as? String;
            self.userNameTextField.text = userData.objectForKey("email") as? String;
        }
	}
	
    func didTapOutside(){
        self.view.endEditing(true)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
        if(Singleton.sharedInstance.userSignedUpFlag == true){
            self.navigationController?.popToRootViewControllerAnimated(false);
        }
        
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@IBAction func cancelPressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func registerButtonPressed(sender: UIButton) {
		let userNameTextState = textValidationManager.isContentValid(userNameTextField.text!)
		let firstNameTextState = textValidationManager.isContentValidForNamesAndSurnames(firstNameTextField.text!)
		let lastNameTextState = textValidationManager.isContentValidForNamesAndSurnames(lastNameTextField.text!)
		let passwordTextState = textValidationManager.isContentValid(passwordTextField.text!)
		let reEnterPasswordTextState = textValidationManager.isContentValid(reEnterPasswordTextField.text!)
		
		simpleSwitchCaseValidationForTextFields(userNameTextState, textField: userNameTextField , textfieldBottomConstraint:userNameBottomLayoutConstraint , errorLabel: emailErrorMessageLabel, errorLabelContraint: emailErrorMessageTopLayoutConstraint)
		simpleSwitchCaseValidationForTextFields(firstNameTextState, textField: firstNameTextField , textfieldBottomConstraint:firstNameBottomLayoutConstraint , errorLabel: firstNameErrorMessageLabel, errorLabelContraint: firstNameErrorMessageTopLayoutConstraint)
		simpleSwitchCaseValidationForTextFields(lastNameTextState, textField: lastNameTextField , textfieldBottomConstraint:lastNameBottomLayoutConstraint , errorLabel: lastNameErrorMessageLabel, errorLabelContraint: lastNameErrorMessageTopLayoutConstraint)
		simpleSwitchCaseValidationForTextFields(passwordTextState, textField: passwordTextField , textfieldBottomConstraint:passwordBottomLayoutConstraint , errorLabel: passwordErrorMessageLabel, errorLabelContraint: passwordErrorMessageTopLayoutConstraint)
		simpleSwitchCaseValidationForTextFields(reEnterPasswordTextState, textField: reEnterPasswordTextField , textfieldBottomConstraint:reEnterPasswordBottomLayoutConstraint , errorLabel: reEnterPasswordErrorMessageLabel, errorLabelContraint: reEnterPasswordErrorMessageTopLayoutConstraint)
		
		var firstNameIsOnlyAlpha = false, lastNameIsOnlyAlpha = false, sameStringState = false
		
		if firstNameTextState == TextFieldValidationResult.OK {
			firstNameIsOnlyAlpha = textValidationManager.isOnlyAlphabetic(firstNameTextField)
			if !firstNameIsOnlyAlpha {
				if firstNameBottomLayoutConstraint.constant != 10 {
					cleanTextFieldsandErrorLabels(firstNameTextField, textfieldBottomConstraint: firstNameBottomLayoutConstraint, errorLabel: firstNameErrorMessageLabel)
				}
				firstNameErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("stringhasnumbers",texfieldName: "First Name")
				highLightTextFieldsAndShowErrorLabels(firstNameTextField, textfieldBottomConstraint: firstNameBottomLayoutConstraint, errorLabel: firstNameErrorMessageLabel)
			}
		}
		
		if lastNameTextState == TextFieldValidationResult.OK {
			lastNameIsOnlyAlpha = textValidationManager.isOnlyAlphabetic(lastNameTextField)
			if !lastNameIsOnlyAlpha {
				
				if lastNameBottomLayoutConstraint.constant != 10 {
					cleanTextFieldsandErrorLabels(lastNameTextField, textfieldBottomConstraint: lastNameBottomLayoutConstraint, errorLabel: lastNameErrorMessageLabel)
				}
                lastNameErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("stringhasnumbers", texfieldName: "Last Name")
				highLightTextFieldsAndShowErrorLabels(lastNameTextField, textfieldBottomConstraint: lastNameBottomLayoutConstraint, errorLabel: lastNameErrorMessageLabel)
			}
		}
		
		if passwordTextState == TextFieldValidationResult.OK  && reEnterPasswordTextState == TextFieldValidationResult.OK {
			sameStringState = textValidationManager.isSameContent(passwordTextField, secondTextField: reEnterPasswordTextField)
			if !sameStringState {
				if passwordBottomLayoutConstraint.constant != 10 {
					cleanTextFieldsandErrorLabels(passwordTextField, textfieldBottomConstraint: passwordBottomLayoutConstraint, errorLabel: passwordErrorMessageLabel)
				}
                passwordErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("notsamestring", texfieldName: "")
				highLightTextFieldsAndShowErrorLabels(passwordTextField, textfieldBottomConstraint: passwordBottomLayoutConstraint, errorLabel: passwordErrorMessageLabel)
				
				if reEnterPasswordBottomLayoutConstraint.constant != 40 {
					cleanTextFieldsandErrorLabels(reEnterPasswordTextField, textfieldBottomConstraint: reEnterPasswordBottomLayoutConstraint, errorLabel: reEnterPasswordErrorMessageLabel)
				}
                reEnterPasswordErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("notsamestring",texfieldName: "")
				
				highLightTextFieldsAndShowErrorLabels(reEnterPasswordTextField, textfieldBottomConstraint: reEnterPasswordBottomLayoutConstraint, errorLabel: reEnterPasswordErrorMessageLabel)
				
			}
		}
		
		if userNameTextState == TextFieldValidationResult.OK && firstNameTextState == .OK && lastNameTextState == .OK && firstNameIsOnlyAlpha == true && lastNameIsOnlyAlpha == true && sameStringState == true {
			if reachabilityHandler.verifyInternetConnection() == true {
				let user = EMNUser(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: userNameTextField.text!, password: passwordTextField.text)
                if(self.fbUserObject != nil){
                    //let fbUserJson = NSJSONSerialization.
                    //var err: NSError?
                    let dictionaryData: NSData =  try! NSJSONSerialization.dataWithJSONObject(self.fbUserObject, options:NSJSONWritingOptions(rawValue: 0))
                    let fbUserJson = NSString(data: dictionaryData, encoding: NSUTF8StringEncoding)
                    
                    if(fbUserJson != nil){
                        user.fbDataJson = fbUserJson as? String;
                    }
                }
                Singleton.sharedInstance.user = user;
                wsManager.registerUser(user, completionHandler: { (success, message: String?) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						if success {
                            Singleton.sharedInstance.userSignedUpFlag = true;
                            self.performSegueWithIdentifier("welcomeNewUserSegue", sender: nil);
						} else {
							//println("[WSM] failed to register")
							var msg: String
							if let message = message {
								msg = message
							} else {
                                msg = "Something went wrong. Please try again"
							}
                        self.presentViewController(self.alertControlerManager.alertForServerError("Register info", errorMessage: msg), animated: true, completion: nil)
						}
					})
				})
			} else {
				self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
			}
		}
	}
	
	func cleanTextFieldsandErrorLabels(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel: UILabel) {
		textfieldBottomConstraint.constant -= 22 //inverse margin to return to orignal position
		
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.view.layoutIfNeeded()
		})
		
		errorLabel.hidden = true
		textField.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1).CGColor
		textField.layer.borderWidth = 2.5
	}
	
	func highLightTextFieldsAndShowErrorLabels(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel: UILabel) {
		textfieldBottomConstraint.constant += 22 // margin top 10pts + (label height 12pts + margin bottom 10pts)
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.view.layoutIfNeeded()
		})
		
		errorLabel.hidden = false
		textField.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
		textField.layer.borderWidth = 2.5
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
	
	func simpleSwitchCaseValidationForTextFields(textState: TextFieldValidationResult,textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint,errorLabel: UILabel, errorLabelContraint: NSLayoutConstraint) {
        if textField == reEnterPasswordTextField && textfieldBottomConstraint.constant != 40 {
            cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
        } else if textField != reEnterPasswordTextField && textfieldBottomConstraint.constant != 10 {
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		}
		
        var textFieldName = ""
        
        switch textField {
        case userNameTextField:
            textFieldName = "Email"
        case firstNameTextField:
             textFieldName = "First name"
        case lastNameTextField:
            textFieldName = "Last name"
        case passwordTextField:
            textFieldName = "Password"
        case reEnterPasswordTextField:
            textFieldName = "Re-enter password"
        default:
             textFieldName = "TextField"
        }
        
		switch textState {
		case .OK:
			break
			
		case .EMPTY:
            errorLabel.text = textValidationManager.errorMessageForIssueInTextField("empty", texfieldName: textFieldName )
			highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
            
		case .NOT_MINIMUM:
            if textField == firstNameTextField || textField == lastNameTextField {
                errorLabel.text = textValidationManager.errorMessageForIssueInTextField("minNamelength", texfieldName: textFieldName )
                highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
            }else{
                errorLabel.text = textValidationManager.errorMessageForIssueInTextField("minlength", texfieldName: textFieldName )
                highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
            }
			
		case .NOT_MAXIMUM:
			errorLabel.text = textValidationManager.errorMessageForIssueInTextField("maxlength", texfieldName: textFieldName )
			highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		}
	}
	
}

extension RegisterViewController: UITextFieldDelegate {
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		highlightTextField(textField)
		switch textField {
		case userNameTextField where userNameBottomLayoutConstraint.constant != 10:
            cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: userNameBottomLayoutConstraint, errorLabel: emailErrorMessageLabel)
		case firstNameTextField where firstNameBottomLayoutConstraint.constant != 10:
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: firstNameBottomLayoutConstraint, errorLabel: firstNameErrorMessageLabel)
		case lastNameTextField where lastNameBottomLayoutConstraint.constant != 10:
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: lastNameBottomLayoutConstraint, errorLabel: lastNameErrorMessageLabel)
		case passwordTextField where passwordBottomLayoutConstraint.constant != 10:
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: passwordBottomLayoutConstraint, errorLabel: passwordErrorMessageLabel)
		case reEnterPasswordTextField where reEnterPasswordBottomLayoutConstraint.constant != 40:
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: reEnterPasswordBottomLayoutConstraint, errorLabel: reEnterPasswordErrorMessageLabel)
		default:
			break
		}
      
		return true
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		unhighlightTextField(textField)
		
		return true
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		textField.borderStyle = UITextBorderStyle.None
		
		return true
	}
	
	func highlightTextField(textField: UITextField) {
		textField.layer.borderColor = UIColor(red: 89/255, green: 189/255, blue: 211/255, alpha: 1).CGColor
		textField.layer.borderWidth = 2.5
		
		let placeholder = NSAttributedString(string: textField.attributedPlaceholder!.string, attributes: [NSForegroundColorAttributeName : UIColor(red: 89/255, green: 189/255, blue: 211/255, alpha: 1)])
		textField.attributedPlaceholder = placeholder
	}
	
	func unhighlightTextField(textField: UITextField) {
		textField.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
		textField.layer.borderWidth = 0
		textField.layer.cornerRadius = 0
		let placeholder = NSAttributedString(string: textField.attributedPlaceholder!.string, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
		textField.attributedPlaceholder = placeholder
	}
	
	func verifyErrorsInTextFields(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel : UILabel, errorLabelConstraint: NSLayoutConstraint ) {
		textfieldBottomConstraint.constant += 22 // margin top 10pts + (label height 12pts + margin bottom 10pts)
		
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.view.layoutIfNeeded()
		})
		
		errorLabel.hidden = false
		errorLabel.superview!.removeConstraint(errorLabelConstraint)
		
		let auxErrorMessageTopLayoutConstraint = NSLayoutConstraint(item: errorLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: textField, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10)
		errorLabel.superview!.addConstraint(auxErrorMessageTopLayoutConstraint)
		
		textField.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
		textField.layer.borderWidth = 2.5
	}
	
}
