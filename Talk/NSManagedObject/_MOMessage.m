// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOMessage.m instead.

#import "_MOMessage.h"

const struct MOMessageAttributes MOMessageAttributes = {
	.authorAvatarUrl = @"authorAvatarUrl",
	.authorName = @"authorName",
	.body = @"body",
	.captureImageUrlStr = @"captureImageUrlStr",
	.cellHeight = @"cellHeight",
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.displayMode = @"displayMode",
	.duration = @"duration",
	.highlight = @"highlight",
	.id = @"id",
	.isSend = @"isSend",
	.isSystem = @"isSystem",
	.isUnread = @"isUnread",
	.mentions = @"mentions",
	.messageStr = @"messageStr",
	.numbersOfRows = @"numbersOfRows",
	.originMessageId = @"originMessageId",
	.receiptors = @"receiptors",
	.roomID = @"roomID",
	.searchCellHeight = @"searchCellHeight",
	.sendImage = @"sendImage",
	.sendImageCategory = @"sendImageCategory",
	.sendImageHeight = @"sendImageHeight",
	.sendImageWidth = @"sendImageWidth",
	.sendStatus = @"sendStatus",
	.storyID = @"storyID",
	.tags = @"tags",
	.teamID = @"teamID",
	.toID = @"toID",
	.updatedAt = @"updatedAt",
	.uuid = @"uuid",
	.voiceLocalAMRPath = @"voiceLocalAMRPath",
};

const struct MOMessageRelationships MOMessageRelationships = {
	.attachments = @"attachments",
	.creator = @"creator",
	.story = @"story",
};

@implementation MOMessageID
@end

@implementation _MOMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MOMessageID*)objectID {
	return (MOMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"cellHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cellHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isSendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isSend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isSystemValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isSystem"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isUnreadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isUnread"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numbersOfRowsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numbersOfRows"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"searchCellHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"searchCellHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sendImageHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sendImageHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sendImageWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sendImageWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sendStatusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sendStatus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic authorAvatarUrl;

@dynamic authorName;

@dynamic body;

@dynamic captureImageUrlStr;

@dynamic cellHeight;

- (float)cellHeightValue {
	NSNumber *result = [self cellHeight];
	return [result floatValue];
}

- (void)setCellHeightValue:(float)value_ {
	[self setCellHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveCellHeightValue {
	NSNumber *result = [self primitiveCellHeight];
	return [result floatValue];
}

- (void)setPrimitiveCellHeightValue:(float)value_ {
	[self setPrimitiveCellHeight:[NSNumber numberWithFloat:value_]];
}

@dynamic createdAt;

@dynamic creatorID;

@dynamic displayMode;

@dynamic duration;

- (float)durationValue {
	NSNumber *result = [self duration];
	return [result floatValue];
}

- (void)setDurationValue:(float)value_ {
	[self setDuration:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result floatValue];
}

- (void)setPrimitiveDurationValue:(float)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithFloat:value_]];
}

@dynamic highlight;

@dynamic id;

@dynamic isSend;

- (BOOL)isSendValue {
	NSNumber *result = [self isSend];
	return [result boolValue];
}

- (void)setIsSendValue:(BOOL)value_ {
	[self setIsSend:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsSendValue {
	NSNumber *result = [self primitiveIsSend];
	return [result boolValue];
}

- (void)setPrimitiveIsSendValue:(BOOL)value_ {
	[self setPrimitiveIsSend:[NSNumber numberWithBool:value_]];
}

@dynamic isSystem;

- (BOOL)isSystemValue {
	NSNumber *result = [self isSystem];
	return [result boolValue];
}

- (void)setIsSystemValue:(BOOL)value_ {
	[self setIsSystem:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsSystemValue {
	NSNumber *result = [self primitiveIsSystem];
	return [result boolValue];
}

- (void)setPrimitiveIsSystemValue:(BOOL)value_ {
	[self setPrimitiveIsSystem:[NSNumber numberWithBool:value_]];
}

@dynamic isUnread;

- (BOOL)isUnreadValue {
	NSNumber *result = [self isUnread];
	return [result boolValue];
}

- (void)setIsUnreadValue:(BOOL)value_ {
	[self setIsUnread:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsUnreadValue {
	NSNumber *result = [self primitiveIsUnread];
	return [result boolValue];
}

- (void)setPrimitiveIsUnreadValue:(BOOL)value_ {
	[self setPrimitiveIsUnread:[NSNumber numberWithBool:value_]];
}

@dynamic mentions;

@dynamic messageStr;

@dynamic numbersOfRows;

- (int16_t)numbersOfRowsValue {
	NSNumber *result = [self numbersOfRows];
	return [result shortValue];
}

- (void)setNumbersOfRowsValue:(int16_t)value_ {
	[self setNumbersOfRows:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNumbersOfRowsValue {
	NSNumber *result = [self primitiveNumbersOfRows];
	return [result shortValue];
}

- (void)setPrimitiveNumbersOfRowsValue:(int16_t)value_ {
	[self setPrimitiveNumbersOfRows:[NSNumber numberWithShort:value_]];
}

@dynamic originMessageId;

@dynamic receiptors;

@dynamic roomID;

@dynamic searchCellHeight;

- (float)searchCellHeightValue {
	NSNumber *result = [self searchCellHeight];
	return [result floatValue];
}

- (void)setSearchCellHeightValue:(float)value_ {
	[self setSearchCellHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveSearchCellHeightValue {
	NSNumber *result = [self primitiveSearchCellHeight];
	return [result floatValue];
}

- (void)setPrimitiveSearchCellHeightValue:(float)value_ {
	[self setPrimitiveSearchCellHeight:[NSNumber numberWithFloat:value_]];
}

@dynamic sendImage;

@dynamic sendImageCategory;

@dynamic sendImageHeight;

- (float)sendImageHeightValue {
	NSNumber *result = [self sendImageHeight];
	return [result floatValue];
}

- (void)setSendImageHeightValue:(float)value_ {
	[self setSendImageHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveSendImageHeightValue {
	NSNumber *result = [self primitiveSendImageHeight];
	return [result floatValue];
}

- (void)setPrimitiveSendImageHeightValue:(float)value_ {
	[self setPrimitiveSendImageHeight:[NSNumber numberWithFloat:value_]];
}

@dynamic sendImageWidth;

- (float)sendImageWidthValue {
	NSNumber *result = [self sendImageWidth];
	return [result floatValue];
}

- (void)setSendImageWidthValue:(float)value_ {
	[self setSendImageWidth:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveSendImageWidthValue {
	NSNumber *result = [self primitiveSendImageWidth];
	return [result floatValue];
}

- (void)setPrimitiveSendImageWidthValue:(float)value_ {
	[self setPrimitiveSendImageWidth:[NSNumber numberWithFloat:value_]];
}

@dynamic sendStatus;

- (int16_t)sendStatusValue {
	NSNumber *result = [self sendStatus];
	return [result shortValue];
}

- (void)setSendStatusValue:(int16_t)value_ {
	[self setSendStatus:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSendStatusValue {
	NSNumber *result = [self primitiveSendStatus];
	return [result shortValue];
}

- (void)setPrimitiveSendStatusValue:(int16_t)value_ {
	[self setPrimitiveSendStatus:[NSNumber numberWithShort:value_]];
}

@dynamic storyID;

@dynamic tags;

@dynamic teamID;

@dynamic toID;

@dynamic updatedAt;

@dynamic uuid;

@dynamic voiceLocalAMRPath;

@dynamic attachments;

- (NSMutableOrderedSet*)attachmentsSet {
	[self willAccessValueForKey:@"attachments"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"attachments"];

	[self didAccessValueForKey:@"attachments"];
	return result;
}

@dynamic creator;

@dynamic story;

@end

@implementation _MOMessage (AttachmentsCoreDataGeneratedAccessors)
- (void)addAttachments:(NSOrderedSet*)value_ {
	[self.attachmentsSet unionOrderedSet:value_];
}
- (void)removeAttachments:(NSOrderedSet*)value_ {
	[self.attachmentsSet minusOrderedSet:value_];
}
- (void)addAttachmentsObject:(MOAttachment*)value_ {
	[self.attachmentsSet addObject:value_];
}
- (void)removeAttachmentsObject:(MOAttachment*)value_ {
	[self.attachmentsSet removeObject:value_];
}
- (void)insertObject:(MOAttachment*)value inAttachmentsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"attachments"];
}
- (void)removeObjectFromAttachmentsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"attachments"];
}
- (void)insertAttachments:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"attachments"];
}
- (void)removeAttachmentsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"attachments"];
}
- (void)replaceObjectInAttachmentsAtIndex:(NSUInteger)idx withObject:(MOAttachment*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"attachments"];
}
- (void)replaceAttachmentsAtIndexes:(NSIndexSet *)indexes withAttachments:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"attachments"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self attachments]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"attachments"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"attachments"];
}
@end

