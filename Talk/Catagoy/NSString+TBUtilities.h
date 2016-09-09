//
//  NSString+TBUtilities.h
//  Talk
//
//  Created by 王卫 on 15/11/24.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TBUtilities)

- (BOOL)isValidUrl;
- (NSString *)getTalkTeamImageName;
- (BOOL)isQQEmail;

@end
