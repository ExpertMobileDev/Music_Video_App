//
//  MyProfileInfoEditController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import AVFoundation

var status : AVAuthorizationStatus!
class MyProfileInfoEditController: PortraitViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	private var isKeyboardVisible = false
    
    var picker :UIImagePickerController!
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var reEnterPasswordTextField: UITextField!
	@IBOutlet weak var saveChangesButton: UIButton!
	@IBOutlet weak var scrollViewBottomLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var emailBottomLayoutConstraint: NSLayoutConstraint!
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
   	@IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileCoverImageView: UIImageView!
    

	
	let wsManager = WebserviceManager()
	let textValidationManager = TextFieldValidationsManager()
	let alertControlerManager = AlertControllerManager()
	let reachabilityHandler = ReachabilityHandler()
    var selectedPhoto = 0
    
	var user: EMNUser!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.user = Singleton.sharedInstance.user;
        self.picker = UIImagePickerController();
		self.picker.delegate = self   //the required delegate to get a photo back to the app.
        
        self.title = "Update Password";
        
		emailErrorMessageLabel.hidden = true
		firstNameErrorMessageLabel.hidden = true
		lastNameErrorMessageLabel.hidden = true
		passwordErrorMessageLabel.hidden = true
		reEnterPasswordErrorMessageLabel.hidden = true
		emailTextField.text = user.email
		firstNameTextField.text = user.firstName
		lastNameTextField.text = user.lastName
		print("[EPVC] password: \(user.password)")
		passwordTextField.text = user.password
		reEnterPasswordTextField.text = user.password
        
		saveChangesButton.setImage(nil, forState: UIControlState.Highlighted)
		let tapRecognizer = UITapGestureRecognizer()
		tapRecognizer.addTarget(self, action: #selector(MyProfileInfoEditController.didTapOutside))
		self.view.addGestureRecognizer(tapRecognizer)
	}
	
	func didTapOutside(){
		self.view.endEditing(true)
	}
    
    
    func editPhoto(sender: UIButton) {
        //we set the integer with the sent tag to know which button has been pressed
        selectedPhoto = sender.tag
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        picker.modalPresentationStyle = .Popover
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func editPhotoOptions(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        // 2
        let deleteAction = UIAlertAction(title: "Take photo", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.takePhoto(sender)
            print("Photo taken and selected")
        })
        let saveAction = UIAlertAction(title: "Choose from library", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.selectPhoto(sender)
            print("Photo Selected from library")
        })
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Photo edit cancelled")
        })
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func selectPhoto(sender: UIButton) {
        status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if status == AVAuthorizationStatus.Denied {
            let alertVC = UIAlertController(title: "No library access", message: "Sorry, access to library was denied", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
            alertVC.addAction(okAction)
            presentViewController(alertVC, animated: true, completion: nil)
        } else {
            print("we open the piker to select the photo")
            print(sender.tag)
            //we set the integer with the sent tag to know which button has been pressed
            selectedPhoto = sender.tag
            picker.allowsEditing = false
            picker.sourceType = .PhotoLibrary
            picker.modalPresentationStyle = .Popover
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func takePhoto(sender: UIButton) {
        status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        //we set the integer with the sent tag to know which button has been pressed
        selectedPhoto = sender.tag
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            if status == AVAuthorizationStatus.Denied {
                let alertVC = UIAlertController(title: "No camera access", message: "Sorry, access to camera was denied", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
                alertVC.addAction(okAction)
                presentViewController(alertVC, animated: true, completion: nil)
            } else {
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                picker.cameraCaptureMode = .Photo
                presentViewController(picker, animated: true, completion: nil)
            }
        } else {

            noCamera()
        }
    }
    
    func noCamera(){
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        /*
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
            */
    }
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyProfileInfoEditController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyProfileInfoEditController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@IBAction func cancelPressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
	}
    
    @IBAction func editProfilePicture(sender: UIButton)
    {
        self.editPhotoOptions(sender);
    }

    @IBAction func editCoverPicture(sender: UIButton)
    {
        self.editPhotoOptions(sender);
    }

    
	@IBAction func saveButtonTouchedUpInside(sender: UIButton) {
		firstNameTextField.text = firstNameTextField.text!.capitalizedString
		lastNameTextField.text = lastNameTextField.text!.capitalizedString
		
		let emailTextState = textValidationManager.isContentValid(emailTextField.text!)
		let firstNameTextState = textValidationManager.isContentValidForNamesAndSurnames(firstNameTextField.text!)
		let lastNameTextState = textValidationManager.isContentValidForNamesAndSurnames(lastNameTextField.text!)
		let passwordTextState = textValidationManager.isContentValid(passwordTextField.text!)
		let reEnterPasswordTextState = textValidationManager.isContentValid(reEnterPasswordTextField.text!)
		
		simpleSwitchCaseValidationForTextFields(emailTextState, textField: emailTextField , textfieldBottomConstraint: emailBottomLayoutConstraint , errorLabel: emailErrorMessageLabel, errorLabelContraint: emailErrorMessageTopLayoutConstraint)
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
				lastNameErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("stringhasnumbers",texfieldName: "Last Name")
				highLightTextFieldsAndShowErrorLabels(lastNameTextField, textfieldBottomConstraint: lastNameBottomLayoutConstraint, errorLabel: lastNameErrorMessageLabel)
			}
		}
		
		if passwordTextState == TextFieldValidationResult.OK  && reEnterPasswordTextState == .OK {
			sameStringState = textValidationManager.isSameContent(passwordTextField, secondTextField: reEnterPasswordTextField)
			if !sameStringState {
				if passwordBottomLayoutConstraint.constant != 10 {
					cleanTextFieldsandErrorLabels(passwordTextField, textfieldBottomConstraint: passwordBottomLayoutConstraint, errorLabel: passwordErrorMessageLabel)
				}
				passwordErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("notsamestring",texfieldName:"")
				highLightTextFieldsAndShowErrorLabels(passwordTextField, textfieldBottomConstraint: passwordBottomLayoutConstraint, errorLabel: passwordErrorMessageLabel)
				
				if reEnterPasswordBottomLayoutConstraint.constant != 40 {
					cleanTextFieldsandErrorLabels(reEnterPasswordTextField, textfieldBottomConstraint: reEnterPasswordBottomLayoutConstraint, errorLabel: reEnterPasswordErrorMessageLabel)
				}
				reEnterPasswordErrorMessageLabel.text = textValidationManager.errorMessageForIssueInTextField("notsamestring",texfieldName:"")
				
				highLightTextFieldsAndShowErrorLabels(reEnterPasswordTextField, textfieldBottomConstraint: reEnterPasswordBottomLayoutConstraint, errorLabel: reEnterPasswordErrorMessageLabel)
			}
		}
		
		if emailTextState == TextFieldValidationResult.OK && firstNameTextState == .OK && lastNameTextState == .OK && firstNameIsOnlyAlpha == true && lastNameIsOnlyAlpha == true && sameStringState == true {
			if reachabilityHandler.verifyInternetConnection() == true {
				// println("Device has internet connection")
				let user = EMNUser(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!)
				wsManager.updateUserProfile(user, completionHandler: { (success, message) -> Void in
					if success {
						print("[EPVC] user info updated.")
						NSUserDefaults.standardUserDefaults().setObject(user.email, forKey: "user_email")
                        let dictUser = user.asDictionary()
                        NSUserDefaults.standardUserDefaults().setObject(dictUser, forKey: "user")
                        NSUserDefaults.standardUserDefaults().synchronize()
						/*
						if let profileVC = self.presentingViewController as? ProfileViewController {
							//profileVC.user = user
						}
						*/
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							let alertC = self.alertControlerManager.alertForSuccesfulSavedChanges({ (aa: UIAlertAction!) -> Void in
								self.dismissViewControllerAnimated(true, completion: { () -> Void in
									
								})
							})
							self.presentViewController(alertC, animated: true, completion: nil)
						})
						
					} else {
						//println("[EPVC] failed to edit user. Message: \(message)")
						var msg: String
						if let message = message {
							msg = message
							self.presentViewController(self.alertControlerManager.alertForServerError("Edit profile info", errorMessage: msg), animated: true, completion: nil)
						} else {
							self.presentViewController(self.alertControlerManager.alertForServerError("Edit profile info", errorMessage: "Something went wrong. Please try again"), animated: true, completion: nil)
						}
						//call to some alert controller
					}
				})
			} else {
				self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
			}
		}
	}
		
	func simpleSwitchCaseValidationForTextFields(textState: TextFieldValidationResult,textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint,errorLabel: UILabel, errorLabelContraint: NSLayoutConstraint) {
		if textField == reEnterPasswordTextField && textfieldBottomConstraint.constant != 40 {
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		} else if textField != reEnterPasswordTextField && textfieldBottomConstraint.constant != 10 {
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		}
		
		var textFieldName = ""
		
		switch textField {
		case emailTextField:
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
		case TextFieldValidationResult.OK:
			break
		case TextFieldValidationResult.EMPTY:
			errorLabel.text = textValidationManager.errorMessageForIssueInTextField("empty", texfieldName: textFieldName)
			highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		case TextFieldValidationResult.NOT_MINIMUM:
			if textField == firstNameTextField || textField == lastNameTextField {
				errorLabel.text = textValidationManager.errorMessageForIssueInTextField("minNamelength", texfieldName: textFieldName )
				highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
			}else{
				errorLabel.text = textValidationManager.errorMessageForIssueInTextField("minlength", texfieldName: textFieldName )
				highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
			}
			
		case TextFieldValidationResult.NOT_MAXIMUM:
			errorLabel.text = textValidationManager.errorMessageForIssueInTextField("maxlength", texfieldName: textFieldName)
			highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
		}
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
	
	func cleanTextFieldsandErrorLabels(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel: UILabel) {
		textfieldBottomConstraint.constant -= 22 //inverse margin to return to orignal position
		
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.view.layoutIfNeeded()
		})
		
		errorLabel.hidden = true
		textField.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1).CGColor
		textField.layer.borderWidth = 2.5
	}
	
	@IBAction func SaveButtonTouchedDown(sender: AnyObject) {
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
	
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera) {
            // Access the uncropped image from info dictionary
            let imageToSave1: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage //same but with different way
            UIImageWriteToSavedPhotosAlbum(imageToSave1, nil, nil, nil)
            //self.dismissViewControllerAnimated(true, completion: nil)
        }
        //we made a switch case to select the proper ImageView
        switch selectedPhoto{
        case 1:
            
            print("case 1")
            if(info[UIImagePickerControllerOriginalImage] != nil){
                Singleton.sharedInstance.user.avatarImage = info[UIImagePickerControllerOriginalImage] as? UIImage;                
            }
            profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
            if(profileImageView.image != nil){
                if reachabilityHandler.verifyInternetConnection() == true{
                    wsManager.saveAvatar(profileImageView.image!, completionHandler: nil);
                }
                
            }

        case 2:
            print("case 2")
            if(info[UIImagePickerControllerOriginalImage] != nil){
                Singleton.sharedInstance.user.coverImage = info[UIImagePickerControllerOriginalImage] as? UIImage;
            }
            profileCoverImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if(self.profileCoverImageView.image != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.saveCover(profileCoverImageView.image!, completionHandler: nil);
                }
                
            }
        default:
            print("[Profile EDIT] Fell through options for uploading ");
        }
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    

    
    
}

extension MyProfileInfoEditController: UITextFieldDelegate {
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		highlightTextField(textField)
		
		switch textField {
		case emailTextField where emailBottomLayoutConstraint.constant != 10:
			cleanTextFieldsandErrorLabels(textField, textfieldBottomConstraint: emailBottomLayoutConstraint, errorLabel: emailErrorMessageLabel)
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
	
}


