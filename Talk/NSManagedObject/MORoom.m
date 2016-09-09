#import "MORoom.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface MORoom ()

// Private interface goes here.

@end

@implementation MORoom

// Custom logic goes here.
+ (NSArray *)findAllJoinedRoomInCurrentTeam {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    NSPredicate *joinedTopicFilter = [NSPredicate predicateWithFormat:@"isArchived = NO AND isQuit = NO AND teams.id = %@", currentTeamID];
    NSArray *allJoinedRoomArray = [MORoom MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:joinedTopicFilter];
    return allJoinedRoomArray;
}

@end
