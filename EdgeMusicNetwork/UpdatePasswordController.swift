//
//  MyProfileInfoEditController.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

class UpdatePasswordController: PortraitViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var isKeyboardVisible = false
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var scrollViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var reEnterPasswordBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    @IBOutlet weak var reEnterPasswordErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordErrorMessageTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var reEnterPasswordErrorMessageTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnWatching: UIButton!
    
    
    let wsManager = WebserviceManager()
    let textValidationManager = TextFieldValidationsManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    var selectedPhoto = 0
    
    var user: EMNUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = Singleton.sharedInstance.user;
        
        self.title = "Reset Password";
        
        passwordErrorMessageLabel.hidden = true
        reEnterPasswordErrorMessageLabel.hidden = true
        passwordTextField.text = user.password
        reEnterPasswordTextField.text = user.password
        saveChangesButton.setImage(nil, forState: UIControlState.Highlighted)
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(UpdatePasswordController.didTapOutside))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func didTapOutside(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Singleton.sharedInstance.isWatching == true {
            self.btnWatching.alpha = 1
        }else {
            self.btnWatching.alpha = 0
        }
        if Singleton.sharedInstance.updatePasswordFromMenu == true {
            let menuIcon = UIImage(named: "hamburger_menu")
            let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: #selector(UpdatePasswordController.showMenu(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }else{
            let backIcon = UIImage(named: "back")
            let backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action:#selector(UpdatePasswordController.goBack))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UpdatePasswordController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UpdatePasswordController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func showMenu(sender:AnyObject){
        self.presentLeftMenuViewController(self)
        self.sideMenuViewController.hideContentViewController()
    }
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
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
    @IBAction func saveButtonTouchedUpInside(sender: UIButton) {
        
        let passwordTextState = textValidationManager.isContentValid(passwordTextField.text!)
        let reEnterPasswordTextState = textValidationManager.isContentValid(reEnterPasswordTextField.text!)
        
        simpleSwitchCaseValidationForTextFields(passwordTextState, textField: passwordTextField , textfieldBottomConstraint:passwordBottomLayoutConstraint , errorLabel: passwordErrorMessageLabel, errorLabelContraint: passwordErrorMessageTopLayoutConstraint)
        simpleSwitchCaseValidationForTextFields(reEnterPasswordTextState, textField: reEnterPasswordTextField , textfieldBottomConstraint:reEnterPasswordBottomLayoutConstraint , errorLabel: reEnterPasswordErrorMessageLabel, errorLabelContraint: reEnterPasswordErrorMessageTopLayoutConstraint)
        var sameStringState = false;
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
        
        if sameStringState == true {
            if reachabilityHandler.verifyInternetConnection() == true {
                // println("Device has internet connection")
                wsManager.updateUserPassword(passwordTextField.text!, completionHandler: { (success, message) -> Void in
                    if success {
                        print("[EPVC] user info updated.")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alertC = self.alertControlerManager.alertForSuccesfulSavedChanges({ (aa: UIAlertAction!) -> Void in
                                self.navigationController?.popViewControllerAnimated(true);
                            })
                            self.presentViewController(alertC, animated: true, completion: nil)
                        })
                        
                    } else {
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

            errorLabel.text = textValidationManager.errorMessageForIssueInTextField("minlength", texfieldName: textFieldName )
            highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
            
        case TextFieldValidationResult.NOT_MAXIMUM:
            errorLabel.text = textValidationManager.errorMessageForIssueInTextField("maxlength", texfieldName: textFieldName)
            highLightTextFieldsAndShowErrorLabels(textField, textfieldBottomConstraint: textfieldBottomConstraint, errorLabel: errorLabel)
        }
    }
    
    func highLightTextFieldsAndShowErrorLabels(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel: UILabel) {
        //textfieldBottomConstraint.constant += 22 // margin top 10pts + (label height 12pts + margin bottom 10pts)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        errorLabel.hidden = false
        textField.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
        textField.layer.borderWidth = 2.5
    }
    
    func cleanTextFieldsandErrorLabels(textField: UITextField, textfieldBottomConstraint: NSLayoutConstraint, errorLabel: UILabel) {
        //textfieldBottomConstraint.constant -= 22 //inverse margin to return to orignal position
        
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

    
}

extension UpdatePasswordController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        highlightTextField(textField)
        
        switch textField {
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


