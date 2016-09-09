//
//  UIImage+Orientation.h
//  Talk
//
//  Created by teambition-ios on 14/10/30.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Orientation)
//fix the image bug when upload to not mac Server
+ (UIImage *)fixOrientation:(UIImage *)aImage;
@end
