// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOHidenMessage.m instead.

#import "_MOHidenMessage.h"

const struct MOHidenMessageAttributes MOHidenMessageAttributes = {
	.messageID = @"messageID",
	.targetID = @"targetID",
	.teamID = @"teamID",
};

@implementation MOHidenMessageID
@end

@implementation _MOHidenMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"HidenMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"HidenMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"HidenMessage" inManagedObjectContext:moc_];
}

- (MOHidenMessageID*)objectID {
	return (MOHidenMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic messageID;

@dynamic targetID;

@dynamic teamID;

@end

