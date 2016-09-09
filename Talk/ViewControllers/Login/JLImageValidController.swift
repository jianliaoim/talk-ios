//
//  JLImageValidController.swift
//  Talk
//
//  Created by Suric on 16/1/12.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

protocol JLImageValidControllerDelegate : NSObjectProtocol {
    func cancelValid()
    func successValid(uid: NSString)
}

class JLImageValidController: UIViewController {
    @IBOutlet weak var naviagtionBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: TBButton!
    
    let collectionVIewCellIdentifier = "ImageValidCollectionViewCell"
    weak var delegate: JLImageValidControllerDelegate?
    var imageValues: NSMutableArray?
    var appointImageName: NSString?
    var appointUid: NSString?
    var selectedIndex:NSIndexPath?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    // MARK: -LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        cancelButton.backgroundColor = UIColor.jl_redColor()
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: .Normal)
        doneButton.backgroundColor = UIColor.jl_redColor()
        doneButton.setTitle(NSLocalizedString("Sure", comment: "Sure"), forState: .Normal)
        refreshImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            if delegate.respondsToSelector("cancelValid") {
                delegate.cancelValid()
            }
        }
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if (imageValues == nil) || (selectedIndex == nil)  {
            return
        }
        doneButton.startLoading()
        let value = imageValues?.objectAtIndex(selectedIndex!.row) as! String
        TBLoginSessionManager.sharedManager().GET(KImageValidURLString.stringByAppendingString("/valid"), parameters: ["uid": appointUid!,"value": value], success: { (task: NSURLSessionDataTask!, response) -> Void in
            self.doneButton.stopLoading()
            let responseDictionary = response as! NSDictionary
            let isValid = (responseDictionary["valid"]?.boolValue)! as Bool
            if isValid {
                if self.delegate!.respondsToSelector("successValid:") {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.successValid(self.appointUid!)
                }
            } else {
                self.refreshImage()
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("Wrong valid image", comment: "Wrong valid image"))
            }
            }, failure:{ (task: NSURLSessionDataTask!, error: NSError) -> Void in
                self.doneButton.stopLoading()
                TBUtility.showMessageInError(error)
        })
        
    }
    
    //MARK: Private Methods
    
    func refreshImage() {
        let language = TBUtility.systemLanguageIsChinese() ? "zh" : "en"
        TBLoginSessionManager.sharedManager().GET(KImageValidURLString.stringByAppendingString("/setup"), parameters: ["num": 5,"lang": language], success: { (task: NSURLSessionDataTask!, response) -> Void in
            let responseDictionary = response as! NSDictionary
            self.imageValues = responseDictionary["values"] as? NSMutableArray
            self.appointImageName = responseDictionary["imageName"] as? NSString
            self.appointUid = responseDictionary["uid"] as? NSString
            self.reloadData()
            }, failure:{ (task: NSURLSessionDataTask!, error: NSError) -> Void in
                TBUtility.showMessageInError(error)
        })
    }
    
    func reloadData () {
        if let appointImageName = appointImageName {
            let title = "\(NSLocalizedString("Please Select", comment: "Please Select")): \(appointImageName)"
            self.customNavigationItem.title = title
        }
        self.collectionView.reloadData()
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension JLImageValidController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented == self {
            let imageValidVC = ImageValidPresentationController(presentedViewController: presented, presentingViewController: presenting)
            imageValidVC.presentSize = CGSizeMake(300, 160)
            return imageValidVC
        }
        return nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return ImageValidPresentationAnimationController(isPresenting: true)
        } else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return ImageValidPresentationAnimationController(isPresenting: false)
        } else {
            return nil
        }
    }
}

// MARK: - UICollectionViewDataSource

extension JLImageValidController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionVIewCellIdentifier, forIndexPath: indexPath) as! ImageValidCollectionViewCell
        if let appointUid = appointUid {
            let imageURLString = KImageValidURLString.stringByAppendingFormat("/image?uid=%@&index=%d", appointUid, indexPath.row)
            print("imageURLString:\(imageURLString)")
            cell.validImageView.hnk_setImageFromURL(NSURL(string: imageURLString), placeholder: UIImage(named: "photoDefault"))
        } else {
            cell.validImageView.hnk_setImageFromURL(nil, placeholder: UIImage(named: "photoDefault"))
        }
        cell.selectedImageView.hidden = true
        cell.selectedImageView.image = UIImage(named: "icon-member-selecting")
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension JLImageValidController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectedIndex = selectedIndex {
            let oldSelectedCell = collectionView.cellForItemAtIndexPath(selectedIndex) as! ImageValidCollectionViewCell
            oldSelectedCell.selectedImageView.hidden = true
        }
        selectedIndex = indexPath
        let newSelectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageValidCollectionViewCell
        newSelectedCell.selectedImageView.hidden = false
    }
}
