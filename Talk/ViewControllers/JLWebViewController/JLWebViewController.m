//
//  JSWebViewController.m
//  
//
//  Created by Suric on 15/9/1.
//
//

#import "JLWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MOUser.h"
#import "ChatViewController.h"
#import "MORoom.h"
#import "TBUtility.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NewTopicViewController.h"
#import "SCViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
#import <Photos/Photos.h>
#import "Talk-Swift.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "CTAssetsPickerController.h"
#import "TBChatImageModel.h"
#import "UIImage+Orientation.h"
#import "TBHTTPSessionManager.h"
#import "DOPScrollableActionSheet.h"
#import "ShareToTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "TBFileSessionManager.h"
#import <JLRoutes/JLRoutes.h>

static NSString * const deviceVersion = @"device.version";
static NSString * const bizChat = @"biz.chat";
static NSString * const bizCreateTopic = @"biz.createTopic";
static NSString * const bizUploadImage = @"biz.uploadImage";
static NSString * const bizScanQrcode = @"biz.scanQrcode";
static NSString * const bizGetLocation = @"biz.getLocation";
static NSString * const bizGetUserId = @"biz.getUserId";

static NSString * const jsSDKDemoURLString = @"https://jianliao.com/site/jssdk/demo";

@interface JLWebViewController ()<NewTopicViewControllerDelegate,CLLocationManagerDelegate,BRNImagePickerSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,SCViewControllerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property WebViewJavascriptBridge* bridge;
@property (strong, nonatomic) UIWebView* uiWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) WVJBResponseCallback currentCallback;

@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, strong) UIPopoverController *actionPopoverController;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;

@end

@implementation JLWebViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _geocoder = [[CLGeocoder alloc]init];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.adjustsImageWhenHighlighted = YES;
    [backButton setTitle:NSLocalizedString(@"Back", @"Back") forState:UIControlStateNormal];
    [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
    [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton setTintColor:self.navigationController.navigationBar.tintColor];
    [backButton setFrame:CGRectMake(0, 0, 50, 40)];
    [backButton setImage:[[UIImage imageNamed:@"webview-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeItemPressed:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backItem,closeItem, nil];
    if (!self.hideMoreItem) {
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webview-more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreItemPressed:)];
        self.navigationItem.rightBarButtonItem = moreItem;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.progressView];
    self.navigationController.navigationBar.translucent = NO;
    if (_bridge) { return; }
    
    self.uiWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.uiWebView setDelegate:self];
    [self.uiWebView setMultipleTouchEnabled:YES];
    [self.uiWebView setAutoresizesSubviews:YES];
    [self.uiWebView setScalesPageToFit:YES];
    [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.uiWebView];
    
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.uiWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    //version
    [_bridge registerHandler:deviceVersion handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        responseCallback([self successResponseWithData:versionStr]);
    }];
    //enter chat
    [_bridge registerHandler:bizChat handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"biz.chat called: %@", data);
        [self enterChatWithParams:(NSDictionary *)data andCallBack:(WVJBResponseCallback)responseCallback];
    }];
    //create topic
    [_bridge registerHandler:bizCreateTopic handler:^(id data, WVJBResponseCallback responseCallback) {
        [self createTopic];
        responseCallback([self successResponseWithData:@""]);
    }];
    //upload image
    [_bridge registerHandler:bizUploadImage handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bizCreateTopic called: %@", data);
        self.currentCallback = responseCallback;
        [self showImagePickerSheet];
    }];
    //scan QRCode
    [_bridge registerHandler:bizScanQrcode handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bizScanQrcode called: %@", data);
        self.currentCallback = responseCallback;
        [self scanQrCode];
    }];
    //get location
    [_bridge registerHandler:bizGetLocation handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bizGetLocation called: %@", data);
        self.currentCallback = responseCallback;
        [self startLocate];
    }];
    //get UserId
    [_bridge registerHandler:bizGetUserId handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bizGetLocation called: %@", data);
        NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        responseCallback([self successResponseWithData:currentUserId]);
    }];
    
    [self loadExamplePage:self.uiWebView];
    [_bridge send:@"A string sent from ObjC after Webview has loaded."];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)backButtonPressed:(id)sender {
    if (self.uiWebView.canGoBack) {
        [self.uiWebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreItemPressed:(id)sender {
    NSURL *url = self.uiWebView.request.URL;
    
    DOPAction *safariAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Open in safari", @"Open in safari") iconName:@"activity-safari" handler:^{
        [[UIApplication sharedApplication] openURL:url];
    }];
    DOPAction *mailAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Email", @"Email") iconName:@"activity-mail" handler:^{
        [self sendMailWithText:url.absoluteString];
    }];
    DOPAction *messageAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Message", @"Message") iconName:@"activity-message" handler:^{
        [self sendMessageWithText:url.absoluteString];
    }];
    DOPAction *moreAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"More", @"More") iconName:@"activity-more" handler:^{
        [self moreActionWithURL:url];
    }];
    DOPAction *shareAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Forward", @"Forward") iconName:@"activity-share" handler:^{
        [self forwardMessage:url.absoluteString];
    }];
    DOPAction *copyAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Copy link", @"Copy link") iconName:@"activity-copy" handler:^{
        [self copyLink:url.absoluteString];
    }];
    DOPAction *refreshAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Refresh", @"Refresh") iconName:@"activity-refresh" handler:^{
        [self.uiWebView reload];
    }];
    NSArray *actions = @[@"",@[safariAction, mailAction, messageAction, moreAction],
                         @"",@[shareAction,copyAction, refreshAction]];
    DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
    [actionSheet show];
}

- (void)loadExamplePage:(UIWebView*)webView {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

#pragma mark - Activity Actions

//send mail
-(void)sendMailWithText:(NSString *)text
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.navigationBar.tintColor = [UIColor whiteColor];
    if (![MFMailComposeViewController canSendMail]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can not send Email", @"Can not send Email")];
        return;
    }
    mc.mailComposeDelegate = self;
    [mc setMessageBody:text isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
}

//send Message
-(void)sendMessageWithText:(NSString *)text
{
    MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
    mc.navigationBar.tintColor = [UIColor whiteColor];
    if (![MFMessageComposeViewController canSendText]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can not send Message", @"Can not send Message")];
        return;
    }
    mc.messageComposeDelegate = self;
    [mc setBody:text];
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)moreActionWithURL:(NSURL *)url {
    NSArray *items = [NSArray arrayWithObject:url];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)forwardMessage:(NSString *)messsageBody {
    UINavigationController *shareNavigationController = [[UIStoryboard storyboardWithName:kShareStoryboard bundle:nil] instantiateInitialViewController];
    ShareToTableViewController *shareViewController = [shareNavigationController.viewControllers objectAtIndex:0];
    shareViewController.messageBody = messsageBody;
    shareViewController.isSendMessage = YES;
    [self presentViewController:shareNavigationController animated:YES completion:nil];
}

//Copy link
- (void)copyLink:(NSString *)linkString {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:linkString.length > 0 ? linkString : self.urlString];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Copied", @"Copied")];
}

#pragma mark - JS-SDK Methods

- (NSString *)successResponseWithData:(id)data {
    NSDictionary *params = @{@"success": @YES, @"data": data};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

- (NSString *)failedResponseWithErrorCode:(int)errorCode {
    NSString *errorMsg;
    switch (errorCode) {
        case 1:
            errorMsg = NSLocalizedString(@"Wrong parameters", @"Wrong parameters");
            break;
        case 2:
            errorMsg = NSLocalizedString(@"Failed to start", @"Failed to start");
            break;
        case 3:
            errorMsg = NSLocalizedString(@"Opration Cancel", @"Opration Cancel");
            break;
        case 4:
            errorMsg = NSLocalizedString(@"Wrong enter", @"Wrong enter");
            break;
        case 5:
            errorMsg = NSLocalizedString(@"Locate failed", @"Locate failed");
            break;
        case 6:
            errorMsg = NSLocalizedString(@"Scan failed", @"Scan failed");
            break;
        case 7:
            errorMsg = NSLocalizedString(@"uploaded failed", @"uploaded failed");
            break;
        default:
            break;
    }
    NSDictionary *params = @{@"success": @NO, @"error": @{@"code": [NSNumber numberWithInt:errorCode],@"msg": errorMsg}};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

- (void)enterChatWithParams:(NSDictionary *)params andCallBack:(WVJBResponseCallback)responseCallback{
    BOOL isPrivate = [params[@"isPrivate"] boolValue];
    NSString *targetId = params[@"targetId"];
    
    if (isPrivate) {
        MOUser *tempMOUser =[MOUser findFirstWithId:targetId];
        if (tempMOUser) {
            [self enterChatWithMember:tempMOUser];
            responseCallback([self successResponseWithData:@""]);
        } else {
            responseCallback([self failedResponseWithErrorCode:1]);
        }
    } else {
        MORoom *selectedMORoom =[MORoom MR_findFirstByAttribute:@"id" withValue:targetId];
        if (selectedMORoom) {
            [self enterChatWithTopic:selectedMORoom];
            responseCallback([self successResponseWithData:@""]);
        } else {
            responseCallback([self failedResponseWithErrorCode:1]);
        }
    }
}

- (void)enterChatWithTopic:(MORoom *)selectedMORoom {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShareForTopic object:selectedMORoom];
}

- (void)enterChatWithMember:(MOUser *)tempMOUser {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:tempMOUser];
}

- (void)createTopic {
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kNewTopicStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"showAddNewTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    NewTopicViewController *newTopicVC = [temNav.viewControllers objectAtIndex:0];
    newTopicVC.delegate = self;
    [self presentViewController:temNav animated:YES completion:^{
    }];
}

- (void)scanQrCode {
    SCViewController *scanVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SCViewController"];
    scanVC.delegate = self;
    scanVC.isUseForJsSDK = YES;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)startLocate {
    if ([CLLocationManager locationServicesEnabled]) {
        if (iOS8) {
            [self.locationManager requestAlwaysAuthorization];//（iOS8 need Authorization）
        }
        [self.locationManager startUpdatingLocation];
    }else {
        [SVProgressHUD showErrorWithStatus:@"Please Check your network and locate service"];
    }
}

#pragma mark - Upload  photo related

- (void)showImagePickerSheet {
    if (iOS8) {
        PHAuthorizationStatus authorization = [PHPhotoLibrary authorizationStatus];
        if (authorization == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self showImagePickerSheet];
            }];
            return;
        }
        if (authorization == PHAuthorizationStatusAuthorized) {
            BRNImagePickerSheet *sheet = [[BRNImagePickerSheet alloc]init];
            sheet.numberOfButtons = 3;
            sheet.delegate = self;
            sheet.tintColor = [UIColor jl_redColor];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sheet showInView:self.view];
            });
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"An error occurred", @"An error occurred") message:NSLocalizedString(@"Talk needs access to the camera roll", @"Talk needs access to the camera roll") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
        [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        }];
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Choose From Library", @"Choose From Library") withBlock:^(NSInteger theButtonIndex) {
            [self pickerPictureFromLibrary];
        }];
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Take a Photo", @"Take a Photo") withBlock:^(NSInteger theButtonIndex) {
            [self takePictureWith:UIImagePickerControllerSourceTypeCamera];
        }];
        [actionSheet showInView:self.view];
    }
}

-(void)takePictureWith:(UIImagePickerControllerSourceType) type {
    UIImagePickerController * controlerPicker = [[UIImagePickerController alloc]init];
    controlerPicker.navigationBar.tintColor = [UIColor whiteColor];
    controlerPicker.delegate  = self;
    controlerPicker.sourceType = type;
    [self presentViewController:controlerPicker animated:YES completion:nil];
}

-(void)pickerPictureFromLibrary {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allPhotos];
    picker.showsCancelButton    = YES;
    picker.delegate             = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)uploadImageWithImageModels:(NSArray *)imageModels
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading", @"Uploading")];
    NSMutableArray *imageURLArray = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    [imageModels enumerateObjectsUsingBlock:^(TBChatImageModel *imageModel, NSUInteger idx, BOOL *stop) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            [[TBFileSessionManager sharedManager]POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSData *imageData = UIImageJPEGRepresentation(imageModel.image, 0.5);
                [formData appendPartWithFileData:imageData name:@"file" fileName:imageModel.imageName mimeType:[NSString stringWithFormat:@"image/%@",@"jpg"]];
            } success:^(NSURLSessionDataTask *task, id responseObject) {
                DDLogDebug(@"JSON: %@", responseObject);
                NSString *imageURLString = [responseObject objectForKey:@"downloadUrl"];
                if (imageURLString) {
                    [imageURLArray addObject:imageURLString];
                }
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DDLogDebug(@"Error: %@", error);
                dispatch_group_leave(group);
            }];
        });
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (imageURLArray.count > 0) {
            self.currentCallback([self successResponseWithData:imageURLArray]);
        } else {
            self.currentCallback([self failedResponseWithErrorCode:7]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

#pragma mark- Delegate & Protocol

#pragma mark- MFMailComposedelegate
//the delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DDLogDebug(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            DDLogDebug(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            DDLogDebug(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            DDLogDebug(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- MFMailComposedelegate
//the delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
            DDLogDebug(@"Message send canceled...");
            break;
        case MessageComposeResultSent:
            DDLogDebug(@"Message sent...");
            break;
        case MessageComposeResultFailed:
            DDLogDebug(@"Message send Failed");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - BRNImagePickerSheetDelegate
- (NSString *)imagePickerSheet:(BRNImagePickerSheet *)imagePickerSheet titleForButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL photosSelected = imagePickerSheet.numberOfSelectedPhotos > 0;
    
    if (buttonIndex == 0) {
        if (photosSelected) {
            return [NSString localizedStringWithFormat:NSLocalizedString(@"send %lu Photo", @ "The secondary title to send the photos"),imagePickerSheet.numberOfSelectedPhotos];
        } else {
            return NSLocalizedString(@"Take a Photo", @"Take a Photo");
        }
    } else {
        return NSLocalizedString(@"Choose From Library", @"Choose From Library");
    }
}

- (void)imagePickerSheet:(BRNImagePickerSheet *)imagePickerSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL photosSelected = imagePickerSheet.numberOfSelectedPhotos > 0;
    
    if (buttonIndex == 0) {
        if (photosSelected) {
            NSMutableArray *imageModels = [NSMutableArray array];
            [imagePickerSheet.selectedPhotoIndices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAsset *asset = imagePickerSheet.assets[[obj intValue]];
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // Download from cloud if necessary
                options.networkAccessAllowed = YES;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showProgress:progress status:NSLocalizedString(@"Loading from iCloud", @"Loading from iCloud") maskType:SVProgressHUDMaskTypeNone];;
                    });
                };
                
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Dealing", @"Dealing")];
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    NSURL *captureImageURL = (NSURL *)[info objectForKey:@"PHImageFileURLKey"];
                    NSString *captureImageURLStr = captureImageURL.absoluteString;
                    UIImage *captureImage = [UIImage fixOrientation:[UIImage imageWithData:imageData]];
                    TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
                    imageModel.image = captureImage;
                    imageModel.imageName = [[captureImageURLStr componentsSeparatedByString:@"/"] lastObject];
                    [imageModels addObject:imageModel];
                    if (idx == imagePickerSheet.selectedPhotoIndices.count - 1) {
                        [self uploadImageWithImageModels:imageModels];
                    }
                }];
            }];
        } else {
            [self takePictureWith:UIImagePickerControllerSourceTypeCamera];
        }
    }
    else if (buttonIndex == 1)
    {
        [self pickerPictureFromLibrary];
    }
}

- (void)imagePickerSheet:(BRNImagePickerSheet * __nonnull)imagePickerSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        self.currentCallback([self failedResponseWithErrorCode:3]);
    }
}

- (void)imagePickerSheetCancel:(BRNImagePickerSheet *)imagePickerSheet
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.currentCallback([self failedResponseWithErrorCode:3]);
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
            imageModel.image = [UIImage fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
            imageModel.imageName = [NSString stringWithFormat:@"tbfile%u.png",(arc4random() % 10000) + 1];
            [self uploadImageWithImageModels:[NSArray arrayWithObject:imageModel]];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        self.currentCallback([self failedResponseWithErrorCode:3]);
    }];
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *imageModels = [NSMutableArray array];
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *tempAsset = (ALAsset *)obj;
        CGImageRef ref = [[tempAsset  defaultRepresentation] fullResolutionImage];
        TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
        imageModel.image = [[UIImage alloc]initWithCGImage:ref];
        imageModel.imageName = [[tempAsset defaultRepresentation] filename];
        [imageModels addObject:imageModel];
    }];
    [self uploadImageWithImageModels:imageModels];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    } else {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remind", @"Remind")
                                   message:NSLocalizedString(@"Not more than 10 photos", @"Not more than 10 photos")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker {
    self.currentCallback([self failedResponseWithErrorCode:3]);
}

#pragma mark - NewTopicViewControllerDelegate

-(void)successCreateRoom:(MORoom *)room
{
    [self enterChatWithTopic:room];
}

#pragma mark CLLocationManagerDelegate
/**
 * locate success
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation=[locations lastObject];
    NSString *latitude = [NSString stringWithFormat:@"%f",currLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",currLocation.coordinate.longitude];
    
    DDLogDebug(@"la---%@, lo---%@",latitude,longitude);
    [self.locationManager stopUpdatingLocation];
    
    [self.geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *firstPlacemark=[placemarks firstObject];
        NSString *locationName = firstPlacemark.name;
        DDLogDebug(@"LoactionName:%@",locationName);
        self.currentCallback([self successResponseWithData:@{@"latitude": latitude,
                                                             @"longtitude": longitude}]);
    }];
}
/**
 *locate failed
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        DDLogDebug(@"request Denied");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        DDLogDebug(@"unknown location");
    }
    self.currentCallback([self failedResponseWithErrorCode:5]);
}

#pragma mark - SCViewControllerDelegate

- (BOOL)scViewController:(SCViewController *)scViewController doneScanWithString:(NSString *)string {
    [self.navigationController popViewControllerAnimated:YES];
    if (string) {
        DDLogDebug(@"scan result:%@",string);
        self.currentCallback([self successResponseWithData:string]);
    } else {
        self.currentCallback([self failedResponseWithErrorCode:6]);
    }
    return YES;
}

- (void)cancelSCViewController {
    self.currentCallback([self failedResponseWithErrorCode:3]);
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
        NSURL *URL = request.URL;
        //support jump to other APP
        NSString *urlScheme = [URL scheme];
        if (![[urlScheme lowercaseString] isEqualToString:@"http"] && ![[urlScheme lowercaseString] isEqualToString:@"https"])
        {
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
            return NO;
        }
        //support jump to AppStore
        NSString *requestedURL = [URL absoluteString];
        if([requestedURL  rangeOfString:@"itunes"].location != NSNotFound ||[requestedURL  rangeOfString:@"appsto.re"].location != NSNotFound)
        {
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
            return NO;
        }
        self.uiWebViewCurrentURL = URL;
        self.uiWebViewIsLoading = YES;
        [self fakeProgressViewStartLoading];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
            [self fakeProgressBarStopLoading];
            self.navigationItem.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
            [self fakeProgressBarStopLoading];
        }
    }
}

#pragma mark - Fake Progress Bar Control (UIWebView)

- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.fakeProgressTimer) {
        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)fakeProgressBarStopLoading {
    if(self.fakeProgressTimer) {
        [self.fakeProgressTimer invalidate];
    }
    
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)fakeProgressTimerDidFire:(id)sender {
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.uiWebView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
