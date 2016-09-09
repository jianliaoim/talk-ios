#import "MOMessage.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface MOMessage ()

// Private interface goes here.

@end

@implementation MOMessage

// Custom logic goes here.
+ (void)removeOneTeamMessagesWithTeamId:(NSString *)teamId {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate *allTeamMessagePredicate = [NSPredicate predicateWithFormat:@"teamID = %@", teamId];
        [MOMessage MR_deleteAllMatchingPredicate:allTeamMessagePredicate inContext:localContext];
    }];
}

@end
