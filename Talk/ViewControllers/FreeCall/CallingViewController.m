//
//  CallingViewController.m
//  Talk
//
//  Created by 史丹青 on 9/24/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "CallingViewController.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "JLFreeCallHelper.h"
#import "MOUser.h"
#import "TBUser.h"
#import "constants.h"
#import "CoreData+MagicalRecord.h"
#import "ReactiveCocoa.h"
#import "SVProgressHUD.h"
#import <AddressBook/AddressBook.h>

@interface CallingViewController ()

@property (nonatomic, strong) CTCallCenter *callCenter;

@property (weak, nonatomic) IBOutlet UIImageView *userAvator;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *waitingCallLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) JLFreeCallHelper *helper;
@property (nonatomic) BOOL isCallGroup;
@property (nonatomic) BOOL canCancel;
@property (strong, nonatomic) MOUser *user;
@property (strong, nonatomic) NSArray *phoneArray;

@end

@implementation CallingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canCancel = NO;
    
    [self writeJianliaoIntoAddressBook];
    
    [self setupCallCenter];
    
    //setup UI
    if (self.isCallGroup) {
        [self.userName setText:[NSString stringWithFormat:NSLocalizedString(@"multiple phone call among %d people", @"multiple phone call among %d people"), self.phoneArray.count]];
    } else {
        [self.userName setText:self.user.name];
        self.userAvator.layer.masksToBounds = YES;
        self.userAvator.layer.cornerRadius = 40;
        [self.userAvator sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:[UIImage imageNamed:@"groupCall"]];
    }
    
    [self.phoneNumberLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Please wait for call from %@", @"Please wait for call from %@"), kYTXShowPhoneNumber]];
    
    MOUser *user = [MOUser currentUser];
    self.helper = [[JLFreeCallHelper alloc] init];
    if (self.isCallGroup) {
        [[[self.helper creatConference] flattenMap:^RACStream *(id value) {
            self.canCancel = YES;
            return [self.helper invitePhoneNumbers:self.phoneArray];
        }] subscribeNext:^(id x) {
            //success
        } error:^(NSError *error) {
            if (error != nil) {
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [[self.helper callFrom:user.phoneForLogin To:self.user.phoneForLogin] subscribeNext:^(id x) {
            self.canCancel = YES;
        } error:^(NSError *error) {
            if (error != nil) {
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction

- (IBAction)cancelCall:(UIButton *)sender {
    if (!self.canCancel) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.isCallGroup) {
        [[self.helper cancelConference] subscribeError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        } completed:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [[self.helper cancelCall] subscribeError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        } completed:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (IBAction)hideCallingView:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

- (void)callUser:(MOUser *)user {
    self.isCallGroup = NO;
    self.user = user;
}

- (void)callGroup:(NSArray *)userArray {
    self.isCallGroup = YES;
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id user in userArray) {
        if ([user isKindOfClass:[MOUser class]]) {
            [mutableArray addObject:((MOUser *)user).phoneForLogin];
        } else {
            [mutableArray addObject:((TBUser *)user).phoneForLogin];
        }
    }
    MOUser *user = [MOUser currentUser];
    [mutableArray addObject:user.phoneForLogin];
    self.phoneArray = [mutableArray copy];
}

#pragma mark - Private

- (void)writeJianliaoIntoAddressBook {
    ABAddressBookRef address= ABAddressBookCreateWithOptions(Nil, Nil);
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(address, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        CFStringRef cfName =  CFSTR("简聊");
        NSArray *peoples = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(address, cfName);
        if (peoples.count == 0) {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            ABRecordRef person = ABPersonCreate();
            NSString *firstName = @"简聊";
            NSArray *phones = [NSArray arrayWithObjects:kYTXShowPhoneNumber,[NSString stringWithFormat:@"010%@",kYTXShowPhoneNumber],[NSString stringWithFormat:@"020%@",kYTXShowPhoneNumber],nil];
            NSArray *labels = [NSArray arrayWithObjects:NSLocalizedString(@"Phone Call", @"Phone Call"),NSLocalizedString(@"Phone Call", @"Phone Call"),NSLocalizedString(@"Phone Call", @"Phone Call"),nil];
            ABRecordSetValue(person, kABPersonFirstNameProperty,(__bridge CFStringRef)firstName, NULL);
            ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
            for (int i = 0; i < [phones count]; i ++) {
                ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
            }
            ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
            if (mv) {
                CFRelease(mv);
            }
            ABAddressBookAddRecord(addressBook, person, NULL);
            ABAddressBookSave(addressBook, NULL);
            if (addressBook) {
                CFRelease(addressBook);
            }
        }
    }
    if (address) {
        CFRelease(address);
    }
}

#pragma mark - CallCenter

- (void)setupCallCenter {
    __weak CallingViewController *weakSelf = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            NSLog(@"Call has been disconnected");
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            NSLog(@"Call has just been connected");
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            NSLog(@"Call is incoming");
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {
            NSLog(@"call is dialing");
        }
        else
        {  
            NSLog(@"Nothing is done");  
        }  
    };
}

@end
