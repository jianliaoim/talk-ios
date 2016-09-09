/*
 Copyright 2013 Scott Logic Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
#import "JoinTeamAfterScanQRCodeViewController.h"
#import "SCViewController.h"
#import "SCShapeView.h"
#import <AVFoundation/AVFoundation.h>

@interface SCViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureVideoPreviewLayer *_previewLayer;
    SCShapeView *_boundingBox;
    NSTimer *_boxHideTimer;
}
@property (strong, nonatomic)UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) AVCaptureSession *captureSession;

@property (strong, nonatomic) NSString *teamId;
@property (strong, nonatomic) NSString *teamName;
@property (strong, nonatomic) NSString *signCode;

@end

@implementation SCViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = NSLocalizedString(@"Scan QR Code", @"Scan QR Code") ;
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(onTapCancel)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    //Set the title of "Select QRCode From Photos" Button
    UIBarButtonItem *pickPhotoButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Photos", @"Photos") style:UIBarButtonItemStylePlain target:self action:@selector(selectQRCodeFromPhotos)];
    self.navigationItem.rightBarButtonItem = pickPhotoButtonItem;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg.png"]];
    
    // Create a new AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [session addInput:input];
    } else {
        DDLogDebug(@"error: %@", error);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [session addOutput:output];
    // We're only interested in QR Codes
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // This VC is the delegate. Please call us on the main queue
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Display on screen
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.view.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    _previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:_previewLayer];
    
    
    // Add the view to draw the bounding box for the UIView
    _boundingBox = [[SCShapeView alloc] initWithFrame:self.view.bounds];
    _boundingBox.backgroundColor = [UIColor clearColor];
    _boundingBox.hidden = YES;
    [self.view addSubview:_boundingBox];
    
    CAShapeLayer *focusLayer = [CAShapeLayer layer];
    
    CGFloat focusWidth = CGRectGetWidth(self.view.bounds) * 0.75;
    CGRect outterFrame = self.view.bounds;
    CGRect innerFrame = CGRectMake((CGRectGetWidth(self.view.bounds) - focusWidth)/2, ((CGRectGetHeight(self.view.bounds) - focusWidth)/2), focusWidth, focusWidth);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(outterFrame), CGRectGetMinY(outterFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(outterFrame), CGRectGetMaxY(outterFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(outterFrame), CGRectGetMaxY(outterFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(outterFrame), CGRectGetMinY(outterFrame))];
    //    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(outterFrame), CGRectGetMinY(outterFrame))];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(innerFrame), CGRectGetMinY(innerFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(innerFrame), CGRectGetMaxY(innerFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(innerFrame), CGRectGetMaxY(innerFrame))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(innerFrame), CGRectGetMinY(innerFrame))];
    //    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(innerFrame), CGRectGetMinY(innerFrame))];
    
    focusLayer.path = maskPath.CGPath;
    focusLayer.fillRule = kCAFillRuleEvenOdd;
    focusLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    
    [_previewLayer addSublayer:focusLayer];
    
    UILabel *hintLable = [UILabel new];
    hintLable.text = NSLocalizedString(@"Please place the QR code in rectangle", @"Please place the QR code in rectangle");
    hintLable.textColor = [UIColor whiteColor];
    hintLable.font = [UIFont fontWithName:@"Helvetica-Neue-Light" size:15];
    [hintLable sizeToFit];
    
    CGPoint labelCenter = self.view.center;
    labelCenter.y = CGRectGetMaxY(innerFrame) + 30;
    hintLable.center = labelCenter;
    
    [self.view addSubview:hintLable];
    
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    // Start the AVSession running
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(delayTime,dispatch_get_main_queue(),^(void){
        [session startRunning];
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
    });
    self.captureSession = session;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            [self.captureSession stopRunning];
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
            // Update the frame on the _boundingBox view, and show it
            _boundingBox.frame = transformed.bounds;
            _boundingBox.hidden = NO;
            // Now convert the corners array into CGPoints in the coordinate system
            //  of the bounding box itself
            NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                      fromView:self.view
                                                        toView:_boundingBox];
            
            // Set the corners array
            _boundingBox.corners = translatedCorners;
            
            // Start the timer which will hide the overlay
            [self startOverlayHideTimer];
            
            //Get the string
            DDLogInfo([transformed stringValue]);
            
            [self getTeamInfoWithJSONString:[transformed stringValue]];
        }
    }
}

#pragma mark - Utility Methods
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(_boxHideTimer) {
        [_boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    _boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    _boundingBox.hidden = YES;
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];

    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}

#pragma mark - UI Event
- (void)onTapCancel {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(cancelSCViewController)]) {
        [self.delegate cancelSCViewController];
    }
}

- (void)selectQRCodeFromPhotos {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = (id)self;
    pickerController.allowsEditing = NO;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *qrCodeImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [self decodeImage:qrCodeImage];}];
}

- (void)decodeImage:(UIImage *)image{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:nil];
    CIImage *cgImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:cgImage];
    CIQRCodeFeature *feature = features.firstObject;
    if (feature.messageString) {
        [self getTeamInfoWithJSONString:feature.messageString];
    } else {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"No QRcode detected", @"No QRcode detected") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alter show];
    }
}

#pragma mark - decode JSON string & add team

- (void)getTeamInfoWithJSONString:(NSString *)string {
    if (self.isUseForJsSDK) {
        if ([self.delegate respondsToSelector:@selector(scViewController:doneScanWithString:)]) {
            [self.delegate scViewController:self doneScanWithString:string];
        }
        return;
    }
    //base64decode
    DDLogDebug(string);
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    DDLogDebug(decodedString);
    
    //JSON decode
    NSData *jsonData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    self.teamId = [jsonDic valueForKey:@"_id"];
    self.teamName = [jsonDic valueForKey:@"name"];
    self.signCode = [jsonDic valueForKey:@"signCode"];
    if (self.teamId == nil||self.teamName == nil||self.signCode == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Wrong QR Code", @"Wrong QR Code") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"showTeamInfo" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    JoinTeamAfterScanQRCodeViewController *teamVC = segue.destinationViewController;
    teamVC._id = self.teamId;
    teamVC.name = self.teamName;
    teamVC.signCode = self.signCode;
}

#pragma mark - UIAlert delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self viewWillAppear:YES];
}

@end
