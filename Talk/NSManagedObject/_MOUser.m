// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOUser.m instead.

#import "_MOUser.h"

const struct MOUserAttributes MOUserAttributes = {
	.alias = @"alias",
	.avatarURL = @"avatarURL",
	.createdAt = @"createdAt",
	.email = @"email",
	.hideMobile = @"hideMobile",
	.id = @"id",
	.isGuest = @"isGuest",
	.isMute = @"isMute",
	.isQuit = @"isQuit",
	.isRobot = @"isRobot",
	.mobile = @"mobile",
	.name = @"name",
	.phoneForLogin = @"phoneForLogin",
	.phoneNumber = @"phoneNumber",
	.pinyin = @"pinyin",
	.role = @"role",
	.service = @"service",
	.sourceId = @"sourceId",
	.unread = @"unread",
	.updatedAt = @"updatedAt",
	.userID = @"userID",
};

const struct MOUserRelationships MOUserRelationships = {
	.messages = @"messages",
	.rooms = @"rooms",
	.teams = @"teams",
};

@implementation MOUserID
@end

@implementation _MOUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (MOUserID*)objectID {
	return (MOUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"hideMobileValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hideMobile"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isGuestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isGuest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isMuteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMute"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isQuitValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isQuit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isRobotValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isRobot"];
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

@dynamic alias;

@dynamic avatarURL;

@dynamic createdAt;

@dynamic email;

@dynamic hideMobile;

- (BOOL)hideMobileValue {
	NSNumber *result = [self hideMobile];
	return [result boolValue];
}

- (void)setHideMobileValue:(BOOL)value_ {
	[self setHideMobile:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHideMobileValue {
	NSNumber *result = [self primitiveHideMobile];
	return [result boolValue];
}

- (void)setPrimitiveHideMobileValue:(BOOL)value_ {
	[self setPrimitiveHideMobile:[NSNumber numberWithBool:value_]];
}

@dynamic id;

@dynamic isGuest;

- (BOOL)isGuestValue {
	NSNumber *result = [self isGuest];
	return [result boolValue];
}

- (void)setIsGuestValue:(BOOL)value_ {
	[self setIsGuest:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsGuestValue {
	NSNumber *result = [self primitiveIsGuest];
	return [result boolValue];
}

- (void)setPrimitiveIsGuestValue:(BOOL)value_ {
	[self setPrimitiveIsGuest:[NSNumber numberWithBool:value_]];
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

@dynamic isRobot;

- (BOOL)isRobotValue {
	NSNumber *result = [self isRobot];
	return [result boolValue];
}

- (void)setIsRobotValue:(BOOL)value_ {
	[self setIsRobot:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsRobotValue {
	NSNumber *result = [self primitiveIsRobot];
	return [result boolValue];
}

- (void)setPrimitiveIsRobotValue:(BOOL)value_ {
	[self setPrimitiveIsRobot:[NSNumber numberWithBool:value_]];
}

@dynamic mobile;

@dynamic name;

@dynamic phoneForLogin;

@dynamic phoneNumber;

@dynamic pinyin;

@dynamic role;

@dynamic service;

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

@dynamic userID;

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic rooms;

- (NSMutableSet*)roomsSet {
	[self willAccessValueForKey:@"rooms"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"rooms"];

	[self didAccessValueForKey:@"rooms"];
	return result;
}

@dynamic teams;

@end

