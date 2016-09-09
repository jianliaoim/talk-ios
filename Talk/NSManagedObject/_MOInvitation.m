// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOInvitation.m instead.

#import "_MOInvitation.h"

const struct MOInvitationAttributes MOInvitationAttributes = {
	.email = @"email",
	.id = @"id",
	.key = @"key",
	.mobile = @"mobile",
	.name = @"name",
	.teamId = @"teamId",
};

@implementation MOInvitationID
@end

@implementation _MOInvitation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Invitation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Invitation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:moc_];
}

- (MOInvitationID*)objectID {
	return (MOInvitationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic email;

@dynamic id;

@dynamic key;

@dynamic mobile;

@dynamic name;

@dynamic teamId;

@end

