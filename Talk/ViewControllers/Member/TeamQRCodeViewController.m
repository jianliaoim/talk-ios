//
//  TeamQRCodeViewController.m
//  Talk
//
//  Created by 史丹青 on 6/10/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TeamQRCodeViewController.h"
#import "constants.h"
#import "MOTeam.h"
#import <CoreData+MagicalRecord.h>
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "UIColor+TBColor.h"

@interface TeamQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *teamName;
@property (weak, nonatomic) IBOutlet UIImageView *QRcode;
@property (weak, nonatomic) IBOutlet UILabel *remind;

@end

@implementation TeamQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"QR Code", "QR Code");
    
    //set navigationbar item
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refresh", @"Refresh") style:UIBarButtonItemStylePlain target:self action:@selector(refreshQRCode:)];
    self.navigationItem.rightBarButtonItem = refreshBarButton;
    
    //set team id
    if (self.currentTeamId > 0) {
    } else {
        self.currentTeamId = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    }
    
    MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:self.currentTeamId];
    NSString *teamName = team.name;
    [[NSUserDefaults standardUserDefaults] setValue:team.name forKey:kCurrentTeamName];
    
    [self.teamName setText:teamName];
    self.teamName.textColor = [UIColor jl_redColor];
    
    [self.remind setText:NSLocalizedString(@"Others can scan the code to add team", @"Others can scan the code to add team")];
    [self generateTeamQRCode];
}

#pragma mark - IBAction

- (IBAction)refreshQRCode:(UIButton *)sender {
    [self refreshSignCode];
}

#pragma mark - Private

- (void)generateTeamQRCode {
    // Get current team data
    NSString *teamID = self.currentTeamId;
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamID];
    
    if (moTeam.id && moTeam.name && moTeam.color && moTeam.signCode) {
        // Generate json string
        NSError *error;
        NSDictionary *params = @{@"_id":moTeam.id,@"name":moTeam.name,@"color":moTeam.color,@"signCode":moTeam.signCode};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // base64encode
        NSData *plainData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        
        // Generate QRcode
        CIImage *qrCode = [self createQRForString:base64String];
        
        UIImage *qrCodeImage = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:2 * [UIScreen mainScreen].scale];
        UIImage *coloredQRcodeImage = [self imageBlackToTransparent:qrCodeImage withColor:[UIColor jl_redColor]];
        self.QRcode.image = coloredQRcodeImage;
    }
    
}

#pragma mark - HTTP

- (void)refreshSignCode {
    // Get current team data
    NSString *teamID = self.currentTeamId;
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamID];
    
    // Request new signCode
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    NSDictionary *param = @{@"properties":@{@"signCode":@"1"}};
    [[TBHTTPSessionManager sharedManager] POST:[NSString stringWithFormat:kTeamRefreshURLString,teamID] parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        [SVProgressHUD dismiss];
        
        moTeam.signCode = [responseObject valueForKey:@"signCode"];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [self generateTeamQRCode];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
    
}

#pragma mark - Utility methods
- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale {
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    // Need to set the image orientation correctly
    UIImage *flippedImage = [UIImage imageWithCGImage:[scaledImage CGImage]
                                                scale:scaledImage.scale
                                          orientation:UIImageOrientationDownMirrored];
    
    return flippedImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage*)imageBlackToTransparent:(UIImage*)image withColor:(UIColor *)uicolor{
    
    CGColorRef color = [uicolor CGColor];
    const CGFloat* colors = CGColorGetComponents( color );
    CGFloat red = colors[0]*255;
    CGFloat green = colors[1]*255;
    CGFloat blue = colors[2]*255;
    
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
