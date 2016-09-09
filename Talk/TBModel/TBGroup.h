//
//  TBGroup.h
//  Talk
//
//  Created by 王卫 on 15/12/22.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBGroup : TBModelObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *teamId;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSArray *members;

@end
