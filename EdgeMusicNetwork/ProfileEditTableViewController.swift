//
//  RegisterTableViewController.swift
//  emn
//
//  Created by Jason Cox on 9/27/15.
//  Copyright © 2015 Jason Cox GM. All rights reserved.
//

import UIKit

class ProfileEditTableViewController : UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    var picker :UIImagePickerController!
    
    @IBOutlet weak var tableHeaderView       : UIView!
    @IBOutlet weak var tableFooterView       : UIView!
    
    @IBOutlet weak var firstNameTextField    : UITextField!
    @IBOutlet weak var lastNameTextField     : UITextField!
    @IBOutlet weak var emailTextField        : UITextField!
    @IBOutlet weak var zipCodeTextField      : UITextField!
    
    @IBOutlet weak var bdayMMTextField       : UITextField!
    @IBOutlet weak var bdayDDTextField       : UITextField!
    @IBOutlet weak var bdayYYTextField       : UITextField!
    
    @IBOutlet weak var coverImage            : UIImageView!
    @IBOutlet weak var avatarImage           : UIImageView!
    @IBOutlet weak var avatarBoarderImage    : UIImageView!
    
    @IBOutlet weak var genderSelect : UISegmentedControl!
    @IBOutlet weak var submitButton : UIButton!
    
    @IBOutlet weak var uploadAvatarTableViewCell: UITableViewCell!
    @IBOutlet weak var uploadCoverTableViewCell: UITableViewCell!
    
    var loadingView: UIView!
    var loadingIndicator: UIActivityIndicatorView!
    
    var errorArrow : UIImageView!
    
    var currentTextField : UITextField!
    var doneEditingButton : UIBarButtonItem!
   	
    let wsManager = WebserviceManager()
    let alertControlerManager = AlertControllerManager()
    let reachabilityHandler = ReachabilityHandler()
    
    var fbUserObject: NSDictionary!
    var textFields = [];
    
    var selectedPhoto = 0
    var letBackspaceWorkOnZipcode = true;
    
    override func viewDidLoad() {
        
        self.title = "Edit Profile";
        
        self.picker = UIImagePickerController();
        self.picker.delegate = self   //the required delegate to get a photo back to the app.
        
        self.textFields = [self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.zipCodeTextField, self.bdayMMTextField, self.bdayDDTextField, self.bdayYYTextField];
        
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        self.errorArrow = UIImageView(image: UIImage(named:"error_arrow"));
        self.submitButton = UIButton(type: .Custom);
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named:"back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named:"back")
        
        self.firstNameTextField.text = Singleton.sharedInstance.user!.firstName;
        self.lastNameTextField.text = Singleton.sharedInstance.user!.lastName;
        self.emailTextField.text = Singleton.sharedInstance.user!.email;
        if(Singleton.sharedInstance.user!.gender != nil){
            self.genderSelect.selectedSegmentIndex = Singleton.sharedInstance.user!.gender == "female" ? 1 : 0;
        }

        if(Singleton.sharedInstance.user.zipCode != nil){
            self.zipCodeTextField.text = Singleton.sharedInstance.user!.zipCode;
        }
        if(Singleton.sharedInstance.user.birthday != nil){
            let birthdayParts = Singleton.sharedInstance.user.birthday?.componentsSeparatedByString("-") as [String]!;
            if(birthdayParts?.count == 3){
                self.bdayMMTextField.text = birthdayParts[0];
                self.bdayDDTextField.text = birthdayParts[1];
                self.bdayYYTextField.text = birthdayParts[2];
            }
        }
        
        if(Singleton.sharedInstance.user.coverImage != nil){
            self.coverImage.image = Singleton.sharedInstance.user.coverImage;
        }
        
        if(Singleton.sharedInstance.user.avatarImage != nil){
            self.avatarImage.image = Singleton.sharedInstance.user.avatarImage;
        }
        
        let imageWithShape = UIImage(named: "profile_mask")!
        let mask = CALayer()
        mask.contents = imageWithShape.CGImage
        mask.frame = avatarImage.layer.bounds
        avatarImage.layer.mask = mask
        
        
        let loadingViewFrame = CGRectMake(0,0,self.tableView.frame.size.width, 700);
        self.loadingView = UIView(frame: loadingViewFrame);
        
        self.loadingView.backgroundColor = UIColor.blackColor();
        self.loadingView.alpha = 0.3;
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge);
        let activityFrame = CGRectMake(self.tableView.frame.size.width/2-15,700/2-15, loadingIndicator.frame.size.width, loadingIndicator.frame.size.height);
        loadingIndicator.frame = activityFrame;
        self.loadingView.addSubview(self.loadingIndicator);
        
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
    
    func textFieldShouldBeginEditing(_textField: UITextField) -> Bool
    {
        if let errorIconView = errorIconImageViewFor(_textField)
        {
            errorIconView.removeFromSuperview();
        }
        if(_textField == bdayMMTextField || _textField == bdayDDTextField || _textField == bdayYYTextField){
            _textField.text = "";
        }

        if(self.doneEditingButton == nil){
            self.doneEditingButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(ProfileEditTableViewController.doneEditingText(_:)));
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
        if(_textField == self.zipCodeTextField){
            let newString = _textField.text! + string;
            if(newString.characters.count < 5){
                self.letBackspaceWorkOnZipcode = false;
            }
            if(newString.characters.count == 5 && self.letBackspaceWorkOnZipcode == false){
                _textField.text = newString;
                self.navigationItem.rightBarButtonItem = nil;
                _textField.resignFirstResponder();
                self.letBackspaceWorkOnZipcode = true;
                return false;
            }
            return true;
        }
        
        if(_textField == self.bdayMMTextField){
            let newString = _textField.text! + string;
            if(newString.characters.count == 2){
                _textField.text = newString;
                self.navigationItem.rightBarButtonItem = nil;
                _textField.resignFirstResponder();
                return false;
            }
            return true;
        }
        if(_textField == self.bdayDDTextField){
            let newString = _textField.text! + string;
            if(newString.characters.count == 2){
                _textField.text = newString;
                self.navigationItem.rightBarButtonItem = nil;
                _textField.resignFirstResponder();
                return false;
            }
            return true;
        }
        if(_textField == self.bdayYYTextField){
            let newString = _textField.text! + string;
            if(newString.characters.count == 4){
                _textField.text = newString;
                self.navigationItem.rightBarButtonItem = nil;
                _textField.resignFirstResponder();
                return false;
            }
            return true;
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            tableView.deselectRowAtIndexPath(indexPath, animated: false);
            if(indexPath.row == 0){
                print("Upload new avatar");
                selectedPhoto = 1;
                picker.allowsEditing = true
                picker.sourceType = .PhotoLibrary
                picker.modalPresentationStyle = .Popover
                presentViewController(picker, animated: true, completion: nil)
            }
            if(indexPath.row == 1){
                print("Upload new cover");
                selectedPhoto = 2;
                picker.allowsEditing = true
                picker.sourceType = .PhotoLibrary
                picker.modalPresentationStyle = .Popover
                presentViewController(picker, animated: true, completion: nil)
            }
        }
    }
    @IBAction func resetPassword(sender:UIButton) {
        let mResetPasswordVC = self.storyboard?.instantiateViewControllerWithIdentifier("UpdatePasswordController") as! UpdatePasswordController
        Singleton.sharedInstance.updatePasswordFromMenu = false
        self.navigationController?.pushViewController(mResetPasswordVC, animated: true)
    }
    @IBAction func saveChanges(sender: UIButton) {
        self.doneEditingText(sender);
        var alreadyFlaggedBdayFields: Bool = false;
        var hasErrors: Bool = false;
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
            if(textField == self.zipCodeTextField){
                if(textField.text?.characters.count < 5){
                    hasErrors = true;
                    self.addErrorImageViewFor(textField);
                }
            }
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

            if(textField == self.bdayDDTextField || textField == self.bdayMMTextField || textField == self.bdayYYTextField){
                if(alreadyFlaggedBdayFields == true){
                    continue;
                }
                if(self.bdayDDTextField.text?.characters.count < 2 ||
                    self.bdayMMTextField.text?.characters.count < 2 ||
                    self.bdayYYTextField.text?.characters.count < 4){
                        hasErrors = true;
                        self.addErrorImageViewFor(textField);
                }else{
                    let dateComponents = NSDateComponents();
                    dateComponents.year = Int(self.bdayYYTextField.text!)!;
                    dateComponents.month = Int(self.bdayMMTextField.text!)!;
                    dateComponents.day = Int(self.bdayDDTextField.text!)!;
                    if dateComponents.isValidDateInCalendar(NSCalendar.currentCalendar())
                    {
                        
                    }else{
                        hasErrors = true;
                        self.addErrorImageViewFor(textField);
                    }
                }
                alreadyFlaggedBdayFields = true;
            }
        }
        
        if(hasErrors == true){
            return;
        }
        
        self.view.addSubview(self.loadingView);
        self.loadingIndicator.startAnimating();
        
        let gender: String = self.genderSelect.selectedSegmentIndex == 0 ? "male" : "female";
        let birthday: String = self.bdayDDTextField.text!+"-"+self.bdayMMTextField.text!+"-"+self.bdayYYTextField.text!;
        let user = Singleton.sharedInstance.user;
        user.gender = gender;
        user.birthday = birthday;
        user.zipCode = self.zipCodeTextField.text!;
        user.firstName = self.firstNameTextField.text!;
        user.lastName = self.lastNameTextField.text!;
        user.email = self.emailTextField.text!;
        if(self.fbUserObject != nil){
            //let fbUserJson = NSJSONSerialization.
            //var err: NSError?
            let dictionaryData: NSData =  try! NSJSONSerialization.dataWithJSONObject(self.fbUserObject, options:NSJSONWritingOptions(rawValue: 0))
            let fbUserJson = NSString(data: dictionaryData, encoding: NSUTF8StringEncoding)
            
            if(fbUserJson != nil){
                user.fbDataJson = fbUserJson as? String;
            }
        }
        if reachabilityHandler.verifyInternetConnection() == true {
            wsManager.updateUserProfile(user, completionHandler: { (success, message: String?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success {
                        self.loadingIndicator.stopAnimating();
                        self.loadingView.removeFromSuperview();
                        
                        print("Need to make an alert for successfully edited user");
                        let msg = "Profile updated";
                        self.presentViewController(self.alertControlerManager.alertForServerError("Profile", errorMessage: msg), animated: true, completion: nil)
                        
                    } else {
                        self.loadingIndicator.stopAnimating();
                        self.loadingView.removeFromSuperview();
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
        }else {
            self.loadingIndicator.stopAnimating();
            self.loadingView.removeFromSuperview();
            self.presentViewController(alertControlerManager.alertForFailInInternetConnection(), animated: true, completion: nil)
        }
        
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
            avatarImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
            if(avatarImage.image != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.saveAvatar(avatarImage.image!, completionHandler: nil);
                }                
                uploadAvatarTableViewCell.accessoryType = .Checkmark;
            }
            
        case 2:
            print("case 2")
            if(info[UIImagePickerControllerOriginalImage] != nil){
                Singleton.sharedInstance.user.coverImage = info[UIImagePickerControllerOriginalImage] as? UIImage;
            }
            coverImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if(self.coverImage.image != nil){
                if reachabilityHandler.verifyInternetConnection() == true {
                    wsManager.saveCover(coverImage.image!, completionHandler: nil);
                }
                uploadCoverTableViewCell.accessoryType = .Checkmark;
            }
        default:
            print("[Profile EDIT] Fell through options for uploading ");
        }
        dismissViewControllerAnimated(true, completion: nil) //5
    }
        
}