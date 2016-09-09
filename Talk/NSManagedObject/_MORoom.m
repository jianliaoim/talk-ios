// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MORoom.m instead.

#import "_MORoom.h"

const struct MORoomAttributes MORoomAttributes = {
	.color = @"color",
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.id = @"id",
	.isArchived = @"isArchived",
	.isGeneral = @"isGeneral",
	.isMute = @"isMute",
	.isPrivate = @"isPrivate",
	.isQuit = @"isQuit",
	.pinnedAt = @"pinnedAt",
	.purpose = @"purpose",
	.teamID = @"teamID",
	.topic = @"topic",
	.unread = @"unread",
	.updatedAt = @"updatedAt",
};

const struct MORoomRelationships MORoomRelationships = {
	.members = @"members",
	.teams = @"teams",
};

@implementation MORoomID
@end

@implementation _MORoom

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Room" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Room";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Room" inManagedObjectContext:moc_];
}

- (MORoomID*)objectID {
	return (MORoomID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isArchivedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isArchived"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isGeneralValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isGeneral"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isMuteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMute"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPrivateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPrivate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isQuitValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isQuit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"unreadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unread"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic color;

@dynamic createdAt;

@dynamic creatorID;

@dynamic id;

@dynamic isArchived;

- (BOOL)isArchivedValue {
	NSNumber *result = [self isArchived];
	return [result boolValue];
}

- (void)setIsArchivedValue:(BOOL)value_ {
	[self setIsArchived:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsArchivedValue {
	NSNumber *result = [self primitiveIsArchived];
	return [result boolValue];
}

- (void)setPrimitiveIsArchivedValue:(BOOL)value_ {
	[self setPrimitiveIsArchived:[NSNumber numberWithBool:value_]];
}

@dynamic isGeneral;

- (BOOL)isGeneralValue {
	NSNumber *result = [self isGeneral];
	return [result boolValue];
}

- (void)setIsGeneralValue:(BOOL)value_ {
	[self setIsGeneral:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsGeneralValue {
	NSNumber *result = [self primitiveIsGeneral];
	return [result boolValue];
}

- (void)setPrimitiveIsGeneralValue:(BOOL)value_ {
	[self setPrimitiveIsGeneral:[NSNumber numberWithBool:value_]];
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

@dynamic isPrivate;

- (BOOL)isPrivateValue {
	NSNumber *result = [self isPrivate];
	return [result boolValue];
}

- (void)setIsPrivateValue:(BOOL)value_ {
	[self setIsPrivate:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPrivateValue {
	NSNumber *result = [self primitiveIsPrivate];
	return [result boolValue];
}

- (void)setPrimitiveIsPrivateValue:(BOOL)value_ {
	[self setPrimitiveIsPrivate:[NSNumber numberWithBool:value_]];
}

@dynamic isQuit;

- (BOOL)isQuitValue {
	NSNumber *result = [self isQuit];
	return [result boolValue];
}

- (void)setIsQuitValue:(BOOL)value_ {
	[self setIsQuit:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsQuitValue {
	NSNumber *result = [self primitiveIsQuit];
	return [result boolValue];
}

- (void)setPrimitiveIsQuitValue:(BOOL)value_ {
	[self setPrimitiveIsQuit:[NSNumber numberWithBool:value_]];
}

@dynamic pinnedAt;

@dynamic purpose;

@dynamic teamID;

@dynamic topic;

@dynamic unread;

- (int64_t)unreadValue {
	NSNumber *result = [self unread];
	return [result longLongValue];
}

- (void)setUnreadValue:(int64_t)value_ {
	[self setUnread:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveUnreadValue {
	NSNumber *result = [self primitiveUnread];
	return [result longLongValue];
}

- (void)setPrimitiveUnreadValue:(int64_t)value_ {
	[self setPrimitiveUnread:[NSNumber numberWithLongLong:value_]];
}

@dynamic updatedAt;

@dynamic members;

- (NSMutableSet*)membersSet {
	[self willAccessValueForKey:@"members"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"members"];

	[self didAccessValueForKey:@"members"];
	return result;
}

@dynamic teams;

@end

