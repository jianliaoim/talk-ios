//
//  TBTag.h
//  Talk
//
//  Created by 史丹青 on 7/15/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBTag : TBModelObject

@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) BOOL isSelected;

@end
