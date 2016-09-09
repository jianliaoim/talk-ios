//
//  JLCompleteUserInfoViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/28/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLCompleteUserInfoViewController: UIViewController {
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let viewModel = JLCompleteUserInfoViewModel()
    var keyboardIsShow: Bool = false
    var DevicePhonePadKeyboardHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.title = NSLocalizedString("Complete infomation", comment: "Complete infomation")
        commonInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeToNewAvator", name: kPersonalInfoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: UI Layout

extension JLCompleteUserInfoViewController {
    
    func commonInit() {
        nameTextField.tintColor = UIColor.jl_redColor()
        nameTextField.placeholder = NSLocalizedString("Name", comment: "Name")
        nameTextField.leftView = UIView(frame: CGRectMake(0, 0, 18, 0))
        nameTextField.leftViewMode = UITextFieldViewMode.Always
        
        finishButton.setTitle(NSLocalizedString("Sure", comment: "Sure"), forState: .Normal)
        finishButton.backgroundColor = UIColor.tb_defaultColor()
        finishButton.enabled = false
        finishButton.alpha = 0.5
        
        viewModel.getUserInfo().subscribeNext({ (x) -> Void in
            //success
        }, error: { (error) -> Void in
            //self.performSegueWithIdentifier("showTeams", sender: self)
        })
    }
    
    func changeToNewAvator() {
        if (viewModel.avatorUrl != nil) {
            avatarImage.image = viewModel.avatorImage
        }
    }
    
    func textFieldTextDidChange() {
        if nameTextField.text?.characters.count == 0 {
            finishButton.enabled = false
            finishButton.alpha = 0.5
        } else {
            finishButton.enabled = true
            finishButton.alpha = 1.0
        }
    }
    
    func fetchKeyBoardHieght(notification:NSNotification) {
        let userInfo :[NSObject:AnyObject] = notification.userInfo!
        let userDic = userInfo as NSDictionary
        let keyboarFrame: AnyObject? = userDic.valueForKey(UIKeyboardFrameEndUserInfoKey)
        let frame = keyboarFrame?.CGRectValue
        let keyboardY = frame?.height
        if let height = keyboardY {
            DevicePhonePadKeyboardHeight = height
        }
    }
    
    func keyboardWillShow(notification:NSNotification){
        fetchKeyBoardHieght(notification)
        keyboardIsShow = true
        updateCenter()
    }
    
    func keyboardWillHide(notification:NSNotification){
        fetchKeyBoardHieght(notification)
        keyboardIsShow = false
        updateCenter()
    }
    
    func updateCenter() {
        var center: CGPoint
        if keyboardIsShow {
            center = CGPointMake(screenWidth/2.0, screenHeight/2.0 - 50)
        } else {
            center = CGPointMake(screenWidth/2.0, screenHeight/2.0)
        }
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.center = center
        }
    }
}

// MARK: User Interaction

extension JLCompleteUserInfoViewController {
    
    @IBAction func tapGestureAction(sender: AnyObject) {
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func clickFinishButton(sender: UIButton) {
        SVProgressHUD.showWithStatus(NSLocalizedString("Uploading", comment: "Uploading"))
        JLAccountHelper.changeUserName(nameTextField.text).subscribeNext({ [unowned self] (x) -> Void in
            SVProgressHUD.dismiss()
            self.performSegueWithIdentifier("showTeams", sender: self)
            }, error: { (error:NSError!) -> Void in
                TBUtility.showMessageInError(error)
        })
        
    }

    @IBAction func changeAvator(sender: UIButton) {
        nameTextField.resignFirstResponder()
        let actionSheet = UIActionSheet.SH_actionSheetWithTitle(nil)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            actionSheet.SH_addButtonWithTitle(NSLocalizedString("Take a Photo", comment: "Take a Photo"), withBlock: { [unowned self] (theButtonIndex) -> Void in
                let pickerController = UIImagePickerController()
                pickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                pickerController.delegate = self;
                pickerController.allowsEditing = true;
                self.presentViewController(pickerController, animated: true, completion: nil)
            })
        }
        
        actionSheet.SH_addButtonWithTitle(NSLocalizedString("Choose From Library", comment: "Choose From Library"), withBlock: { [unowned self] (theButtonIndex) -> Void in
            let pickerController = UIImagePickerController()
            pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            pickerController.delegate = self;
            pickerController.allowsEditing = true;
            self.presentViewController(pickerController, animated: true, completion: nil)
        })
        actionSheet.SH_addButtonCancelWithTitle(NSLocalizedString("Cancel", comment: "Cancel"), withBlock: nil)
        actionSheet.showInView(self.view)
    }
}

// MARK: UIImagePickerController

extension JLCompleteUserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        viewModel.avatorImage = info[UIImagePickerControllerEditedImage] as! UIImage
        dismissViewControllerAnimated(true, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping:1,initialSpringVelocity:5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            }, completion: nil)
        
        SVProgressHUD.showWithStatus(NSLocalizedString("Uploading avatar", comment: "Uploading avatar"))
        viewModel.uploadUserAvator().subscribeNext({ [unowned self] (x) -> Void in
            self.uploadAvatarUrl()
            }, error: { (error:NSError!) -> Void in
                TBUtility.showMessageInError(error)
        })
    }
    
    func uploadAvatarUrl() {
        viewModel.uploadUserAvatorUrl().subscribeNext({ [unowned self] (x) -> Void in
            //success
            SVProgressHUD.dismiss()
            self.avatarImage.setCornerRadiusWithNumber(40)
            self.changeToNewAvator()
            }, error: { (error:NSError!) -> Void in
                TBUtility.showMessageInError(error)
        })
    }
    
}



