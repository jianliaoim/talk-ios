// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOMessage.h instead.

#import <CoreData/CoreData.h>

extern const struct MOMessageAttributes {
	__unsafe_unretained NSString *authorAvatarUrl;
	__unsafe_unretained NSString *authorName;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *captureImageUrlStr;
	__unsafe_unretained NSString *cellHeight;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *displayMode;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *highlight;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isSend;
	__unsafe_unretained NSString *isSystem;
	__unsafe_unretained NSString *isUnread;
	__unsafe_unretained NSString *mentions;
	__unsafe_unretained NSString *messageStr;
	__unsafe_unretained NSString *numbersOfRows;
	__unsafe_unretained NSString *originMessageId;
	__unsafe_unretained NSString *receiptors;
	__unsafe_unretained NSString *roomID;
	__unsafe_unretained NSString *searchCellHeight;
	__unsafe_unretained NSString *sendImage;
	__unsafe_unretained NSString *sendImageCategory;
	__unsafe_unretained NSString *sendImageHeight;
	__unsafe_unretained NSString *sendImageWidth;
	__unsafe_unretained NSString *sendStatus;
	__unsafe_unretained NSString *storyID;
	__unsafe_unretained NSString *tags;
	__unsafe_unretained NSString *teamID;
	__unsafe_unretained NSString *toID;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *uuid;
	__unsafe_unretained NSString *voiceLocalAMRPath;
} MOMessageAttributes;

extern const struct MOMessageRelationships {
	__unsafe_unretained NSString *attachments;
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *story;
} MOMessageRelationships;

@class MOAttachment;
@class MOUser;
@class MOStory;

@class NSObject;

@class NSObject;

@class NSObject;

@class NSObject;

@class NSObject;

@interface MOMessageID : NSManagedObjectID {}
@end

@interface _MOMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOMessageID* objectID;

@property (nonatomic, strong) NSString* authorAvatarUrl;

//- (BOOL)validateAuthorAvatarUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* authorName;

//- (BOOL)validateAuthorName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* body;

//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* captureImageUrlStr;

//- (BOOL)validateCaptureImageUrlStr:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* cellHeight;

@property (atomic) float cellHeightValue;
- (float)cellHeightValue;
- (void)setCellHeightValue:(float)value_;

//- (BOOL)validateCellHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* displayMode;

//- (BOOL)validateDisplayMode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* duration;

@property (atomic) float durationValue;
- (float)durationValue;
- (void)setDurationValue:(float)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id highlight;

//- (BOOL)validateHighlight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isSend;

@property (atomic) BOOL isSendValue;
- (BOOL)isSendValue;
- (void)setIsSendValue:(BOOL)value_;

//- (BOOL)validateIsSend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isSystem;

@property (atomic) BOOL isSystemValue;
- (BOOL)isSystemValue;
- (void)setIsSystemValue:(BOOL)value_;

//- (BOOL)validateIsSystem:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isUnread;

@property (atomic) BOOL isUnreadValue;
- (BOOL)isUnreadValue;
- (void)setIsUnreadValue:(BOOL)value_;

//- (BOOL)validateIsUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id mentions;

//- (BOOL)validateMentions:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* messageStr;

//- (BOOL)validateMessageStr:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* numbersOfRows;

@property (atomic) int16_t numbersOfRowsValue;
- (int16_t)numbersOfRowsValue;
- (void)setNumbersOfRowsValue:(int16_t)value_;

//- (BOOL)validateNumbersOfRows:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* originMessageId;

//- (BOOL)validateOriginMessageId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id receiptors;

//- (BOOL)validateReceiptors:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* roomID;

//- (BOOL)validateRoomID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* searchCellHeight;

@property (atomic) float searchCellHeightValue;
- (float)searchCellHeightValue;
- (void)setSearchCellHeightValue:(float)value_;

//- (BOOL)validateSearchCellHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id sendImage;

//- (BOOL)validateSendImage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sendImageCategory;

//- (BOOL)validateSendImageCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sendImageHeight;

@property (atomic) float sendImageHeightValue;
- (float)sendImageHeightValue;
- (void)setSendImageHeightValue:(float)value_;

//- (BOOL)validateSendImageHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sendImageWidth;

@property (atomic) float sendImageWidthValue;
- (float)sendImageWidthValue;
- (void)setSendImageWidthValue:(float)value_;

//- (BOOL)validateSendImageWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sendStatus;

@property (atomic) int16_t sendStatusValue;
- (int16_t)sendStatusValue;
- (void)setSendStatusValue:(int16_t)value_;

//- (BOOL)validateSendStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* storyID;

//- (BOOL)validateStoryID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id tags;

//- (BOOL)validateTags:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* toID;

//- (BOOL)validateToID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uuid;

//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* voiceLocalAMRPath;

//- (BOOL)validateVoiceLocalAMRPath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *attachments;

- (NSMutableOrderedSet*)attachmentsSet;

@property (nonatomic, strong) MOUser *creator;

//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MOStory *story;

//- (BOOL)validateStory:(id*)value_ error:(NSError**)error_;

@end

@interface _MOMessage (AttachmentsCoreDataGeneratedAccessors)
- (void)addAttachments:(NSOrderedSet*)value_;
- (void)removeAttachments:(NSOrderedSet*)value_;
- (void)addAttachmentsObject:(MOAttachment*)value_;
- (void)removeAttachmentsObject:(MOAttachment*)value_;

- (void)insertObject:(MOAttachment*)value inAttachmentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAttachmentsAtIndex:(NSUInteger)idx;
- (void)insertAttachments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAttachmentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAttachmentsAtIndex:(NSUInteger)idx withObject:(MOAttachment*)value;
- (void)replaceAttachmentsAtIndexes:(NSIndexSet *)indexes withAttachments:(NSArray *)values;

@end

@interface _MOMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthorAvatarUrl;
- (void)setPrimitiveAuthorAvatarUrl:(NSString*)value;

- (NSString*)primitiveAuthorName;
- (void)setPrimitiveAuthorName:(NSString*)value;

- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;

- (NSString*)primitiveCaptureImageUrlStr;
- (void)setPrimitiveCaptureImageUrlStr:(NSString*)value;

- (NSNumber*)primitiveCellHeight;
- (void)setPrimitiveCellHeight:(NSNumber*)value;

- (float)primitiveCellHeightValue;
- (void)setPrimitiveCellHeightValue:(float)value_;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (NSString*)primitiveDisplayMode;
- (void)setPrimitiveDisplayMode:(NSString*)value;

- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (float)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(float)value_;

- (id)primitiveHighlight;
- (void)setPrimitiveHighlight:(id)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsSend;
- (void)setPrimitiveIsSend:(NSNumber*)value;

- (BOOL)primitiveIsSendValue;
- (void)setPrimitiveIsSendValue:(BOOL)value_;

- (NSNumber*)primitiveIsSystem;
- (void)setPrimitiveIsSystem:(NSNumber*)value;

- (BOOL)primitiveIsSystemValue;
- (void)setPrimitiveIsSystemValue:(BOOL)value_;

- (NSNumber*)primitiveIsUnread;
- (void)setPrimitiveIsUnread:(NSNumber*)value;

- (BOOL)primitiveIsUnreadValue;
- (void)setPrimitiveIsUnreadValue:(BOOL)value_;

- (id)primitiveMentions;
- (void)setPrimitiveMentions:(id)value;

- (NSString*)primitiveMessageStr;
- (void)setPrimitiveMessageStr:(NSString*)value;

- (NSNumber*)primitiveNumbersOfRows;
- (void)setPrimitiveNumbersOfRows:(NSNumber*)value;

- (int16_t)primitiveNumbersOfRowsValue;
- (void)setPrimitiveNumbersOfRowsValue:(int16_t)value_;

- (NSString*)primitiveOriginMessageId;
- (void)setPrimitiveOriginMessageId:(NSString*)value;

- (id)primitiveReceiptors;
- (void)setPrimitiveReceiptors:(id)value;

- (NSString*)primitiveRoomID;
- (void)setPrimitiveRoomID:(NSString*)value;

- (NSNumber*)primitiveSearchCellHeight;
- (void)setPrimitiveSearchCellHeight:(NSNumber*)value;

- (float)primitiveSearchCellHeightValue;
- (void)setPrimitiveSearchCellHeightValue:(float)value_;

- (id)primitiveSendImage;
- (void)setPrimitiveSendImage:(id)value;

- (NSString*)primitiveSendImageCategory;
- (void)setPrimitiveSendImageCategory:(NSString*)value;

- (NSNumber*)primitiveSendImageHeight;
- (void)setPrimitiveSendImageHeight:(NSNumber*)value;

- (float)primitiveSendImageHeightValue;
- (void)setPrimitiveSendImageHeightValue:(float)value_;

- (NSNumber*)primitiveSendImageWidth;
- (void)setPrimitiveSendImageWidth:(NSNumber*)value;

- (float)primitiveSendImageWidthValue;
- (void)setPrimitiveSendImageWidthValue:(float)value_;

- (NSNumber*)primitiveSendStatus;
- (void)setPrimitiveSendStatus:(NSNumber*)value;

- (int16_t)primitiveSendStatusValue;
- (void)setPrimitiveSendStatusValue:(int16_t)value_;

- (NSString*)primitiveStoryID;
- (void)setPrimitiveStoryID:(NSString*)value;

- (id)primitiveTags;
- (void)setPrimitiveTags:(id)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

- (NSString*)primitiveToID;
- (void)setPrimitiveToID:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;

- (NSString*)primitiveVoiceLocalAMRPath;
- (void)setPrimitiveVoiceLocalAMRPath:(NSString*)value;

- (NSMutableOrderedSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableOrderedSet*)value;

- (MOUser*)primitiveCreator;
- (void)setPrimitiveCreator:(MOUser*)value;

- (MOStory*)primitiveStory;
- (void)setPrimitiveStory:(MOStory*)value;

@end
