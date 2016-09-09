//
//  JLSpotlightHelper.m
//  Talk
//
//  Created by 史丹青 on 11/25/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "JLSpotlightHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "constants.h"
#import "CoreData+MagicalRecord.h"
#import "Mantle.h"
#import "MOUser.h"
#import "TBUser.h"

static NSString * const domainIdentifier = @"com.jianliao.user";

@implementation JLSpotlightHelper

#pragma mark - Public
+ (void)indexAllMembersInCurrentTeam {
    NSArray *moUserArray = [MOUser findAllInCurrentTeamWithContainRobot:NO];
    NSMutableArray *searchItems = [[NSMutableArray alloc] init];
    for (MOUser *moUser in moUserArray) {
        if ([moUser.id isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserKey]]) {
            continue;
        }
        TBUser *tbUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:moUser error:nil];
        CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:tbUser.id domainIdentifier:domainIdentifier attributeSet:[self userAttributeSet:tbUser]];
        [searchItems addObject:searchableItem];
    }
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchItems completionHandler:nil];
};

+ (void)refreshIndexInCurrentTeam {
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        [self indexAllMembersInCurrentTeam];
    }];
};

#pragma mark - Private
+ (CSSearchableItemAttributeSet *)userAttributeSet:(TBUser *)tbUser {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(__bridge NSString *)kUTTypeContact];
    attributeSet.thumbnailData = UIImageJPEGRepresentation([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:tbUser.avatarURL.absoluteString], 0.9);
    attributeSet.title = tbUser.name;
    NSString *description = @"";
    if (tbUser.phoneForLogin) {
        attributeSet.phoneNumbers = @[tbUser.phoneForLogin];
        description = [description stringByAppendingString:tbUser.phoneForLogin];
        description = [description stringByAppendingString:@"\n"];
    }
    if (tbUser.email) {
        attributeSet.emailAddresses = @[tbUser.email];
        description = [description stringByAppendingString:tbUser.email];
        description = [description stringByAppendingString:@"\n"];
    }
    attributeSet.contentDescription = description;
    attributeSet.keywords = @[@"简聊", @"jianliao", @"jl", @"teambition",@"talk"];
    attributeSet.supportsPhoneCall = @1;
    attributeSet.supportsNavigation = @1;
    
    attributeSet.relatedUniqueIdentifier = tbUser.id;
    
    return attributeSet;
};

@end
