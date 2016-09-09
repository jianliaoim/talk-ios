//
//  JLWelcomeViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/27/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLWelcomeViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let teambitionViewModel = JLWelcomeViewModel()

    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.setTitle(NSLocalizedString("Sign in", comment: "Sign in"), forState: UIControlState.Normal)
        signUpButton.setTitle(NSLocalizedString("Sign up", comment: "Sign up"), forState: UIControlState.Normal)
        
        TBUtility.startimingEventWithAction(kAnalyticsTimingLoginDuration)
        TBUtility.startimingEventWithAction(kAnalyticsTimingRegisterDuration)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated:animated)
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated:animated)
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let loginVC = segue.destinationViewController as! JLLoginViewController
        if let identifier = segue.identifier {
            switch  identifier {
            case "SignIn":
                loginVC.isSignin = true
                TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionLoginReady, label: "", value: nil)
            case "SignUp":
                loginVC.isSignin = false
                TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionRegisterReady, label: "", value: nil)
            default:
                loginVC.isSignin = true
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func loginWithTeambition(sender: UIButton) {
        TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionLoginReady, label: "", value: nil)
        let webVC = TBLoginViewController()
        webVC.delegate = self
        let nc = UINavigationController(rootViewController: webVC)
        presentViewController(nc, animated: true, completion: nil)
    }
    
}

// MARK: TBLoginViewControllerDelegate

extension JLWelcomeViewController: TBLoginViewControllerDelegate {
    
    func finishLoginFromTeambition(codeString:String) {
        TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionLoginSuccess, label: kAnalyticsLabelWithTeambition, value: nil)

        SVProgressHUD.showWithStatus(NSLocalizedString("Loading...", comment: "Loading..."))
        teambitionViewModel.loginCode = codeString
        teambitionViewModel.loginWithTeambitionCode().subscribeNext({ (x) -> Void in
            let isNewUser = x as! Bool
            if isNewUser {
                let completeInfoVC = self.storyboard?.instantiateViewControllerWithIdentifier("JLCompleteUserInfoViewController") as! JLCompleteUserInfoViewController
                self.navigationController?.pushViewController(completeInfoVC, animated: false)
            } else {
                let chooseTeamVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseTeamViewController") as! ChooseTeamViewController
                self.navigationController?.pushViewController(chooseTeamVC, animated: false)
            }
            }, error: { (error:NSError!) -> Void in
                SVProgressHUD.showErrorWithStatus(error.localizedRecoverySuggestion)
        })
        
    }
    
}

