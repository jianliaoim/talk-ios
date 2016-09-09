//
//  TBInvitation.h
//  Talk
//
//  Created by 史丹青 on 9/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBInvitation : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *teamId;
@property (nonatomic, copy) NSString *email;

@end
