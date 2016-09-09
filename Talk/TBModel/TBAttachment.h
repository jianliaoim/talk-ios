//
//  TBAttachment.h
//  
//
//  Created by Suric on 15/8/4.
//
//

#import "TBModelObject.h"
#import "TBMessage.h"
@interface TBAttachment : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) TBMessage *message;

@end
