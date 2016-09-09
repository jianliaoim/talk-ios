//
//  UIFont+TBUtilitier.m
//  Talk
//
//  Created by 王卫 on 15/11/17.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "UIFont+TBUtilities.h"

@implementation UIFont (TBUtilities)

+ (UIFont *)boldFontWithFont:(UIFont *)font {
    UIFontDescriptor *fontDescriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:0];
}

@end
