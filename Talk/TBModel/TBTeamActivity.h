//
//  TBTeamActivity.h
//  Talk
//
//  Created by Suric on 16/2/15.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TBModelObject.h"
#import "TBUser.h"

@interface TBTeamActivity : TBModelObject
@property (nonatomic, copy) NSString *team;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *activityTitle;
@property (nonatomic, copy) NSString *activityDetail;
@property (nonatomic, copy) NSString *thumbnailURLString;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGSize imageSize;
@property (nonatomic, strong) NSDictionary *target;
@property (nonatomic, strong) TBUser *creator;
@end
