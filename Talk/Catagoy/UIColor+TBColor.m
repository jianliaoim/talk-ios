//
// Created by Shire on 10/9/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "UIColor+TBColor.h"
#import "constants.h"
#import "MOTeam.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBUtility.h"


@implementation UIColor (TBColor)

// Main Colors
+ (UIColor *)tb_brandColor {
    return [UIColor tb_docColor];
}

//Backgourd color
+ (UIColor *)tb_BackgroundColor {
    return [UIColor colorWithRed:241.0f / 255.0f green:241.0f / 255.0f blue:241.0f / 255.0f alpha:1.0];
}

//Jianliao new color
+ (UIColor *)jl_redColor {
    return [UIColor colorWithRed:250.0f / 255.0f green:104.0f / 255.0f blue:85.0f / 255.0f alpha:1.0];
}

+ (UIColor *)jl_lightRedColor {
    return [[UIColor jl_redColor] colorWithAlphaComponent:0.24];
}

+ (UIColor *)jl_badgeColor {
    return [UIColor colorWithRed:227.0f / 255.0f green:54.0f / 255.0f blue:55.0f / 255.0f alpha:1.0];
};

+ (UIColor *)jl_lightGrayColor {
    return [UIColor colorWithRed:204.0f / 255.0f green:204.0f / 255.0f blue:204.0f / 255.0f alpha:1.0];
};

+ (UIColor *)jl_separatorColor {
    return [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0];
}

+ (UIColor *)jl_plusColor {
    return [UIColor colorWithRed:179.0f/255.0f green:51.0f/255.0f blue:34.0f/255.0f alpha:1.0];
}

+ (UIColor *)jl_tabbarItemSelectedColor {
    return [UIColor colorWithRed:44.0f/255.0f green:47.0f/255.0f blue:51.0f/255.0f alpha:1.0];
}

+ (UIColor *)jl_tabbarItemDeselectedColor {
    return [UIColor colorWithRed:57.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1.0];
}

//Guide color

+ (UIColor *)jl_guideBlueColor {
    return [UIColor colorWithRed:26.0f/255.0f green:35.0f/255.0f blue:126.0f/255.0f alpha:1.0];
}

+ (UIColor *)jl_guideYellowColor {
    return [UIColor colorWithRed:251.0f/255.0f green:220.0f/255.0f blue:166.0f/255.0f alpha:1.0];
}

+ (UIColor *)jl_guideRedColor {
    return [UIColor colorWithRed:255.0f/255.0f green:226.0f/255.0f blue:216.0f/255.0f alpha:1.0];
}

//Dark Color
+ (UIColor *)tb_DarkColor {
    return [UIColor colorWithRed:30.0f / 255.0f green:32.0f / 255.0f blue:36.0f / 255.0f alpha:1.0];
};

//Team Color
+ (UIColor *)tb_grapeColor {
    return [UIColor colorWithRed:136.0f / 255.0f green:50.0f / 255.0f blue:151.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_blueberryColor {
    return [UIColor colorWithRed:92.0f / 255.0f green:107.0f / 255.0f blue:192.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_oceanColor {
    return [UIColor colorWithRed:25.0f / 255.0f green:118.0f / 255.0f blue:210.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_mintColor {
    return [UIColor colorWithRed:0.0f / 255.0f green:150.0f / 255.0f blue:136.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_teaColor {
    return [UIColor colorWithRed:57.0f / 255.0f green:153.0f / 255.0f blue:99.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_inkColor {
    return [UIColor colorWithRed:66.0f / 255.0f green:66.0f / 255.0f blue:66.0f / 255.0f alpha:1.0];
}

//New Color 
+ (UIColor *)tb_indigoColor {
    return [UIColor colorWithRed:121.0f / 255.0f green:134.0f / 255.0f blue:203.0f / 255.0f alpha:1.0];
}

//Warning color
+ (UIColor *)tb_warningColor {
    return [UIColor colorWithRed:1 green:185/255.f blue:9/255.f alpha:1];
}

//Room random color
+ (UIColor *)tb_roomRandomColor {
    int num = (random() % 6);
    switch (num) {
        case 0:
            return [UIColor tb_purpleColor];
            break;
        case 1:
            return [UIColor tb_indigoColor];
            break;
        case 2:
            return [UIColor tb_blueColor];
            break;
        case 3:
            return [UIColor tb_cyanColor];
            break;
        case 4:
            return [UIColor tb_grassColor];
            break;
        case 5:
            return [UIColor tb_yellowColor];
            break;
            
        default:
            return [UIColor tb_purpleColor];
            break;
    }
}

//.doc
+ (UIColor *)tb_docColor {
    return [UIColor jl_redColor];
}

+ (UIColor *)tb_lightDocColor {
   return [[UIColor tb_docColor] colorWithAlphaComponent:0.24];
}

//doc color with alpha
+ (UIColor *)tb_docColorwithAlpha:(CGFloat)alpha {
    return [[UIColor tb_docColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)tb_darkBlueColor {
    return [UIColor colorWithRed:58.0f / 255.0f green:96.0f/255.0f blue:253.0f/255.0f alpha:1.0];
}

+ (UIColor *)tb_defaultColor {
    return [UIColor jl_redColor];
}

//.ppt
+ (UIColor *)tb_redorangeColor {
    return [UIColor colorWithRed:255.0f / 255.0f green:87.0f / 255.0f blue:34.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_yellowColor {
    return [UIColor colorWithRed:212.0f / 255.0f green:225.0f / 255.0f blue:87.0f / 255.0f alpha:1.0];
}

// .xls
+ (UIColor *)tb_grassColor {
    return [UIColor colorWithRed:156.0f / 255.0f green:204.0f / 255.0f blue:101.0f / 255.0f alpha:1.0];
}

// .rar
+ (UIColor *)tb_purpleColor {
    return [UIColor colorWithRed:149.0f / 255.0f green:117.0f / 255.0f blue:205.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_grayColor {
    return [UIColor colorWithRed:158.0f / 255.0f green:158.0f / 255.0f blue:158.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_greenColor {
    return [UIColor colorWithRed:37.0f / 255.0f green:155.0f / 255.0f blue:36.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_blueColor {
    return [UIColor colorWithRed:79.0f / 255.0f green:195.0f / 255.0f blue:247.0f / 255.0f alpha:1.0];
}

//.pdf
+ (UIColor *)tb_redColor {
    return [UIColor colorWithRed:255.0f / 255.0f green:112.0f / 255.0f blue:67.0f / 255.0f alpha:1.0];
}

//.psd  #00bcd4
+ (UIColor *)tb_lightBlueColor {
    return [UIColor colorWithRed:0.0f / 255.0f green:188.0f / 255.0f blue:212.0f / 255.0f alpha:1.0];
}


+ (UIColor *)tb_orangeColor {
    return [UIColor colorWithRed:255.0f / 255.0f green:185.0f / 255.0f blue:9.0f / 255.0f alpha:1.0];
}

//
+ (UIColor *)tb_cyanColor {
    return [UIColor colorWithRed:77.0f / 255.0f green:182.0f / 255.0f blue:172.0f / 255.0f alpha:1.0];
}

//.ai
+ (UIColor *)tb_brownColor {
    return [UIColor colorWithRed:121.0f / 255.0f green:85.0f / 255.0f blue:72.0f / 255.0f alpha:1.0];
}

//.ind
+ (UIColor *)tb_pinkColor {
    return [UIColor colorWithRed:255.0f / 255.0f green:64.0f / 255.0f blue:129.0f / 255.0f alpha:1.0];
}

//other file type color
+ (UIColor *)tb_otherFileColor {
    return [UIColor colorWithRed:56.0f/255.0f green:56.0f/255.0f blue:56.0f/255.0f alpha:1.0];
}

+ (UIColor *)tb_iOS7BlueColor {
    return [UIColor colorWithRed:0.0 green:122.0f / 255.0f blue:1.0 alpha:1.0];
}



// Text Colors

+ (UIColor *)tb_textGray {
    return [UIColor colorWithWhite:0.50 alpha:1];
}

+ (UIColor *)tb_subTextColor {
    return [UIColor colorWithRed:166.0/255.0 green:166.0/255.0  blue:166.0/255.0  alpha:1.0];
}

+ (UIColor *)tb_customGrayColor
{
    return [UIColor colorWithRed:84.0/255.0 green:84.0/255.0  blue:84.0/255.0  alpha:1.0];
}

+ (UIColor *)tb_tableHeaderGrayColor
{
    return [UIColor colorWithRed:128.0/255.0 green:128.0/255.0  blue:128.0/255.0  alpha:1.0];
}

// Border Colors

+ (UIColor *)tb_borderColor {
    //return [UIColor colorWithWhite:0.70f alpha:1.0f];
    return [UIColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:216.0f/255.0f alpha:1.0];
}

+ (UIColor *)tb_imageBorderColor {
    return [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0];
}

//others
+ (UIColor *)tb_searchBarColor {
    return [UIColor colorWithRed:221.0/255.0f green:221.0f/255.0f blue:221.0/255.0f alpha:1.0];
}

+ (UIColor *)tb_tableViewSeperatorColor {
    return [UIColor colorWithRed:0.0f/255.0f green:0.0f / 255.0f blue:0.0f/255.0f alpha:0.05];
}

+ (UIColor *)tb_pinedCellbackgoundColor {
    return [[UIColor lightGrayColor] colorWithAlphaComponent:0.10];
}

+ (UIColor *)tb_pinedActionColor {
    return [UIColor colorWithRed:255.0f/255.0f green:185.0f/255.0f blue:9.0f/255.0f alpha:0.05];
}

+ (UIColor *)tb_MoreActionColor {
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.05];
}

+ (UIColor *)tb_badgeBackgroudColor {
    return [UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:0.7];
}

+ (UIColor *)tb_sectionBackgroundColor {
    return [UIColor colorWithRed:247.0f / 255.0f green:247.0f / 255.0f blue:247.0f / 255.0f alpha:1.0];
}

+ (UIColor *)tb_progressTintColor {
    return [UIColor colorWithRed:0.0f/255.0f green:0.0f / 255.0f blue:0.0f/255.0f alpha:0.10];
}

//hight for link search key and so on
+ (UIColor *)tb_HighlightColor {
    UIColor *hightColor = [UIColor tb_docColor];
    if (CGColorEqualToColor(hightColor.CGColor, [UIColor tb_inkColor].CGColor) ) {
        return [UIColor tb_orangeColor];
    } else {
        return hightColor;
    }
}

+ (UIColor *)tb_shareToSearchBarcolor {
    return [UIColor colorWithRed:0.892 green:0.892 blue:0.892 alpha:1];
}

//story
+ (UIColor *)tb_storyTitleColor {
    return [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
}

+ (UIColor *)tb_storyLinkColor {
    return [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0];
}

+ (UIColor *)tb_storyLinkBlueColor {
    return [UIColor colorWithRed:78/255.0 green:182/255.0 blue:232/255.0 alpha:1.0];
}

+ (UIColor *)tb_storyDetailColor {
    return [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0];
}

+ (UIColor *)tb_storyEditorPlaceholdColor {
    return [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0];
}

+ (UIColor *)tb_storyFileBackgroundColor {
    return [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
}


@end