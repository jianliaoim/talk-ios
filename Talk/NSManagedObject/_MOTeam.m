// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOTeam.m instead.

#import "_MOTeam.h"

const struct MOTeamAttributes MOTeamAttributes = {
	.color = @"color",
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.hasUnread = @"hasUnread",
	.id = @"id",
	.inviteCode = @"inviteCode",
	.inviteURL = @"inviteURL",
	.minDate = @"minDate",
	.name = @"name",
	.nonJoinable = @"nonJoinable",
	.signCode = @"signCode",
	.source = @"source",
	.sourceId = @"sourceId",
	.unread = @"unread",
	.updatedAt = @"updatedAt",
};

const struct MOTeamRelationships MOTeamRelationships = {
	.rooms = @"rooms",
	.users = @"users",
};

@implementation MOTeamID
@end

@implementation _MOTeam

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Team";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Team" inManagedObjectContext:moc_];
}

- (MOTeamID*)objectID {
	return (MOTeamID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"hasUnreadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasUnread"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"nonJoinableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nonJoinable"];
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

@dynamic hasUnread;

- (BOOL)hasUnreadValue {
	NSNumber *result = [self hasUnread];
	return [result boolValue];
}

- (void)setHasUnreadValue:(BOOL)value_ {
	[self setHasUnread:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasUnreadValue {
	NSNumber *result = [self primitiveHasUnread];
	return [result boolValue];
}

- (void)setPrimitiveHasUnreadValue:(BOOL)value_ {
	[self setPrimitiveHasUnread:[NSNumber numberWithBool:value_]];
}

@dynamic id;

@dynamic inviteCode;

@dynamic inviteURL;

@dynamic minDate;

@dynamic name;

@dynamic nonJoinable;

- (BOOL)nonJoinableValue {
	NSNumber *result = [self nonJoinable];
	return [result boolValue];
}

- (void)setNonJoinableValue:(BOOL)value_ {
	[self setNonJoinable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNonJoinableValue {
	NSNumber *result = [self primitiveNonJoinable];
	return [result boolValue];
}

- (void)setPrimitiveNonJoinableValue:(BOOL)value_ {
	[self setPrimitiveNonJoinable:[NSNumber numberWithBool:value_]];
}

@dynamic signCode;

@dynamic source;

@dynamic sourceId;

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

@dynamic rooms;

- (NSMutableSet*)roomsSet {
	[self willAccessValueForKey:@"rooms"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"rooms"];

	[self didAccessValueForKey:@"rooms"];
	return result;
}

@dynamic users;

- (NSMutableSet*)usersSet {
	[self willAccessValueForKey:@"users"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"users"];

	[self didAccessValueForKey:@"users"];
	return result;
}

@end

