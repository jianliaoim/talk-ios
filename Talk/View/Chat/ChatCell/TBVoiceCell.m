//
//  TBVoiceCell.m
//  Talk
//
//  Created by Suric on 15/5/11.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBVoiceCell.h"
#import "constants.h"
#import "TBUtility.h"
#import "RecordAudio.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "MagicalRecord.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "TBAttachment.h"
#import "TBUser.h"

#define voiceCellDefaultHeight 47

@implementation TBVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.playButton.layer.masksToBounds = YES;
    self.playButton.layer.cornerRadius = cornerRadius;
    self.playProgressView.layer.masksToBounds = YES;
    self.playProgressView.layer.cornerRadius = cornerRadius;
    self.playProgressView.layer.shouldRasterize = YES;
    [self.playProgressView setProgress:0.0];
    [self.playProgressView setFrontColor:[UIColor jl_lightRedColor]];
    [self.playProgressView setHorizontal:YES];
    self.currentPlaySecond = 0;
}

-(void)setMessage:(TBMessage *)message {
    [super setMessage:message];
    
    TBAttachment *attachment = [message.attachments firstObject];
    //set length
    CGFloat totalDuration;
    if (self.message.sendStatus == sendStatusFailed || self.message.sendStatus == sendStatusSending) {
        totalDuration = self.message.duration;
    } else {
        totalDuration = [attachment.data[kVoiceDuration] floatValue];
    }
    int minLength = 1;
    if (totalDuration <= minLength) {
        self.voiceLengthConstraint.constant = voiceMinLength;
        self.progressLengthConstraint.constant = voiceMinLength;
    } else if (totalDuration > 60) {
        self.voiceLengthConstraint.constant = voiceMaxLength;
        self.progressLengthConstraint.constant = voiceMaxLength;
    }
    else {
        self.voiceLengthConstraint.constant = voiceMinLength + (voiceMaxLength - voiceMinLength)/(60 - minLength) * (totalDuration - minLength);
        self.progressLengthConstraint.constant = voiceMinLength + (voiceMaxLength - voiceMinLength)/(60 - minLength) * (totalDuration - minLength);
    }
    
    //play button and play Image button
    UIImage *playImage = [[UIImage imageNamed:@"icon-voice-play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.unreadDotIamgeView.hidden = YES;
    self.imageButton.tintColor = [UIColor jl_redColor];
    self.durationLabel.textColor = [UIColor tb_otherFileColor];
    //progress color
    [self.playProgressView setBackColor:[UIColor clearColor]];
    [self.playButton setBackgroundColor:[UIColor whiteColor]];
    if (message.isSend) {
        //avator
        [self.userAvatorImageView sd_setImageWithURL:self.message.creator.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
        //unread Dot
        self.unreadDotIamgeView.hidden = !message.isUnread;
    }
//    else {
//        [self.playButton setBackgroundColor:[UIColor tb_lightDocColor]];
//    }
    [self.imageButton setBackgroundImage:playImage forState:UIControlStateNormal];
    
    self.userNameAndTimeLbl.hidden = NO;
    self.imageButton.hidden = NO;
    
    NSString *userName = [TBUtility getCreatorNameForMessage:message];
    switch (message.sendStatus) {
        case sendStatusSucceed:
        {
            //userNameAndTime
            if (userName) {
                self.userNameAndTimeLbl.text = [userName stringByAppendingFormat:@"  %@",[message.createdAt tb_timeAgo]];
            } else {
                self.userNameAndTimeLbl.text = [NSLocalizedString(@"someone", nil) stringByAppendingFormat:@"  %@",[message.createdAt tb_timeAgo]];
            }
            
            //duration
            self.durationLabel.text = [TBUtility getTimeStringWithDuration:totalDuration];
        }
            break;
        case sendStatusSending:
        {
            self.userNameAndTimeLbl.text = NSLocalizedString(@"Sending...", nil);
            self.userNameAndTimeLbl.textColor = [UIColor tb_subTextColor];
            self.durationLabel.text = [TBUtility getTimeStringWithDuration:message.duration];
        }
            break;
        case sendStatusFailed:
        {
            self.userNameAndTimeLbl.text = NSLocalizedString(@"Failed,Tap to resend", nil);
            self.userNameAndTimeLbl.textColor = [UIColor redColor];
            self.durationLabel.text = [TBUtility getTimeStringWithDuration:message.duration];
        }
            break;
        case sendStatusRecording:
        {
            self.imageButton.hidden = YES;
            self.userNameAndTimeLbl.hidden = YES;
            self.durationLabel.text = [TBUtility getTimeStringWithDuration:message.duration];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)playMessage:(id)sender {
    if (self.message.sendStatus == sendStatusFailed) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResendVoiceNotification object:self.message];
        return;
    }
    
    if (self.message.sendStatus == sendStatusSucceed) {
        if (self.isPlay) {
            if (self.timer) {
                [self.timer invalidate];
                self.isPlay = NO;
                [self.playProgressView setProgress:0];
                self.currentPlaySecond = 0;
                UIImage *playImage = [[UIImage imageNamed:@"icon-voice-play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.imageButton setBackgroundImage:playImage forState:UIControlStateNormal];
                CGFloat totalDuration;
                if (self.message.sendStatus == sendStatusFailed) {
                    totalDuration = self.message.duration;
                } else {
                    TBAttachment *attachment = [self.message.attachments firstObject];
                    totalDuration = [attachment.data[kVoiceDuration] floatValue];
                }
                self.durationLabel.text = [TBUtility getTimeStringWithDuration:totalDuration];
                if ([_delegate respondsToSelector:@selector(stopVoicePlay)]) {
                    [_delegate stopVoicePlay];
                }
            }
        }
        else {
            self.unreadDotIamgeView.hidden = YES;
            self.durationLabel.text = [TBUtility getTimeStringWithDuration:self.currentPlaySecond];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
            self.isPlay = YES;
            if ([_delegate respondsToSelector:@selector(playVoiceWithMessage:)]) {
                [_delegate playVoiceWithMessage:self.message];
            }
        }
        
    }
}

- (void)updateProgress:(NSTimer *)timer {
    self.isPlay = YES;
    self.currentPlaySecond = self.currentPlaySecond + timer.timeInterval;
    self.durationLabel.text = [TBUtility getTimeStringWithDuration:self.currentPlaySecond];
    
    UIImage *playImage = [[UIImage imageNamed:@"icon-voice-pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageButton setBackgroundImage:playImage forState:UIControlStateNormal];
    
    CGFloat totalDuration;
    if (self.message.sendStatus == sendStatusFailed) {
        totalDuration = self.message.duration;
    } else {
        TBAttachment *attachment = [self.message.attachments firstObject];
        totalDuration = [attachment.data[kVoiceDuration] floatValue];
    }
    [self.playProgressView setProgress:self.currentPlaySecond/totalDuration animated:YES];
    if (self.currentPlaySecond >= totalDuration) {
        [self.playProgressView setProgress:0];
        self.currentPlaySecond = 0;
        [timer invalidate];
        self.isPlay = NO;
        
        UIImage *playImage = [[UIImage imageNamed:@"icon-voice-play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageButton setBackgroundImage:playImage forState:UIControlStateNormal];
    }
}

+ (CGFloat)calculateCellHeight {
    return voiceCellDefaultHeight;
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
    }
}

@end
