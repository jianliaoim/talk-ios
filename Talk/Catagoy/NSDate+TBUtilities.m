//
// Created by Shire on 10/21/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import <MTDates/NSDate+MTDates.h>
#import "NSDate+TBUtilities.h"


@implementation NSDate (TBUtilities)

- (NSString *)tb_stringWithShortFormat {
    NSDate *date = [NSDate date];

    if ([self mt_isWithinSameDay:date]) {
        return [self mt_stringFromDateWithHourAndMinuteFormat:MTDateHourFormat12Hour];
    } else if ([self mt_year] == [date mt_year]) {
        return [self mt_stringFromDateWithFormat:@"MMM d" localized:YES];
    }
    return [self mt_stringFromDateWithFormat:@"yyyy MMM d" localized:YES];
}

- (NSString *)tb_stringWithShortDate {
    NSDate *date = [NSDate date];

    if ([self mt_year] == [date mt_year]) {
        return [self mt_stringFromDateWithFormat:@"MMM d" localized:YES];
    }
    return [self mt_stringFromDateWithFormat:@"yyyy MMM d" localized:YES];
}

-(NSString *)tb_timeAgo
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if(deltaSeconds < 60)
    {
        return NSLocalizedString(@"Just now",@"Just now" );
    }
    else if([self isToday])
    {
        [formatter setDateFormat:@"HH:mm"];
        return [formatter stringFromDate:self];
    }
    else if ([self isThisYear])
    {
        [formatter setDateFormat:NSLocalizedString(@"Short Date Formatter", @"Short Date Formatter")];
        return [formatter stringFromDate:self];
    }
    else
    {
        [formatter setDateFormat:NSLocalizedString(@"Year Formatter", @"Year Formatter")];
        return [formatter stringFromDate:self];
    }
}


- (BOOL)isToday {
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components :unit fromDate :[ NSDate date ]];
    NSDateComponents *selfCmps = [calendar components :unit fromDate :self];
    return (selfCmps. year == nowCmps. year ) && (selfCmps. month == nowCmps. month ) && (selfCmps. day == nowCmps. day);
}

- ( NSDate *)dateWithYMD {
    NSDateFormatter *fmt = [[ NSDateFormatter alloc]init];
    fmt. dateFormat = @"yyyy-MM-dd" ;
    NSString *selfStr = [fmt stringFromDate : self];
    return [fmt dateFromString :selfStr];
}

- (BOOL)isThisYear {
    NSCalendar *cale = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    NSDateComponents  *nowCmps = [cale  components: unit fromDate: [NSDate date]];
    NSDateComponents *selfCmps = [cale components :unit fromDate : self ];
    return nowCmps.year == selfCmps.year;
}
                                  

@end