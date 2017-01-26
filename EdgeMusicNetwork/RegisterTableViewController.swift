//
//  RegisterTableViewController.swift
//  emn
//
//  Created by Jason Cox on 9/27/15.
//  Copyright © 2015 Jason Cox GM. All rights reserved.
//

import UIKit

class RegisterTableViewController : UITableViewController, UITextFieldDelegate
{
    @IBOutlet weak var tableHeaderView       : UIView!
    @IBOutlet weak var tableFooterView       : UIView!
    
    @IBOutlet weak var firstNameTextField    : UITextField!
    @IBOutlet weak var lastNameTextField     : UITextField!
    @IBOutlet weak var emailTextField        : UITextField!
    
//    @IBOutlet weak var zipCodeTextField      : UITextField!
//    @IBOutlet weak var bdayMMTextField       : UITextField!
//    @IBOutlet weak var bdayDDTextField       : UITextField!
//    @IBOutlet weak var bdayYYTextField       : UITextField!
    
    @IBOutlet weak var passwordTextField        : UITextField!
    @IBOutlet weak var reEnterPasswordTextField : UITextField!
    
//    @IBOutlet weak var genderSelect : UISegmentedControl!
    @IBOutlet weak var submitButton : UIButton!
    
    var cancelBarButtonItem: UIBarButtonItem!
    
    var loadingView: UIView!
    var loadingIndicator: UIActivityIndicatorView!
    
    var errorArrow : UIImageView!
    
    var currentTextField : UITextField!
    var doneEditingButton : UIBarButtonItem!
   	
    let wsManager = WebserviceManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    let textValidationManager = TextFieldValidationsManager()
    
    var fbUserObject: NSDictionary!
    var textFields = [];
    
    override func viewDidLoad() {
        self.title = "Register";
        
        self.textFields = [self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField, self.reEnterPasswordTextField];
//        self.textFields = [self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.zipCodeTextField, self.bdayMMTextField, self.bdayDDTextField, self.bdayYYTextField, self.passwordTextField, self.reEnterPasswordTextField];
        
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        self.errorArrow = UIImageView(image: UIImage(named:"error_arrow"));
        self.submitButton = UIButton(type: .Custom);
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        if let userData: AnyObject = self.fbUserObject
        {
            self.firstNameTextField.text = userData.objectForKey("first_name")  as? String;
            self.lastNameTextField.text = userData.objectForKey("last_name") as? String;
            self.emailTextField.text = userData.objectForKey("email") as? String;
//            if let genderString = userData.objectForKey("gender") as? String
//            {
//                if(genderString.lowercaseString == "female"){
//                    self.genderSelect.selectedSegmentIndex = 1;
//                }
//            }
        }
        
        let loadingViewFrame = CGRectMake(0,0,self.tableView.frame.size.width, 700);
        self.loadingView = UIView(frame: loadingViewFrame);
        
        self.loadingView.backgroundColor = UIColor.blackColor();
        self.loadingView.alpha = 0.3;
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge);
        let activityFrame = CGRectMake(self.tableView.frame.size.width/2-15,700/2-15, loadingIndicator.frame.size.width, loadingIndicator.frame.size.height);
        loadingIndicator.frame = activityFrame;
        self.loadingView.addSubview(self.loadingIndicator);
        
        self.cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(RegisterTableViewController.cancelAddUser(_:)));

        super.viewDidLoad();
    }
    
    func doneEditingText(sender: AnyObject)
    {
        for textField in self.textFields as! [UITextField]
        {
            if(textField.isFirstResponder()){
                textField.resignFirstResponder();
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
    func cancelAddUser(sender: AnyObject!)
    {
        wsManager.registerTask.cancel();
        self.loadingIndicator.stopAnimating();
        self.loadingView.removeFromSuperview();
        self.navigationController?.navigationItem.rightBarButtonItem = nil;
    }
    
    func textFieldShouldBeginEditing(_textField: UITextField) -> Bool
    {
        if let errorIconView = errorIconImageViewFor(_textField)
        {
            errorIconView.removeFromSuperview();
        }
        _textField.text = "";
        if(self.doneEditingButton == nil){
            self.doneEditingButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(RegisterTableViewController.doneEditingText(_:)));
        }
        self.navigationItem.rightBarButtonItem = self.doneEditingButton;
        return true;
    }
    func textFieldShouldEndEditing(_textField: UITextField) -> Bool
    {
        return true;
    }
    
    func textFieldShouldReturn(_textField: UITextField) -> Bool {
        let index = self.textFields.indexOfObject(_textField);
        if (self.textFields.count > index+1) {
            let nextField = self.textFields.objectAtIndex(index+1) as! UITextField;
            nextField.becomeFirstResponder();
        }else{
            self.navigationItem.rightBarButtonItem = nil;
            _textField.resignFirstResponder();
        }
        return true;
    }
    
    func textField(_textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if(_textField == self.zipCodeTextField){
//            let newString = _textField.text! + string;
//            if(newString.characters.count == 5){
//                _textField.text = newString;
//                self.bdayMMTextField.becomeFirstResponder();
//                return false;
//            }
//            return true;
//        }
//        
//        if(_textField == self.bdayMMTextField){
//            let newString = _textField.text! + string;
//            if(newString.characters.count == 2){
//                _textField.text = newString;
//                self.bdayDDTextField.becomeFirstResponder();
//                return false;
//            }
//            return true;
//        }
//        if(_textField == self.bdayDDTextField){
//            let newString = _textField.text! + string;
//            if(newString.characters.count == 2){
//                _textField.text = newString;
//                self.bdayYYTextField.becomeFirstResponder();
//                return false;
//            }
//            return true;
//        }
//        if(_textField == self.bdayYYTextField){
//            let newString = _textField.text! + string;
//            if(newString.characters.count == 4){
//                _textField.text = newString;
//                self.passwordTextField.becomeFirstResponder();
//                return false;
//            }
//            return true;
//        }
        return true;
    }
    
    func errorIconImageViewFor(_textField: UITextField) -> UIImageView?
    {
        for myView: UIView in _textField.superview!.subviews
        {
            if let iconView = myView as? UIImageView
            {
                return iconView;
            }
        }
        return nil;
    }
    
    func addErrorImageViewFor(_textField: UITextField){
        let errorView = UIImageView(image: UIImage(named: "error_arrow"));
        errorView.translatesAutoresizingMaskIntoConstraints = false;
        let textFieldSuperView = _textField.superview;
        textFieldSuperView!.addSubview(errorView);
        
        let horizontalConstraint = NSLayoutConstraint(item: errorView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: textFieldSuperView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -10);
        textFieldSuperView?.addConstraint(horizontalConstraint);
        let verticalConstriaint = NSLayoutConstraint(item: errorView, attribute: NSLayoutAttribute.CenterY, relatedBy:
            NSLayoutRelation.Equal, toItem: textFieldSuperView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0);
        textFieldSuperView?.addConstraint(verticalConstriaint);
        let widthConstraint = NSLayoutConstraint(item: errorView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 15);
        errorView.addConstraint(widthConstraint);
        let heightConstraint = NSLayoutConstraint(item: errorView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 15)
        errorView.addConstraint(heightConstraint)
    }
    
    @IBAction func registerUser(sender: UIButton) {
        self.doneEditingText(sender);
//        var alreadyFlaggedBdayFields: Bool = false;
        var hasErrors: Bool = false;
        var alertOpened = false
        for textField in self.textFields as! [UITextField]
        {
            if(textField == self.firstNameTextField){
                if(textField.text?.characters.count < 2){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                }
            }
            if(textField == self.lastNameTextField){
                if(textField.text?.characters.count < 2){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                }
            }
//            if(textField == self.zipCodeTextField){
//                if(textField.text?.characters.count < 5){
//                    hasErrors = true;
//                    self.addErrorImageViewFor(textField);
//                }
//            }
            if(textField == self.emailTextField){
                if(textField.text?.characters.count < 2){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                }else{
                    if(!EMNUtils.isValidEmail(textField.text!)){
                        hasErrors = true;
                        self.addErrorImageViewFor(textField);
                    }
                }
            }
            if(textField == self.passwordTextField){
                if(textField.text?.characters.count < 6){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                    self.presentViewController(alertControlerManager.alertForLessThanMinCharacters("Password is not long enough"), animated: true, completion: nil)
                    alertOpened = true
                }
            }
            if(textField == self.reEnterPasswordTextField){
                if(textField.text?.characters.count < 6){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                    if alertOpened == true {
                        self.presentViewController(alertControlerManager.alertForLessThanMinCharacters("Username is not long enough"), animated: true, completion: nil)
                    }
                }
            }
            if(hasErrors == false){
                if(self.passwordTextField.text != self.reEnterPasswordTextField.text){
                    hasErrors = true;
                    self.addErrorImageViewFor(self.passwordTextField);
                    self.addErrorImageViewFor(self.reEnterPasswordTextField);
                }
            }
//            if(textField == self.bdayDDTextField || textField == self.bdayMMTextField || textField == self.bdayYYTextField){
//                if(alreadyFlaggedBdayFields == true){
//                    continue;
//                }
//                if(self.bdayDDTextField.text?.characters.count < 2 ||
//                    self.bdayMMTextField.text?.characters.count < 2 ||
//                    self.bdayYYTextField.text?.characters.count < 4){
//                    hasErrors = true;
//                    self.addErrorImageViewFor(textField);
//                }else{
//                    let dateComponents = NSDateComponents();
//                    dateComponents.year = Int(self.bdayYYTextField.text!)!;
//                    dateComponents.month = Int(self.bdayMMTextField.text!)!;
//                    dateComponents.day = Int(self.bdayDDTextField.text!)!;
//                    if dateComponents.isValidDateInCalendar(NSCalendar.currentCalendar())
//                    {
//                        
//                    }else{
//                        hasErrors = true;
//                        self.addErrorImageViewFor(textField);
//                    }
//                }
//                alreadyFlaggedBdayFields = true;
//            }
        }
        if(hasErrors == true){
            return;
        }
        print("Adding user to system");
        self.view.addSubview(self.loadingView);
        self.loadingIndicator.startAnimating();
        self.navigationController?.navigationItem.rightBarButtonItem = self.cancelBarButtonItem;

//        let gender: String = self.genderSelect.selectedSegmentIndex == 0 ? "male" : "female";
//        let birthday: String = self.bdayDDTextField.text!+"-"+self.bdayMMTextField.text!+"-"+self.bdayYYTextField.text!;
        let user = EMNUser(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!);
//        user.gender = gender;
//        user.birthday = birthday;
//        user.points = "2000";
//        user.zipCode = self.zipCodeTextField.text!;
        if(self.fbUserObject != nil){
            let dictionaryData: NSData =  try! NSJSONSerialization.dataWithJSONObject(self.fbUserObject, options:NSJSONWritingOptions(rawValue: 0))
            let fbUserJson = NSString(data: dictionaryData, encoding: NSUTF8StringEncoding)
            
            if(fbUserJson != nil){
                user.fbDataJson = fbUserJson as? String;
            }
        }
        
        
        
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.registerUser(user, completionHandler: { (success, message: String?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success {
//                        let bday: String = self.bdayMMTextField.text!+"-"+self.bdayDDTextField.text!+"-"+self.bdayYYTextField.text!;
//                        user.birthday = bday;
                        self.loadingIndicator.stopAnimating();
                        self.loadingView.removeFromSuperview();
//                        Singleton.sharedInstance.user = user;
                        
                        user.password = self.passwordTextField.text
                        let dictUser = user.asDictionary()
                        NSUserDefaults.standardUserDefaults().setObject(dictUser, forKey: "user")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        Singleton.sharedInstance.userSignedUpFlag = true;
                        self.performSegueWithIdentifier("showWelcomeFromRegisterTableViewSegue", sender: nil);
                    } else {
                        self.loadingIndicator.stopAnimating();
                        self.loadingView.removeFromSuperview();
                        var msg: String
                        if let message = message {
                            msg = message
                            let alert = UIAlertController(title: "Error", message:msg, preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: nil)
                            
                            // Add the actions
                            alert.addAction(cancelAction)
                            
                            // Present the controller
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            msg = "This email address is already registered."
                            let alert = UIAlertController(title: "User Account Already Exist", message:msg, preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "Forgot Password", style: UIAlertActionStyle.Cancel){
                                UIAlertAction in
                                self.alertToEnterTextField()
                            }
                            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: nil)
                            
                            // Add the actions
                            alert.addAction(okAction)
                            alert.addAction(cancelAction)
                            
                            // Present the controller
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        
                    }
                })
            })
        }else{
            self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
        }
        
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
}