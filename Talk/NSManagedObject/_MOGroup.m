// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOGroup.m instead.

#import "_MOGroup.h"

const struct MOGroupAttributes MOGroupAttributes = {
	.createdAt = @"createdAt",
	.creatorId = @"creatorId",
	.id = @"id",
	.members = @"members",
	.name = @"name",
	.teamId = @"teamId",
	.updatedAt = @"updatedAt",
};

@implementation MOGroupID
@end

@implementation _MOGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Group";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Group" inManagedObjectContext:moc_];
}

- (MOGroupID*)objectID {
	return (MOGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic createdAt;

@dynamic creatorId;

@dynamic id;

@dynamic members;

@dynamic name;

@dynamic teamId;

@dynamic updatedAt;

@end

