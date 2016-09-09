//
//  TBContact.m
//  Talk
//
//  Created by 史丹青 on 6/26/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBContact.h"
#import "constants.h"
#import "MOUser.h"
#import "TBUtility.h"
#import "MOInvitation.h"
#import <Hanzi2Pinyin/Hanzi2Pinyin.h>
#import <CoreData+MagicalRecord.h>

@implementation TBContact

+ (NSArray *)fetchTeamContactsWithTeamId:(NSString *)teamId ABAddressBookRef:(ABAddressBookRef)addressbook {
    if (teamId) {
    } else {
        teamId = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    }
    NSMutableArray *teamUserPhoneArray = [[NSMutableArray alloc] init];
    NSMutableArray *teamUserEmailArray = [[NSMutableArray alloc] init];
    NSMutableArray *teamInvitationPhoneArray = [[NSMutableArray alloc] init];
    NSMutableArray *teamInvitationEmailArray = [[NSMutableArray alloc] init];
    NSArray *teamUserArray = [MOUser findAllInTeamWithTeamId:teamId containRobot:NO];
    for (MOUser *user in teamUserArray) {
        if ([TBUtility dealForNilWithString:user.phoneForLogin].length > 0 && user.isQuitValue == NO) {
            [teamUserPhoneArray addObject:user.phoneForLogin];
        }
        if ([TBUtility dealForNilWithString:user.email].length > 0 && user.isQuitValue == NO) {
            [teamUserEmailArray addObject:user.email];
        }
    }
    
    NSArray *tempInvitationArray = [MOInvitation MR_findByAttribute:@"teamId" withValue:teamId];
    for (MOInvitation *invitation in tempInvitationArray) {
        if ([invitation.mobile length] > 0) {
            [teamInvitationPhoneArray addObject:invitation.mobile];
        }
        if ([invitation.email length] > 0) {
            [teamInvitationEmailArray addObject:invitation.email];
        }
    }
    
    NSMutableArray *localContactArray = [[NSMutableArray alloc]init];
    CFArrayRef allperson = ABAddressBookCopyArrayOfAllPeople(addressbook);
    for (int i = 0; i < CFArrayGetCount(allperson); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allperson, i);
        //phone
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++) {
            TBContact *contact = [[TBContact alloc] init];
            if (ABRecordCopyValue(person, kABPersonLastNameProperty)||ABRecordCopyValue(person, kABPersonFirstNameProperty)) {
                [self setupTBContact:contact withABRecordRef:person];
                contact.originPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                contact.phone = [TBUtility getNumberString:contact.originPhone];
                [contact setIsInTeam:NO];
                for (NSString *phoneString in teamUserPhoneArray) {
                    if ([contact.phone containsString:phoneString]) {
                        [contact setIsInTeam:YES];
                    }
                }
                for (NSString *phoneString in teamInvitationPhoneArray) {
                    if ([contact.phone containsString:phoneString]) {
                        [contact setIsInvited:YES];
                    }
                }
                [localContactArray addObject:contact];
            }
        }
        //email
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (int k = 0; k < ABMultiValueGetCount(emails); k++) {
            TBContact *contact = [[TBContact alloc] init];
            if (ABRecordCopyValue(person, kABPersonLastNameProperty)||ABRecordCopyValue(person, kABPersonFirstNameProperty)) {
                [self setupTBContact:contact withABRecordRef:person];
                contact.email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, k);
                [contact setIsInTeam:NO];
                for (NSString *emailString in teamUserEmailArray) {
                    if ([contact.email containsString:emailString]) {
                        [contact setIsInTeam:YES];
                    }
                }
                for (NSString *emailString in teamInvitationEmailArray) {
                    if ([contact.email containsString:emailString]) {
                        [contact setIsInvited:YES];
                    }
                }
                [localContactArray addObject:contact];
            }
        }
    }
    return localContactArray;
}


+ (void)setupTBContact:(TBContact *)contact withABRecordRef:(ABRecordRef)person {
    if (ABRecordCopyValue(person, kABPersonLastNameProperty)==Nil) {
        contact.name = [NSString stringWithFormat:@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
        contact.pinyin = [Hanzi2Pinyin convertToAbbreviation:[NSString stringWithFormat:@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty)]];
    } else if (ABRecordCopyValue(person, kABPersonFirstNameProperty)==Nil) {
        contact.name = [NSString stringWithFormat:@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty)];
        contact.pinyin = [Hanzi2Pinyin convertToAbbreviation:[NSString stringWithFormat:@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty)]];
    } else {
        contact.name = [NSString stringWithFormat:@"%@ %@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty),(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
        contact.pinyin = [Hanzi2Pinyin convertToAbbreviation:[NSString stringWithFormat:@"%@%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty),(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty)]];
    }
    NSData *imgData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    if (imgData) {
        contact.avator = [UIImage imageWithData: imgData];
        contact.hasAvator = YES;
    } else {
        contact.hasAvator = NO;
    }
    imgData = Nil;
}


@end
