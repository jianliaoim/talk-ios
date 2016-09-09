//
//  TBTimeCell.m
//  
//
//  Created by Suric on 15/8/6.
//
//

#import "TBTimeCell.h"
#import "UIColor+TBColor.h"
#import "constants.h"
#import "TBAttachment.h"
#import "TBUtility.h"

#define cellDefaultHeight  35

@implementation TBTimeCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(TBMessage *)message {
    _message = message;

    NSString *userName = [TBUtility getCreatorNameForMessage:message];
    //userNameAndTime
    self.userNameAndTimeLbl.hidden = NO;
    if (message.isSend) {
        switch (message.sendStatus) {
            case sendStatusSucceed:
            {
                [self.resendBtn setEnabled:NO];
                self.userNameAndTimeLbl.textColor = [UIColor tb_subTextColor];
                NSString *timeString = [message.createdAt tb_timeAgo];
                if (userName) {
                    self.userNameAndTimeLbl.text = [userName stringByAppendingFormat:@"  %@",timeString];
                } else {
                    self.userNameAndTimeLbl.text = [NSLocalizedString(@"someone", nil) stringByAppendingFormat:@"  %@",timeString];
                }
            }
                break;
            case sendStatusSending:
            {
                [self.resendBtn setEnabled:NO];
                self.userNameAndTimeLbl.text = NSLocalizedString(@"Sending...", nil);
                self.userNameAndTimeLbl.textColor = [UIColor tb_subTextColor];
            }
                break;
            case sendStatusRecording:
            {
                [self.resendBtn setEnabled:NO];
                self.userNameAndTimeLbl.hidden = YES;
            }
                break;
            case sendStatusFailed:
            {
                [self.resendBtn setEnabled:YES];
                self.userNameAndTimeLbl.text = NSLocalizedString(@"Failed,Tap to resend", nil);
                self.userNameAndTimeLbl.textColor = [UIColor redColor];
            }
                break;
                
            default:
                break;
        }
    } else {
        if (userName) {
            self.userNameAndTimeLbl.text = [userName stringByAppendingFormat:@"  %@",[message.createdAt tb_timeAgo]];
        } else {
            self.userNameAndTimeLbl.text = [NSLocalizedString(@"someone", nil) stringByAppendingFormat:@"  %@",[message.createdAt tb_timeAgo]];
        }
    }
}

- (IBAction)resendMessage:(id)sender {
    //speech
    if (self.message.duration > 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResendVoiceNotification object:self.message];
    }
    // image
    else if (self.message.sendImageCategory) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResendImageNotification object:self.message];
    }
    //text
    else {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResendMessageNotification object:self.message];
    }
}

#pragma mark -Class Methods

+ (CGFloat)calculateCellHeight {
    return cellDefaultHeight;
}

@end
