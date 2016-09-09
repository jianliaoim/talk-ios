//
//  BindAccountViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/31/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class BindAccountViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var inputPhoneView:InputPhoneView?
    var inputVerificationCodeView:InputVerificationCodeView?
    var remindView: RemindView?
    
    var viewModel = BindAccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self == navigationController?.viewControllers[0] {
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIBarButtonItemStyle.Done, target: self, action: "cancelVC")
            navigationItem.leftBarButtonItem = cancelButton
            self.navigationController?.navigationBar.barTintColor = UIColor.tb_blueColor()
        }
        
        title = NSLocalizedString("Linked accounts", comment: "Linked accounts")
        tableView.dataSource = self
        tableView.delegate = self
        checkBindAccounts()
    }
    
    func cancelVC() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Bind account related

extension BindAccountViewController {
    
    func checkBindAccounts() {
        SVProgressHUD.showWithStatus(NSLocalizedString("Loading...", comment: "Loading..."))
        viewModel.checkBindStatus().subscribeNext({ [unowned self] (x) -> Void in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            }, error: { (error:NSError!) -> Void in
            SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
        })
    }
    
    func bindMobilePhone() {
        inputPhoneView = InputPhoneView.loadFromNibNamed("InputPhoneView") as? InputPhoneView
        inputPhoneView!.delegate = self
        inputPhoneView!.isEmail = false
        navigationController!.view.addSubview(inputPhoneView!)
        inputPhoneView!.showWithTitle(NSLocalizedString("Link mobilephone", comment: "Link mobilephone"), reminder: NSLocalizedString("Please verify your phone, Jianliao will send you a message.", comment: "Please verify your phone, Jianliao will send you a message."))
    }
    
    func bindEmail() {
        inputPhoneView = InputPhoneView.loadFromNibNamed("InputPhoneView") as? InputPhoneView
        inputPhoneView!.delegate = self
        inputPhoneView!.isEmail = true
        navigationController!.view.addSubview(inputPhoneView!)
        inputPhoneView!.showWithTitle(NSLocalizedString("Link email", comment: "Link email"), reminder: NSLocalizedString("Please verify your email", comment: "Please verify your email"))
    }
    
    func inputVerificationCode(isEmail:Bool) {
        inputPhoneView = nil
        inputVerificationCodeView = InputVerificationCodeView.loadFromNibNamed("InputVerificationCodeView") as? InputVerificationCodeView
        inputVerificationCodeView!.delegate = self
        inputVerificationCodeView!.isEmail = isEmail
        navigationController!.view.addSubview(inputVerificationCodeView!)
        if isEmail {
            inputVerificationCodeView!.showWithTitle(NSLocalizedString("Input verification code", comment: "Input verification code"), reminder: NSLocalizedString("Aready send code to your email", comment: "Aready send code to your email"))
        } else {
            inputVerificationCodeView!.showWithTitle(NSLocalizedString("Input verification code", comment: "Input verification code"), reminder: NSLocalizedString("Aready send code to you mobile", comment: "Aready send code to you mobile"))
        }
    }
    
    func remindBindAccountHasExisted(showname:String) {
        remindView = RemindView.loadFromNibNamed("RemindView") as? RemindView
        remindView!.delegate = self
        navigationController!.view.addSubview(remindView!)
        remindView!.showWithTitle(NSLocalizedString("This account has already been linked", comment: "This account has already been linked"), reminder: NSString(format: NSLocalizedString("%@ has already been created. If you continue, the old account will be canceled", comment: "%@ has already been created. If you continue, the old account will be canceled"), showname) as String, rightButtonName:NSLocalizedString("Link", comment: "Link"), color:UIColor.tb_warningColor())
    }
    
    func showBindSuccessView() {
        let successView = RemindView.loadFromNibNamed("SuccessView") as! SuccessView
        navigationController!.view.addSubview(successView)
        successView.showWithTitle(NSLocalizedString("Link success", comment: "Link success"), reminder: NSLocalizedString("You can use this account to login Jianliao", comment: "You can use this account to login Jianliao"))
        tableView.reloadData()
    }
    
    func bindTeambition() {
        if viewModel.hasBindTeambition {
            remindView = RemindView.loadFromNibNamed("RemindView") as? RemindView
            remindView!.delegate = self
            navigationController!.view.addSubview(remindView!)
            remindView!.showWithTitle(NSLocalizedString("Unlink teambition", comment: "Unlink teambition"), reminder:NSLocalizedString("After you unlink the Teambition, you cannot login by Teambition account", comment: "After you unlink the Teambition, you cannot login by Teambition account"), rightButtonName:NSLocalizedString("Unlink", comment: "Unlink"), color:UIColor.tb_warningColor())
            viewModel.wantUnbindTeambition = true
        } else {
            let webVC = TBLoginViewController()
            webVC.delegate = self
            let nc = UINavigationController(rootViewController: webVC)
            presentViewController(nc, animated: true, completion: nil)
        }
    }
    
    func remindQQEmail() {
        let alertController: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("QQ Email Remind", comment: "QQ Email Remind"), preferredStyle: .Alert)
        let editAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Back and Edit", comment: "Back and Edit"), style: .Default) { (action) -> Void in
        };
        let continueAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Continue", comment: "Continue"), style: .Default) { (action) -> Void in
            self.sendVerifyCode(true)
        };
        alertController.addAction(editAction)
        alertController.addAction(continueAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.jl_redColor()
    }
    
    func sendVerifyCode(isEmail:Bool) {
        viewModel.sendVerifyCode().subscribeNext({ [unowned self] (x) -> Void in
            if self.inputPhoneView != nil {
                self.inputPhoneView?.removeFromSuperview()
            }
            self.inputVerificationCode(isEmail)
            }, error: { (error:NSError!) -> Void in
                TBUtility.showMessageInError(error)
        })
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate

extension BindAccountViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BindAccountCell") as! BindAccountCell
        cell.bindButton.setTitleColor(UIColor.jl_redColor(), forState: UIControlState.Normal)
        switch (indexPath.row) {
            case 0:
                cell.bindImage.image = UIImage(named: "icon-phone")
                cell.bindName.text = NSLocalizedString("Mobile number", comment: "Mobile number")
                if viewModel.hasBindMobile {
                    cell.bindAccount.text = viewModel.showPhoneMobile
                } else {
                    cell.bindAccount.text = NSLocalizedString("Unlinked", comment: "Unlinked")
                }
                
                cell.bindButton.setTitle(NSLocalizedString("Link", comment: "Link"), forState: UIControlState.Normal)
                if viewModel.hasBindMobile {
                    cell.bindButton.setTitle(NSLocalizedString("Change", comment: "Change"), forState: UIControlState.Normal)
                }
                
                cell.bindButton.addTarget(self, action: "bindMobilePhone", forControlEvents: UIControlEvents.TouchUpInside)
                break;
        case 1:
            cell.bindImage.image = UIImage(named: "icon-mail")
            cell.bindName.text = NSLocalizedString("Email", comment: "Email")
            let separator = UIView.init(frame: CGRectMake(50, 0, CGRectGetWidth(cell.contentView.frame), 2/UIScreen.mainScreen().scale))
            separator.backgroundColor = UIColor.jl_separatorColor();
            cell.contentView.addSubview(separator)
            if viewModel.hasBindEmail {
                cell.bindAccount.text = viewModel.showEmail
            } else {
                cell.bindAccount.text = NSLocalizedString("Unlinked", comment: "Unlinked")
            }
            
            cell.bindButton.setTitle(NSLocalizedString("Link", comment: "Link"), forState: UIControlState.Normal)
            if viewModel.hasBindEmail {
                cell.bindButton.setTitle(NSLocalizedString("Change", comment: "Change"), forState: UIControlState.Normal)
            }
            cell.bindButton.addTarget(self, action: "bindEmail", forControlEvents: UIControlEvents.TouchUpInside)
            break;
        case 2:
            cell.bindImage.image = UIImage(named: "teambition")
            cell.bindName.text = "Teambition"
            let separator = UIView.init(frame: CGRectMake(50, 0, CGRectGetWidth(cell.contentView.frame), 2/UIScreen.mainScreen().scale))
            separator.backgroundColor = UIColor.jl_separatorColor();
            cell.contentView.addSubview(separator)
            if viewModel.hasBindTeambition {
                cell.bindAccount.text = viewModel.showTeambitionAccount
            } else {
                cell.bindAccount.text = NSLocalizedString("Unlinked", comment: "Unlinked")
            }
            if viewModel.hasBindMobile || viewModel.hasBindEmail {
                cell.bindButton.hidden = false
                cell.bindButton.setTitle(NSLocalizedString("Link", comment: "Link"), forState: UIControlState.Normal)
                if viewModel.hasBindTeambition {
                    cell.bindButton.setTitle(NSLocalizedString("Unlink", comment: "Unlink"), forState: UIControlState.Normal)
                }
                cell.bindButton.addTarget(self, action: "bindTeambition", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.bindButton.hidden = true
            }
            
            
                break;

            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
}

extension BindAccountViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
}

// MARK: InputPhoneViewDelegate

extension BindAccountViewController: InputPhoneViewDelegate {
    
    func clickCompleteButtonInInputPhoneView(phoneNumber:String, isEmail:Bool) {
        viewModel.phoneNumber = phoneNumber
        viewModel.isEmail = isEmail
        if isEmail {
            if let email:NSString = phoneNumber {
                if email.isQQEmail() {
                   self.remindQQEmail()
                } else {
                    self.sendVerifyCode(isEmail)
                }
            } else {
                self.sendVerifyCode(isEmail)
            }
        } else {
            validImage()
        }
    }
    
    func changeCountryCode() {
        let countryCodeVC = SelectCountryToInputMobileNumberViewController()
        countryCodeVC.delegate = self
        let navVC = UINavigationController(rootViewController: countryCodeVC)
        presentViewController(navVC, animated: true, completion: nil)
    }

    func validImage() {
        let imageValidVC = UIStoryboard(name: kLoginStoryboard, bundle: nil).instantiateViewControllerWithIdentifier("JLImageValidController") as! JLImageValidController
        imageValidVC.delegate = self
        presentViewController(imageValidVC, animated: true, completion: nil)
    }
}

// MARK: JLImageValidControllerDelegate

extension BindAccountViewController: JLImageValidControllerDelegate {
    func cancelValid() {
    }
    
    func successValid(uid: NSString) {
        viewModel.validUid = uid as String
        self.sendVerifyCode(viewModel.isEmail)
    }
}

// MARK: InputVerificationCodeViewDelegate

extension BindAccountViewController: InputVerificationCodeViewDelegate {
    
    func clickCompleteButtonInInputVerificationCodeView(verifycode:String) {
        viewModel.verificationCode = verifycode
        if self.viewModel.isEmail {
            if !viewModel.hasBindEmail {
                bindMobileOrEmail()
            } else {
                changeMobileOrEmail()
            }
        } else {
            if !viewModel.hasBindMobile {
                bindMobileOrEmail()
            } else {
                changeMobileOrEmail()
            }
        }
    }
    
    func bindMobileOrEmail() {
        viewModel.bindMobileOrEmail().subscribeNext({ [unowned self] (x) -> Void in
            if self.inputVerificationCodeView != nil {
                self.inputVerificationCodeView?.removeFromSuperview()
            }
            self.showBindSuccessView()
            }, error: { (error:NSError!) -> Void in
                let jsonData = (error.userInfo as! [String:AnyObject])[AFNetworkingOperationFailingURLResponseDataErrorKey] as! NSData
                let dict = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())) as! NSDictionary
                print(dict)
                let dataDict = dict["data"] as! NSDictionary
                if dict["code"] as? Int == 230 {
                    self.viewModel.bindCode = dataDict["bindCode"] as? String
                    if self.inputVerificationCodeView != nil {
                        self.inputVerificationCodeView?.removeFromSuperview()
                    }
                    if self.viewModel.isEmail {
                        self.viewModel.needForceBindEmail = true
                        self.remindBindAccountHasExisted(dataDict["showname"] as! String)
                    } else {
                        self.viewModel.needForceBindMobile = true
                        self.remindBindAccountHasExisted(dataDict["showname"] as! String)
                    }
                } else {
                    self.inputVerificationCodeView?.wrongVerificationCodeUI()
                }
                
        })
    }
    
    func changeMobileOrEmail() {
        viewModel.changeMobileOrEmail().subscribeNext({ [unowned self] (x) -> Void in
            if self.inputVerificationCodeView != nil {
                self.inputVerificationCodeView?.removeFromSuperview()
            }
            self.showBindSuccessView()
            }, error: { (error:NSError!) -> Void in
                let jsonData = (error.userInfo as! [String:AnyObject])[AFNetworkingOperationFailingURLResponseDataErrorKey] as! NSData
                let dict = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())) as! NSDictionary
                print(dict)
                let dataDict = dict["data"] as! NSDictionary
                if dict["code"] as? Int == 230 {
                    self.viewModel.bindCode = dataDict["bindCode"] as? String
                    print("bindcode:\(self.viewModel.bindCode)")
                    if self.inputVerificationCodeView != nil {
                        self.inputVerificationCodeView?.removeFromSuperview()
                    }
                    self.viewModel.needForceBindMobile = true
                    self.remindBindAccountHasExisted(dataDict["showname"] as! String)
                } else {
                    self.inputVerificationCodeView?.wrongVerificationCodeUI()
                }
                
        })
    }
    
    func sendVerifyCodeAgain() {
        viewModel.sendVerifyCode().subscribeNext({ [unowned self] (x) -> Void in
                self.inputVerificationCodeView!.setSendAgainButton()
            }, error: { (error:NSError!) -> Void in
                SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
        })
    }
}

// MARK: RemindViewDelegate

extension BindAccountViewController: RemindViewDelegate {
    
    func clickFinishButtonInRemindView() {
        
        if viewModel.wantUnbindTeambition {
            viewModel.unbindTeambitionAccount().subscribeNext({ [unowned self] (x) -> Void in
                self.viewModel.hasBindTeambition = false
                self.tableView.reloadData()
                }, error: { (error:NSError!) -> Void in
                    SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
            })
            viewModel.wantUnbindTeambition = true
        }
        
        if viewModel.needForceBindMobile {
            viewModel.forceBindMobileOrEmail().subscribeNext({ [unowned self] (x) -> Void in
                self.remindView?.removeFromSuperview()
                self.viewModel.needForceBindMobile = false
                self.showBindSuccessView()
                }, error: { (error:NSError!) -> Void in
                    SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
            })
        } else if viewModel.needForceBindEmail {
            viewModel.forceBindMobileOrEmail().subscribeNext({ [unowned self] (x) -> Void in
                self.remindView?.removeFromSuperview()
                self.viewModel.needForceBindEmail = false
                self.showBindSuccessView()
                }, error: { (error:NSError!) -> Void in
                    SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
            })
        } else if viewModel.needForceBindTeambition {
            viewModel.forceBindWithTeambitionAccount().subscribeNext({ [unowned self] (x) -> Void in
                self.remindView?.removeFromSuperview()
                self.viewModel.needForceBindTeambition = false
                self.showBindSuccessView()
                }, error: { (error:NSError!) -> Void in
                SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
            })
        }
        
    }
    
}

// MARK: TBLoginViewControllerDelegate

extension BindAccountViewController: TBLoginViewControllerDelegate {
    
    func finishLoginFromTeambition(codeString:String) {
        viewModel.loginCode = codeString
        viewModel.bindWithTeambitionCode().subscribeNext({ (x) -> Void in
            self.showBindSuccessView()
            self.viewModel.hasBindTeambition = true
            }, error: { (error:NSError!) -> Void in
                let jsonData = (error.userInfo as! [String:AnyObject])[AFNetworkingOperationFailingURLResponseDataErrorKey] as! NSData
                let dict = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())) as! NSDictionary
                print(dict)
                let dataDict = dict["data"] as! NSDictionary
                if dict["code"] as? Int == 230 {
                    self.viewModel.bindCode = dataDict["bindCode"] as? String
                    print("bindcode:\(self.viewModel.bindCode)")
                    self.viewModel.needForceBindTeambition = true
                    self.remindBindAccountHasExisted(dataDict["showname"] as! String)
                } else {
                    SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
                }
        })
    }
}

// MARK: SelectCountryDelegate

extension BindAccountViewController: SelectCountryCodeDelegate {
    
    func selectedCountry(selectedCountry: TBCountry!) {
        viewModel.countryCode = "+\(selectedCountry.phoneCode)"
        inputPhoneView!.countryCode = viewModel.countryCode
        inputPhoneView!.countryCodeLabel.text = viewModel.countryCode
    }
    
}

