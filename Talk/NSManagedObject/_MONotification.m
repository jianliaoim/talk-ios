// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MONotification.m instead.

#import "_MONotification.h"

const struct MONotificationAttributes MONotificationAttributes = {
	.authorName = @"authorName",
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.creatorName = @"creatorName",
	.emitterID = @"emitterID",
	.id = @"id",
	.isHidden = @"isHidden",
	.isMute = @"isMute",
	.isPinned = @"isPinned",
	.latestReadMessageID = @"latestReadMessageID",
	.sendStatus = @"sendStatus",
	.target = @"target",
	.targetID = @"targetID",
	.teamID = @"teamID",
	.text = @"text",
	.type = @"type",
	.unreadNum = @"unreadNum",
	.updatedAt = @"updatedAt",
};

const struct MONotificationRelationships MONotificationRelationships = {
	.draft = @"draft",
	.story = @"story",
};

@implementation MONotificationID
@end

@implementation _MONotification

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Notification";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:moc_];
}

- (MONotificationID*)objectID {
	return (MONotificationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isHiddenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isHidden"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isMuteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMute"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPinnedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPinned"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sendStatusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sendStatus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"unreadNumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unreadNum"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic authorName;

@dynamic createdAt;

@dynamic creatorID;

@dynamic creatorName;

@dynamic emitterID;

@dynamic id;

@dynamic isHidden;

- (BOOL)isHiddenValue {
	NSNumber *result = [self isHidden];
	return [result boolValue];
}

- (void)setIsHiddenValue:(BOOL)value_ {
	[self setIsHidden:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsHiddenValue {
	NSNumber *result = [self primitiveIsHidden];
	return [result boolValue];
}

- (void)setPrimitiveIsHiddenValue:(BOOL)value_ {
	[self setPrimitiveIsHidden:[NSNumber numberWithBool:value_]];
}

@dynamic isMute;

- (BOOL)isMuteValue {
	NSNumber *result = [self isMute];
	return [result boolValue];
}

- (void)setIsMuteValue:(BOOL)value_ {
	[self setIsMute:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsMuteValue {
	NSNumber *result = [self primitiveIsMute];
	return [result boolValue];
}

- (void)setPrimitiveIsMuteValue:(BOOL)value_ {
	[self setPrimitiveIsMute:[NSNumber numberWithBool:value_]];
}

@dynamic isPinned;

- (BOOL)isPinnedValue {
	NSNumber *result = [self isPinned];
	return [result boolValue];
}

- (void)setIsPinnedValue:(BOOL)value_ {
	[self setIsPinned:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPinnedValue {
	NSNumber *result = [self primitiveIsPinned];
	return [result boolValue];
}

- (void)setPrimitiveIsPinnedValue:(BOOL)value_ {
	[self setPrimitiveIsPinned:[NSNumber numberWithBool:value_]];
}

@dynamic latestReadMessageID;

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

@dynamic target;

@dynamic targetID;

@dynamic teamID;

@dynamic text;

@dynamic type;

@dynamic unreadNum;

- (int64_t)unreadNumValue {
	NSNumber *result = [self unreadNum];
	return [result longLongValue];
}

- (void)setUnreadNumValue:(int64_t)value_ {
	[self setUnreadNum:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveUnreadNumValue {
	NSNumber *result = [self primitiveUnreadNum];
	return [result longLongValue];
}

- (void)setPrimitiveUnreadNumValue:(int64_t)value_ {
	[self setPrimitiveUnreadNum:[NSNumber numberWithLongLong:value_]];
}

@dynamic updatedAt;

@dynamic draft;

@dynamic story;

@end

