// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOStory.m instead.

#import "_MOStory.h"

const struct MOStoryAttributes MOStoryAttributes = {
	.category = @"category",
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.data = @"data",
	.id = @"id",
	.isPublic = @"isPublic",
	.members = @"members",
	.teamID = @"teamID",
	.title = @"title",
	.updatedAt = @"updatedAt",
};

const struct MOStoryRelationships MOStoryRelationships = {
	.messages = @"messages",
	.notification = @"notification",
};

@implementation MOStoryID
@end

@implementation _MOStory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Story";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Story" inManagedObjectContext:moc_];
}

- (MOStoryID*)objectID {
	return (MOStoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isPublicValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPublic"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic category;

@dynamic createdAt;

@dynamic creatorID;

@dynamic data;

@dynamic id;

@dynamic isPublic;

- (BOOL)isPublicValue {
	NSNumber *result = [self isPublic];
	return [result boolValue];
}

- (void)setIsPublicValue:(BOOL)value_ {
	[self setIsPublic:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPublicValue {
	NSNumber *result = [self primitiveIsPublic];
	return [result boolValue];
}

- (void)setPrimitiveIsPublicValue:(BOOL)value_ {
	[self setPrimitiveIsPublic:[NSNumber numberWithBool:value_]];
}

@dynamic members;

@dynamic teamID;

@dynamic title;

@dynamic updatedAt;

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic notification;

@end

