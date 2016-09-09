//
//  TBSearchTextCell.m
//  Talk
//
//  Created by Suric on 15/4/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBSearchMessageCell.h"
#import "TBUtility.h"
#import "MORoom.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "NSDate+TBUtilities.h"
#import "MOUser.h"
#import "TBUser.h"

#define cellDefaultHeight 95
#define contentLableFont  17
#define linkLableFont  14

#define messageContentLableRightMargin 12
#define imageMessageContentLableLeftMargin  67

@implementation TBSearchMessageCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 3;
    
    UIColor *tintColor = [UIColor jl_redColor];
    self.creatorNamelabel.textColor = tintColor;
    self.tintColor = tintColor;
    self.seperator.hidden = YES;
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLongPressRecognizer:(UILongPressGestureRecognizer *)newLongPressRecognizer {
    if (_longPressRecognizer != newLongPressRecognizer) {
        if (_longPressRecognizer != nil) {
            [self removeGestureRecognizer:_longPressRecognizer];
        }
        
        if (newLongPressRecognizer != nil) {
            [self addGestureRecognizer:newLongPressRecognizer];
        }
        
        _longPressRecognizer = newLongPressRecognizer;
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    [self layoutIfNeeded];
}

- (void)setModel:(TBMessage *)model andAttachemnt:(TBAttachment *)attachment {
    _model = model;
    _attachment = attachment;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //name
    if (model.roomID) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:model.roomID];
        MORoom *tempRoom = [MORoom MR_findFirstWithPredicate:predicate];
        NSString *username;
        if (model.authorName) {
            username = model.authorName;
        } else {
            NSString *userName = [TBUtility dealForNilWithString:[TBUtility getFinalUserNameWithTBUser:model.creator]];
            if (userName) {
                username = userName;
            } else {
                username = NSLocalizedString(@"someone", nil);
            }
        }
        NSString *nameString;
        NSString *topicName = [TBUtility getTopicNameWithIsGeneral:tempRoom.isGeneralValue andTopicName:tempRoom.topic];
        nameString = [NSString stringWithFormat:@"%@ ▸ %@",username,topicName];
        self.creatorNamelabel.text = nameString;
    } else if (model.storyID) {
        NSPredicate *predicate = [TBUtility storyPredicateForCurrentTeamWithRoomId:model.storyID];
        MOStory *tempStory = [MOStory MR_findFirstWithPredicate:predicate];
        if (!tempStory) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                [MTLManagedObjectAdapter managedObjectFromModel:model.story insertingIntoContext:localContext error:NULL];
            }];
        }

        NSString *username;
        NSString *userName = [TBUtility dealForNilWithString:[TBUtility getFinalUserNameWithTBUser:model.creator]];
        if (userName) {
            username = userName;
        } else {
            username = NSLocalizedString(@"someone", nil);
        }
        NSString *nameString = [NSString stringWithFormat:@"%@ ▸ %@",username,model.story.title];
        self.creatorNamelabel.text = nameString;
    } else {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
        MOUser *createrUser = [MOUser findFirstWithId:model.creatorID];
        NSString *creatorName = [TBUtility getFinalUserNameWithMOUser:createrUser];
        MOUser *targetUser = [MOUser findFirstWithId:model.toID];
        NSString *targetUserName = [TBUtility getFinalUserNameWithMOUser:targetUser];
        self.creatorNamelabel.text = [NSString stringWithFormat:@"%@ ▸ %@", [currentUserID isEqualToString:createrUser.id] ? NSLocalizedString(@"me", @"me"):creatorName ,[currentUserID isEqualToString:targetUser.id] ? NSLocalizedString(@"me", @"me"):targetUserName];
    }
    
    //time
    self.timeLabel.text = [model.createdAt tb_timeAgo];
    
    //imageView and content
    self.fileButton.hidden = YES;
    self.messageContent.numberOfLines = 0;
    if (model.attachments.count > 0) {
        NSString *category = attachment.category;
        NSString *quoteCategory = attachment.data[kQuoteCategory];
        //message with attachment && quoteCategory is @"url"
        if ([category isEqualToString:kDisplayModeQuote] && [quoteCategory isEqualToString:kQuoteCategoryURL]) {
            self.messageContent.numberOfLines = 3;
            self.quoteLinkLabel.numberOfLines = 1;
        } else {
            self.messageContent.numberOfLines = 2;
            self.quoteLinkLabel.numberOfLines = 3;
        }
        
        //file
        if ([category isEqualToString:kDisplayModeFile]) {
            self.messageContent.numberOfLines = 1;
            self.quoteLinkLabel.numberOfLines = 1;
            self.messageContent.text = attachment.data[kFileName];
            NSString *fileSize = attachment.data[kFileSize];
            NSString *mediaSizeString = [NSString stringWithFormat:@"%@",[TBUtility convertBytes:fileSize.intValue]];
            self.quoteLinkLabel.text = mediaSizeString;
            
            NSString *fileCategory = attachment.data[kFileCategory];
            NSString *fileType = attachment.data[kFileType];
            if ([fileCategory isEqualToString:kFileCategoryImage]) {
                [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:attachment.data[kFileThumbnailUrl]] placeholderImage:[UIImage imageNamed:@"photoDefault"]];
            } else {
                self.fileButton.hidden = NO;
                UIImage *bubbleImage = [[UIImage imageNamed:@"icon-search-file"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.fileButton setTintColor:[TBUtility fileColorWithType: fileType]];
                [self.fileButton setTitle:fileType forState:UIControlStateNormal];
                [self.fileButton setBackgroundImage:bubbleImage forState:UIControlStateNormal];
            }
        }
        // rtf
        else if ([category isEqualToString:kDisplayModeRtf]) {
            self.messageContent.text = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteTitle]]];
            self.quoteLinkLabel.text = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteText]]];
            [self setAvatarImageViewWithImageName:@"icon-search-hyper"];
        }
        // quote
        else if ([category isEqualToString:kDisplayModeQuote]) {
            self.messageContent.text = [TBUtility dealForNilWithString:attachment.data[kQuoteTitle]];
            self.quoteLinkLabel.text =[TBUtility dealForNilWithString: attachment.text];
            if ([category isEqualToString:kDisplayModeQuote] && [quoteCategory isEqualToString:kQuoteCategoryURL]) {
                self.messageContent.text = model.messageStr;
            } else {
                if (model.authorAvatarUrl) {
                    [self.avatarImageView sd_setImageWithURL:model.authorAvatarUrl placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
                } else {
                    if (model.creator.avatarURL) {
                        [self.avatarImageView sd_setImageWithURL:model.creator.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
                    } else {
                        [self.avatarImageView setImage:[UIImage imageNamed:@"avatar"]];
                    }
                }
            }
        }
        // snippet
        else if ([category isEqualToString:kDisplayModeSnippet]) {
            self.messageContent.text = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteTitle]]];
            self.quoteLinkLabel.text = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteText]]];
            [self setAvatarImageViewWithImageName:@"icon-search-snippet"];
        }
        // speech
        else if ([category isEqualToString:kDisplayModeSpeech]) {
            [self setAvatarImageViewWithImageName:@"icon-favorite-voice"];
            NSString *audioString = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Audio", @"Audio")];
            self.messageContent.text = audioString;
            self.quoteLinkLabel.text = [TBUtility getTimeStringWithDuration:[attachment.data[kVoiceDuration] integerValue]];
        }
        /*other unknown category*/
        else {
            self.messageContent.text = model.messageStr;
            self.quoteLinkLabel.text = @"";
        }
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"icon-search-text"];
        self.messageContent.text = model.messageStr;
    }
    
    //content
    NSArray *highlightKeys = model.highlight.allKeys;
    if (self.currentSearchString) {
        if ([highlightKeys containsObject:kHighlightKeyBody]) {
            self.messageContent.attributedText = [TBUtility getHighlightStringFromMessageHighlightDictionary:model.highlight withKeyString:kHighlightKeyBody];
        }
        if ([highlightKeys containsObject:kHighlightKeyfileName]) {
            self.messageContent.attributedText = [TBUtility getHighlightStringFromMessageHighlightDictionary:model.highlight withKeyString:kHighlightKeyfileName];
        }
    }
    if ([highlightKeys containsObject:kHighlightKeyAttachmentText])  {
        self.quoteLinkLabel.attributedText = [TBUtility getHighlightStringFromMessageHighlightDictionary:model.highlight withKeyString:kHighlightKeyAttachmentText];
    }
}

- (void)setAvatarImageViewWithImageName:(NSString *)imageName {
    self.avatarImageView.image = [UIImage imageNamed:imageName];
}

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model
{
    CGFloat height;
    if (model.attachments.count > 0) {
        TBAttachment *attachment = model.attachments.firstObject;
        NSString *category = attachment.category;
        NSString *quoteCategory = attachment.data[kQuoteCategory];
        NSInteger contentLines;
        NSInteger linkLines;
        //message with attachment && quoteCategory is @"url"
        BOOL isURL = NO;
        if ([category isEqualToString:kDisplayModeQuote] && [quoteCategory isEqualToString:kQuoteCategoryURL]) {
            contentLines = 3;
            linkLines = 1;
            isURL = YES;
        } else {
            contentLines = 2;
            linkLines = 3;
        }
        
        //file
        if ([category isEqualToString:kDisplayModeFile]) {
            height = cellDefaultHeight;
        }
        // rtf ,quote, snippet
        else if ([category isEqualToString:kDisplayModeRtf] || [category isEqualToString:kDisplayModeSnippet] || [category isEqualToString:kDisplayModeQuote]) {
            NSString *title = @"";
            NSString *link = @" ";
            if (isURL) {
                title = model.messageStr;
                if (attachment.data[kQuoteTitle]) {
                    link = [@" " stringByAppendingString:attachment.data[kQuoteTitle]];
                }
            } else {
                if (attachment.data[kQuoteTitle]) {
                    title = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteTitle]]];
                }
                if (attachment.data[kQuoteText]) {
                    link = [TBUtility getStringWithoutHtmlFromString:[TBUtility dealForNilWithString:attachment.data[kQuoteText]]];
                }
            }
            CGFloat contentHeight = [TBSearchMessageCell getSizeWithString:title andNumberOfLines:contentLines andFontSize:contentLableFont].height;
            CGFloat linkHeight = [TBSearchMessageCell getSizeWithString:link andNumberOfLines:linkLines andFontSize:linkLableFont].height;
            height = cellDefaultHeight - 38 + contentHeight + linkHeight;
        }
        // speech
        else if ([category isEqualToString:kDisplayModeSpeech]) {
            height = cellDefaultHeight;
        }
        /*other unknown category*/
        else {
            height = cellDefaultHeight;
        }
    } else {
        height = cellDefaultHeight - 45 + [TBSearchMessageCell getSizeWithString:model.messageStr andNumberOfLines:0 andFontSize:contentLableFont].height;
    }
    if (height < 95) {
        return 95;
    } else {
        return height;
    }
}

+(CGSize)getSizeWithString:(NSString *)string andNumberOfLines:(NSInteger)number andFontSize:(CGFloat)fontSize
{
    NSString *importStr = string;
    CGFloat contentViewWidth ;
    contentViewWidth = [[UIScreen mainScreen] bounds].size.width - imageMessageContentLableLeftMargin - messageContentLableRightMargin;
    CGFloat maxHeight;
    switch (number) {
        case 0:
            maxHeight = CGFLOAT_MAX;
            break;
        case 1:
            maxHeight = 21;
            break;
        case 2:
            maxHeight = 40;
            break;
        case 3:
            maxHeight = 70;
            break;
            
        default:
            break;
    }
    CGSize tempsize = CGSizeMake(contentViewWidth,maxHeight);
    UILabel *temLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines = number;
    temLabel.font = [UIFont systemFontOfSize:fontSize];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    temLabel.text = importStr;
    CGSize size = [temLabel sizeThatFits:tempsize];
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

@end
