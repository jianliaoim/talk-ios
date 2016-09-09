//
//  ChatViewController.m
//  Talk
//
//  Created by zhangxiaolian on 14/10/9.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageEditViewController.h"
#import "TopicSettingController.h"
#import "ChooseAtMemberController.h"
#import "FeedbackTableViewController.h"
#import "HyperDetailViewController.h"
#import "MeInfoViewController.h"

#import "TbChatTableViewCell.h"
#import "TBChatSendTableViewCell.h"
#import "TBQuoteTableViewCell.h"
#import "TBQuoteSendTableViewCell.h"
#import "TBFileTableViewCell.h"
#import "TBFileSendTableViewCell.h"
#import "TBImageTableViewCell.h"
#import "TBImageSendTableViewCell.h"
#import "TBSystemMessageCell.h"
#import "TBWeiboCell.h"
#import "TBVoiceCell.h"
#import "TBVoiceSendCell.h"
#import "TBTimeCell.h"
#import "TBTimeSendCell.h"
#import "TBAttachementMessageCell.h"
#import "TBAttatchmentMessageSendCell.h"

#import "PresentingAnimator.h"
#import "DismissingAnimator.h"

#import "SLKUIConstants.h"
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AGEmojiKeyBoardView.h"
#import "NSString+Emoji.h"
#import "AZAPreviewController.h"
#import "AZAPreviewItem.h"

#import "TBUser.h"
#import "TBMessage.h"
#import "MOMessage.h"
#import "MOUser.h"
#import "MORoom.h"
#import "TBTag.h"
#import "TBAttachment.h"

#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "UIColor+TBColor.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"

#import <NSDate+TimeAgo.h>
#import "NSDate+TBUtilities.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "TBUtility.h"
#import "TBChatImageModel.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <MessageUI/MessageUI.h>
#import <Photos/Photos.h>
#import "Talk-Swift.h"
#import "RecordAudio.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "MWPhotoBrowser.h"
#import "TBMenuItem.h"
#import "UIImage+Orientation.h"
#import <FLAnimatedImage.h>
#import "ItemsViewController.h"
#import "MessageSendEngine.h"

#import "AddTagViewController.h"
#import "MessageShelfButtonGuideView.h"
#import "GuideHelper.h"
#import "TBWeiboSendCell.h"
#import "SHActionSheetBlocks.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "ShareToTableViewController.h"
#import "JLWebViewController.h"

#import "CallingViewController.h"
#import "AddTopicMemberViewController.h"
#import "TBMemberInfoView.h"
#import "StoryView.h"
#import "JLStoryView.h"
#import "MONotification.h"
#import "MODraft.h"
#import <Masonry.h>

#import "RecentMessagesViewController.h"
#import "Talk-Swift.h"

static NSString *CellIdentifier = @"TbChatTableViewCell";
static NSString *sendCellIdentifier = @"TBChatSendTableViewCell";
static NSString *quoteCellIdentifier = @"TBQuoteTableViewCell";
static NSString *quoteSendCellIdentifier = @"TBQuoteSendTableViewCell";
static NSString *fileCellIdentifier = @"TBFileTableViewCell";
static NSString *fileSendCellIdentifier = @"TBFileSendTableViewCell";
static NSString *imageCellIdentifier = @"TBImageTableViewCell";
static NSString *imageSendCellIdentifier = @"TBImageSendTableViewCell";
static NSString *systemCellIdentifier = @"TBSystemMessageCell";
static NSString *weiboCellIdentifier = @"TBWeiboCell";
static NSString *weiboSendCellIdentifier = @"TBWeiboSendCell";
static NSString *voiceCellIdentifier = @"TBVoiceCell";
static NSString *voiceSendCellIdentifier = @"TBVoiceSendCell";
static NSString *timeCellIdentifier = @"TBTimeCell";
static NSString *timeSendCellIdentifier = @"TBTimeSendCell";
static NSString *attachmentMessageCellIdentifier = @"TBAttachementMessageCell";
static NSString *attachmentMessageSendCellIdentifier = @"TBAttatchmentMessageSendCell";

@interface ChatViewController ()<UIGestureRecognizerDelegate, UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,AGEmojiKeyboardViewDataSource,AGEmojiKeyboardViewDelegate,QLPreviewControllerDelegate, QLPreviewControllerDataSource, AZAPreviewControllerDelegate,TTTAttributedLabelDelegate,MFMailComposeViewControllerDelegate,BRNImagePickerSheetDelegate,TBQuoteTableViewCellDelegate,UIViewControllerTransitioningDelegate,MessageEditViewControllerDelegate,RecordAudioDelegate,TBVoiceCellDelegate,MWPhotoBrowserDelegate,TBAttachementMessageCellDelegate,MultiplePhoneCallDelegate,TbChatTableViewCellDelegate>
{
    CGPoint _draggingOffset;
    BOOL isEditingMessage;                //default is NO
    UIColor *chatTintColor;               // chat tintColor
    
    TBFooterView *centerLoadingView;      //loadingView for First enter
    TBFooterView *loadingFooterView;
    UIWebView *phoneCallWebView;          //use for call
    
    //voice
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
    BOOL hasRecordPermission;
}

@property (strong, nonatomic)  UIBarButtonItem *phoneCallItem;
@property (strong, nonatomic)  UIBarButtonItem *messageShelfItem;
@property (strong, nonatomic)  UIBarButtonItem *settingItem; //rightBarButtonItem
@property (strong, nonatomic)  UIBarButtonItem *editStoryItem; //rightBarButtonItem
@property (strong, nonatomic)  UIButton *unreadButton;

//placeholderView for Header or Footer
@property (weak, nonatomic) IBOutlet UIView *roomHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *privateHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *privateWelcomelabel;
@property (weak, nonatomic) IBOutlet UILabel *privateCommentlabel;

//preview pop view
@property (weak, nonatomic) IBOutlet UIView *previewPopView;
@property (weak, nonatomic) IBOutlet UILabel *previewReminderLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinTopicButton;

// The shared scrollView pointer, either a tableView or collectionView
@property (strong, nonatomic) UIScrollView *scrollViewProxy;
// Auto-Layout height constraints used for updating their constants
@property (strong, nonatomic) NSLayoutConstraint *scrollViewHC;
@property (strong, nonatomic) NSLayoutConstraint *textInputbarHC;
@property (strong, nonatomic) NSLayoutConstraint *keyboardHC;

// The single tap gesture used to dismiss the keyboard
@property (strong, nonatomic) UITapGestureRecognizer *singleTapGesture;
// YES if the user is moving the keyboard with a gesture
@property (nonatomic, getter = isMovingKeyboard) BOOL movingKeyboard;
// The current QuicktypeBar mode (hidden, collapsed or expanded)
@property (nonatomic) SLKQuicktypeBarMode quicktypeBarMode;
// The current keyboard status (hidden, showing, etc.)
@property (nonatomic) SLKKeyboardStatus keyboardStatus;
@property (nonatomic) BOOL isReloadTableView;
@property (nonatomic) BOOL shouldLoadMoreForViewDidLoad;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) NSMutableArray *previewItems;       //for preview file
@property (strong, nonatomic) NSMutableArray *currentRoomMembers;
@property (nonatomic,assign) BOOL showKeyboardWhenViewDidAppear;   //showKeyboard or not when view DidAppear
@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

//array for chat data
@property(strong, nonatomic) NSMutableArray *chatDataArray;       //all chatDataArray ,contain succeed and failed messages
@property(strong, nonatomic) NSMutableArray *neweastMessageArray; //newestArray for chatStyleSearch
@property(nonatomic) int  searchUnreadNum; //num for unread in chatStyleSearch
@property (strong, nonatomic) NSMutableDictionary *messageIdToFavoriteId;//temp favorited messages id

//voice related
@property (weak, nonatomic) IBOutlet UIView *voiceReminderView;
@property (weak, nonatomic) IBOutlet UIImageView *voiceRemindImageView;
@property (weak, nonatomic) IBOutlet UILabel *voiceReminderLabel;
@property (strong, nonatomic) TBMessage *sendingVoiceMessage;
@property (strong, nonatomic) TBMessage *playingVoiceMessage;
@property (strong, nonatomic) NSTimer *voiceTimer;
@property (nonatomic) CGFloat currentPlaySecond;

//photo broswer
@property (strong, nonatomic) MWPhotoBrowser *browser;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *morePhotos;
@property (nonatomic) NSInteger photosTotal;

//avatar long press at member
@property (strong, nonatomic) NSMutableArray *avatarAtMemberArray;
@property (strong, nonatomic) StoryView *storyView;
@property (strong, nonatomic) UILabel *titleText;
@property (strong, nonatomic) JLStoryView *storyDisplayView;

@end

#define FetchSize    20
#define SearchFetchSize 15
#define headerViewWithoutCommentLableHeight 95
#define commentLabelLeftMargin 10

static double startRecordTime=0;
static double endRecordTime=0;

@implementation ChatViewController

#pragma mark - Common Init

- (void)initTableView {
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor tb_BackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setScrollViewProxy:self.tableView];
}

- (void)initTablePlaceHolder {
    //set placeholder related
    CGFloat lineSpace = 4;
    CGFloat commentLabelFont = 13.0;
    
    if (self.roomType == ChatRoomTypeForRoom) {
        MORoom *tempRoom = [TBUtility currentAppDelegate].currentRoom;
        self.currentRoom = tempRoom;
        if (tempRoom.isGeneral.boolValue) {
            self.welcomeLabel.text = NSLocalizedString(@"Welcome to Talk", @"Welcome to Talk");
            [self.commentLabel setAttributedText:[TBUtility getAttributedStringWith:NSLocalizedString(@"General comment placeholder", @"General comment placeholder") andLineSpace:lineSpace andFont:commentLabelFont]];
        } else {
            self.welcomeLabel.text = NSLocalizedString(@"Topic placeholder", @"Topic placeholder");
            MOUser *creator = [MOUser findFirstWithId:[TBUtility currentAppDelegate].currentRoom.creatorID];
            NSString *creatorName  = creator.name;
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:NSLocalizedString(@"Date Formatter", @"Date Formatter")];
            NSString *createAtTimeStr = [formatter stringFromDate:[TBUtility currentAppDelegate].currentRoom.createdAt];
            NSString *commentStr = [NSString stringWithFormat:NSLocalizedString(@"Create by comment placeholder", @"Create by comment placeholder"),creatorName,createAtTimeStr];
            [self.commentLabel setAttributedText:[TBUtility getAttributedStringWith:commentStr andLineSpace:lineSpace andFont:commentLabelFont]];
            
            CGSize commentLabelSize = [TBUtility getSizeWith:commentStr andMargin:commentLabelLeftMargin andLineSpace:lineSpace andFont:commentLabelFont];
            CGRect originFrame = self.roomHeaderView.frame;
            originFrame.size.height = headerViewWithoutCommentLableHeight + commentLabelSize.height;
            self.roomHeaderView.frame = originFrame;
        }
        self.roomHeaderView.backgroundColor = [UIColor tb_BackgroundColor];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        MOStory *tempStory = self.currentStory;
        self.currentStory = tempStory;
        self.welcomeLabel.text = NSLocalizedString(@"Topic placeholder", @"Topic placeholder");
        
        MOUser *creator = [MOUser findFirstWithId:self.currentStory.creatorID];
        NSString *creatorName  = creator.name;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:NSLocalizedString(@"Date Formatter", @"Date Formatter")];
        NSString *createAtTimeStr = [formatter stringFromDate:self.currentStory.createdAt];
        NSString *commentStr = [NSString stringWithFormat:NSLocalizedString(@"Create story by comment placeholder", @"Create story by comment placeholder"),creatorName,createAtTimeStr];
        [self.commentLabel setAttributedText:[TBUtility getAttributedStringWith:commentStr andLineSpace:lineSpace andFont:commentLabelFont]];
        
        CGSize commentLabelSize = [TBUtility getSizeWith:commentStr andMargin:commentLabelLeftMargin andLineSpace:lineSpace andFont:commentLabelFont];
        CGRect originFrame = self.roomHeaderView.frame;
        originFrame.size.height = headerViewWithoutCommentLableHeight + commentLabelSize.height;
        self.roomHeaderView.frame = originFrame;
        self.roomHeaderView.backgroundColor = [UIColor tb_BackgroundColor];
    }
    else {
        if ([self.currentToMember.service isEqualToString:@"talkai"]) {
            self.privateWelcomelabel.text = NSLocalizedString(@"Talkai placeholder", @"Talkai placeholder");
            [self.privateCommentlabel setAttributedText:[TBUtility getAttributedStringWith:NSLocalizedString(@"Talkai comment placeholder", @"Talkai comment placeholder") andLineSpace:lineSpace andFont:commentLabelFont]];
        } else {
            self.privateWelcomelabel.text = NSLocalizedString(@"private placeholder", @"private placeholder");
            [self.privateCommentlabel setAttributedText:[TBUtility getAttributedStringWith:NSLocalizedString(@"Private comment placeholder", @"Private comment placeholder") andLineSpace:lineSpace andFont:commentLabelFont]];
        }
        CGRect originFrame = self.privateHeaderView.frame;
        originFrame.size.height = CGRectGetHeight(originFrame) + 30;
        self.privateHeaderView.frame = originFrame;
        self.privateHeaderView.backgroundColor = [UIColor tb_BackgroundColor];
    }
}

- (void)commonInit {
    [self initTableView];
    
    self.bounces = YES;
    self.inverted = NO;
    self.undoShakingEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.view.backgroundColor = [UIColor tb_BackgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //tap tableview to hide keyBoard
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScrollView:)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupNavigationbar];
        [self initTablePlaceHolder];
    });
    [self setupViewConstraints];
    [self initTableLoadingView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //init voice
        [self initVoice];
        //deal for preview
        if (self.isPreView || self.isArchived) {
            [self dealForPreview];
        }
        //show guideView
        //[self guideView];
    });
    
    if (self.roomType == ChatRoomTypeForStory) {
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        [self.view addSubview:self.storyDisplayView];
        [self showTip];
    }
}

- (void)showTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasShowStoryDetailTip]) {
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowStoryDetailTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UIWindow *topWindow = [TBUtility applicationTopView];
    CGRect frame = [self.view convertRect:self.storyDisplayView.frame toView:topWindow];
    CGRect finalFrame = CGRectOffset(frame, 0,66);
    AMPopTip *poptip = [[TBUtility currentAppDelegate] getPopTipWithContainerView:topWindow];
    [poptip showText:NSLocalizedString(@"Show Story tip", nil) direction:AMPopTipDirectionDown maxWidth:200 inView:topWindow fromFrame:finalFrame];
}

- (void)initVoice {
    //voice init
    self.voiceReminderView.layer.masksToBounds = YES;
    self.voiceReminderView.layer.cornerRadius = 18.0;
    self.voiceReminderLabel.text = NSLocalizedString(@"Slide up to cancel", @"Slide up to cancel");
    self.voiceReminderView.hidden = YES;
    self.voiceReminderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.voiceReminderView];
    UIView *window = self.view;
    CGFloat height = 156.0f;
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.voiceReminderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.voiceReminderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterY multiplier:1.0 constant: - CGRectGetHeight(self.navigationController.navigationBar.frame)/2 ]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.voiceReminderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.voiceReminderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
    self.currentPlaySecond = 0;
}

- (void)dealForPreview {
    //preview title
    if (self.isArchived) {
        self.previewReminderLabel.text = NSLocalizedString(@"Topic Archived", @"Topic Archived");
    } else if (self.isPreView) {
        NSMutableAttributedString *previewString = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"You're previewing", @"You're previewing")];
        NSString *topicName = [NSString stringWithFormat:@" #%@",[TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic]];
        NSAttributedString *topicNameString = [[NSAttributedString alloc]initWithString:topicName attributes:@{NSForegroundColorAttributeName : [UIColor jl_redColor]}];
        [previewString appendAttributedString:topicNameString];
        self.previewReminderLabel.attributedText = previewString;
    }
    
    //join button
    self.joinTopicButton.layer.cornerRadius = 20.0f;
    [self.joinTopicButton setBackgroundColor:[UIColor jl_redColor]];
    if (self.isArchived) {
        [self.joinTopicButton setTitle:NSLocalizedString(@"Back recover", @"Back recover") forState:UIControlStateNormal];
    } else if (self.isPreView) {
        [self.joinTopicButton setTitle:NSLocalizedString(@"Join", @"Join") forState:UIControlStateNormal];
    }
    
    //preview popView
    self.previewPopView.layer.cornerRadius = 5.0f;
    self.previewPopView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.previewPopView.layer.shadowOpacity = 0.5;
    self.previewPopView.layer.shadowOffset = CGSizeMake(0, 0);
    self.previewPopView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.previewPopView];
    UIView *window = self.view;
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.previewPopView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.previewPopView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.previewPopView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:self.previewPopView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:109.0f]];
    
    //setting item
    self.settingItem.enabled = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
}

- (void)setupNavigationbar {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIButton *settingButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setFrame:CGRectMake(0, 0, 20, 20)];
    if (self.roomType == ChatRoomTypeForTeamMember) {
        UIImage *image = [[UIImage imageNamed:@"icon-me-navi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [settingButton setTintColor:[UIColor whiteColor]];
        [settingButton setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        [settingButton setBackgroundImage:[UIImage imageNamed:@"topic-setting"] forState:UIControlStateNormal];
    }
    [settingButton addTarget:self action:@selector(SettingAction:) forControlEvents:UIControlEventTouchUpInside];
    self.settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    UIBarButtonItem *fixedSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 12.0f;
    
    UIButton *messageShelfButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageShelfButton setFrame:CGRectMake(0, 0, 20, 20)];
    UIImage *shelfImage= [[UIImage imageNamed:@"icon-shelf"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    messageShelfButton.imageView.tintColor = [UIColor whiteColor];
    [messageShelfButton setBackgroundImage:shelfImage forState:UIControlStateNormal];
    [messageShelfButton addTarget:self action:@selector(messageShelfAction:) forControlEvents:UIControlEventTouchUpInside];
    self.messageShelfItem = [[UIBarButtonItem alloc] initWithCustomView:messageShelfButton];
    
    UIButton *phoneCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneCallButton setFrame:CGRectMake(0, 0, 20, 20)];
    [phoneCallButton setBackgroundImage:[UIImage imageNamed:@"icon-phone-call"] forState:UIControlStateNormal];
    [phoneCallButton addTarget:self action:@selector(phoneCall:) forControlEvents:UIControlEventTouchUpInside];
    self.phoneCallItem = [[UIBarButtonItem alloc] initWithCustomView:phoneCallButton];
    
    if (self.roomType == ChatRoomTypeForStory) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.settingItem,fixedSpace,self.messageShelfItem,nil];
    } else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.settingItem,fixedSpace,self.messageShelfItem,fixedSpace,self.phoneCallItem,nil];
    }
}

- (void)customTitleView {
    if (self.roomType == ChatRoomTypeForRoom) {
        self.title = [TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic];
    } else if (self.roomType == ChatRoomTypeForStory) {
    } else{
        self.title = [TBUtility getFinalUserNameWithMOUser:self.currentToMember];
    }
}

- (void)initTableLoadingView {
    //set footview for load history
    loadingFooterView = [[TBFooterView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    self.loadingHeaderView = loadingFooterView;
    //set Header for newest
    TBFooterView *tempHeaderView = [[TBFooterView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    self.loadingFooterView = tempHeaderView;
}

- (void)initAndLoadData {
    //All message  data  array
    self.chatDataArray = [[NSMutableArray alloc]init];
    self.messageIdToFavoriteId = [[NSMutableDictionary alloc] init];
    //newest message Array;
    self.neweastMessageArray = [[NSMutableArray alloc] init];
    self.searchUnreadNum = 0;
    //current room members
    self.currentRoomMembers = [[NSMutableArray alloc]init];
    //preview related
    self.previewItems = [[NSMutableArray alloc]init];
    //avatar at member related
    self.avatarAtMemberArray = [[NSMutableArray alloc] init];
    //deal for photobroswer
    self.morePhotos = [[NSMutableArray alloc]init];
    
    //load data for different style
    if (self.chatStyle == ChatStyleSearch) {
        [self getNeighborhoodMessage];
    } else {
        self.canLoadNewest = NO;
        [self fetchData];
        if (self.chatStyle == ChatStyleLeft) {
            self.textInputbar.hidden = YES;
        }
    }
    
    //chat title
    if (self.roomType == ChatRoomTypeForRoom) {
        self.title = [TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic];
    } else if (self.roomType == ChatRoomTypeForStory) {
        self.currentStory = [TBUtility currentAppDelegate].currentStory;
        self.title = self.currentStory.title;
    }
    else{
        self.title = [TBUtility getFinalUserNameWithMOUser:self.currentToMember];
    }
}

#pragma mark - View lifecycle

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [TBUtility currentAppDelegate].currentChatViewController = self;
    [self registerPrefixesForAutoCompletion:@[@"@"]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self customTitleView];
    });
    [self commonInit];
    [self initAndLoadData];
    //register notifications
    [self registerNotifications];
    [self checkDraft];
}

- (void)checkDraft {
    NSString *draft = [self chatDraft];
    if (draft.length > 0) {
        self.textInputbar.textView.text = draft;
        [self.textInputbar.textView becomeFirstResponder];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    DDLogDebug(@"viewDidLayoutSubviews");
    if ([self.tableView slk_canScrollToBottom] && self.isReloadTableView) {
        DDLogDebug(@"self.bounds.size.height1: %f",self.tableView.bounds.size.height);
        CGFloat offSetY = CGRectGetHeight(self.tableView.tableHeaderView.frame) - 30;
        CGPoint bottomOffset = CGPointMake(0.0, self.tableView.contentSize.height - self.tableView.bounds.size.height + offSetY);
        if (self.chatDataArray == 0) {
            [self.tableView setContentOffset:CGPointZero animated:NO];
        } else {
            [self.tableView setContentOffset:bottomOffset animated:NO];
        }
        self.isReloadTableView = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
        }];
    } else{
        [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    }
    
    [self.navigationController.navigationBar setAlpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    chatTintColor = [UIColor jl_redColor];
    self.textView.didNotResignFirstResponder = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.showKeyboardWhenViewDidAppear) {
        [self.textView becomeFirstResponder];
        self.showKeyboardWhenViewDidAppear = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.isReloadTableView = NO;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    [super viewWillDisappear:animated];
    // Stops the keyboard from being dismissed during the navigation controller's "swipe-to-pop"
    self.textView.didNotResignFirstResponder = self.isMovingFromParentViewController;
    
    //deal for recording
    if (recordAudio.recorder.isRecording) {
        [self speakTouchUpInside:nil];
    }
    
    //deal for draft
    [self updateDraftIfNeeded:self.textInputbar.textView.text];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //clear memory cache
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)dealloc
{
    [self refreshTabBarbadgeWithReduceNum:1];
    
    if (recordAudio.avPlayer.playing) {
        [recordAudio.avPlayer stop];
    }
    
    [self unregisterNotifications];

    _textInputbar = nil;
    _registeredPrefixes = nil;
    _singleTapGesture = nil;
    _scrollViewHC = nil;
    _textInputbarHC = nil;
    _textInputbarHC = nil;
    _keyboardHC = nil;
}

#pragma mark - Custom Accessors

#pragma mark - Guide

- (void)guideView {
    if ([GuideHelper checkIsNeedGuideByKey:kGuideMessageShelfButtonInChat]) {
        MessageShelfButtonGuideView *guideView = [[MessageShelfButtonGuideView alloc] init];
        [guideView show];
    }
}

- (StoryView *)storyView {
    if (!_storyView) {
        _storyView = [[StoryView alloc] initWithFrame:self.view.frame withStory:self.currentStory];
    }
    return _storyView;
}

- (JLStoryView *)storyDisplayView {
    if (!_storyDisplayView) {
        _storyDisplayView = [[JLStoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) story:self.currentStory];
        _storyDisplayView.parentViewController = self;
    }
    return _storyDisplayView;
}

#pragma mark - Getters

- (SLKTextInputbar *)textInputbar
{
    if (!_textInputbar)
    {
        _textInputbar = [SLKTextInputbar new];
        _textInputbar.translatesAutoresizingMaskIntoConstraints = NO;
        _textInputbar.translucent = NO;
        _textInputbar.controller = self;
        
        [_textInputbar.leftButton addTarget:self action:@selector(didPressVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
        [_textInputbar.centerButton addTarget:self action:@selector(didPressEmojiButton:) forControlEvents:UIControlEventTouchUpInside];
        [_textInputbar.rightButton addTarget:self action:@selector(didPressCameraButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_textInputbar.speakButton addTarget:self action:@selector(speakTapDown:) forControlEvents:UIControlEventTouchDown];
        [_textInputbar.speakButton addTarget:self action:@selector(speakDragOutside:) forControlEvents:UIControlEventTouchDragExit];
        [_textInputbar.speakButton addTarget:self action:@selector(speakDragInside:) forControlEvents:UIControlEventTouchDragEnter];
        [_textInputbar.speakButton addTarget:self action:@selector(speakTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_textInputbar.speakButton addTarget:self action:@selector(speakTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _textInputbar;
}

- (SLKTextView *)textView
{
    return self.textInputbar.textView;
}

- (UIButton *)leftButton
{
    return self.textInputbar.leftButton;
}

- (UIButton *)centerButton
{
    return self.textInputbar.centerButton;
}

- (UIButton *)rightButton
{
    return self.textInputbar.rightButton;
}

- (UIButton *)speakButton {
    return self.textInputbar.speakButton;
}

- (CGFloat)deltaInputbarHeight
{
    return self.textView.intrinsicContentSize.height-self.textView.font.lineHeight;
}

- (CGFloat)minimumInputbarHeight
{
    return self.textInputbar.intrinsicContentSize.height;
}

- (CGFloat)inputBarHeightForLines:(NSUInteger)numberOfLines
{
    CGFloat height = [self deltaInputbarHeight];
    
    height += roundf(self.textView.font.lineHeight*numberOfLines);
    height += self.textInputbar.contentInset.top+self.textInputbar.contentInset.bottom;
    
    return height;
}

- (CGFloat)appropriateInputbarHeight
{
    CGFloat height = 0.0;
    
    if (self.textView.numberOfLines == 1) {
        height = [self minimumInputbarHeight];
    }
    else if (self.textView.numberOfLines < self.textView.maxNumberOfLines) {
        height += [self inputBarHeightForLines:self.textView.numberOfLines];
    }
    else {
        height += [self inputBarHeightForLines:self.textView.maxNumberOfLines];
    }
    
    if (height < [self minimumInputbarHeight]) {
        height = [self minimumInputbarHeight];
    }
    
    return roundf(height);
}

- (CGFloat)appropriateKeyboardHeight:(NSNotification *)notification
{
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self checkForExternalKeyboardInNotification:notification];
    
    // Return 0 if an external keyboard has been detected
    if (self.isExternalKeyboard) {
        return 0.0;
    }
    
    CGFloat keyboardHeight = 0.0;
    CGFloat tabBarHeight = ([self.tabBarController.tabBar isHidden] || self.hidesBottomBarWhenPushed) ? 0.0 : CGRectGetHeight(self.tabBarController.tabBar.frame);
    
    // The height of the keyboard if showing
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        keyboardHeight = MIN(CGRectGetWidth(endFrame), CGRectGetHeight(endFrame));
        keyboardHeight -= tabBarHeight;
    }
    // The height of the keyboard if sliding
    else if ([notification.name isEqualToString:SCKInputAccessoryViewKeyboardFrameDidChangeNotification]) {
        
        if (UI_IS_IOS8_AND_HIGHER || !UI_IS_LANDSCAPE) {
            keyboardHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
        else {
            keyboardHeight = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        }
        
        keyboardHeight -= endFrame.origin.y;
        keyboardHeight -= tabBarHeight;
    }
    
    if (keyboardHeight < 0) {
        keyboardHeight = 0.0;
    }
    
    return keyboardHeight;
}

- (void)checkForExternalKeyboardInNotification:(NSNotification *)notification
{
    CGRect beginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect keyboardFrame = CGRectZero;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        keyboardFrame = [self.view convertRect:[self.view.window convertRect:endFrame fromWindow:nil] fromView:nil];
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        keyboardFrame = [self.view convertRect:[self.view.window convertRect:beginFrame fromWindow:nil] fromView:nil];
    }
    
    if (!self.isMovingKeyboard) {
        _externalKeyboard = keyboardFrame.origin.y + keyboardFrame.size.height > self.view.bounds.size.height;
    }
    
    if (CGRectIsNull(keyboardFrame)) {
        _externalKeyboard = NO;
    }
}

- (CGFloat)appropriateScrollViewHeight
{
    CGFloat topOffset;
    if (self.roomType == ChatRoomTypeForStory) {
        topOffset = CGRectGetHeight(self.storyDisplayView.frame);
    } else {
        topOffset = 0;
    }
    CGFloat height = self.view.bounds.size.height - topOffset;
    height -= self.keyboardHC.constant;
    height -= self.textInputbarHC.constant;
    if (height < 0) return 0;
    else return roundf(height);
}

-(AGEmojiKeyboardView *)emojiKeyboardView
{
    if (!_emojiKeyboardView) {
        
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216) dataSource:self];
        _emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emojiKeyboardView.delegate = self;
    }
    return _emojiKeyboardView;
}

- (NSMutableArray *)photos {
    NSMutableArray *tempAllPhotos = [[NSMutableArray alloc]init];
    for (TBMessage *model in self.chatDataArray) {
        for (TBAttachment *tempAttchment in model.attachments) {
            NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
            if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                NSString *fileName = (NSString *)tempAttchment.data[kFileName];
                NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
                NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
                MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
                photo.caption = fileName;
                photo.messageID = model.id;
                photo.creatorID = model.creatorID;
                photo.tagsArray = model.tags;
                [tempAllPhotos addObject:photo];
            }
        }
    }
    _photos = tempAllPhotos;
    
    return _photos;
}

- (NSMutableArray *)currentRoomMembers {
    if (_currentRoomMembers) {
        NSArray *memberArray;
        if (self.roomType == ChatRoomTypeForStory) {
            NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
            NSArray *userIds = [TBUtility currentAppDelegate].currentStory.members;
            memberArray = [MOUser findUsersWithIds:userIds NotIncludeIds:@[currentUserID]];
        } else if (self.roomType == ChatRoomTypeForTeamMember) {
            memberArray = @[self.currentToMember];
        } else {
            memberArray = [MOUser findTopicMembersExceptSelfAndSortByNameWithTopicId:[TBUtility currentAppDelegate].currentRoom.id];
        }
        //get members
        NSMutableArray *tempTBUserArray  =[NSMutableArray array];
        [memberArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TBUser *member = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:obj error:NULL];
            [tempTBUserArray addObject:member];
        }];
        _currentRoomMembers = tempTBUserArray;
    }
    return _currentRoomMembers;
}

#pragma mark - Setters

- (void)setScrollViewProxy:(UIScrollView *)scrollView
{
    if (self.scrollViewProxy) {
        return;
    }
    _scrollViewProxy = scrollView;
}

- (void)setbounces:(BOOL)bounces
{
    _bounces = bounces;
}

- (void)setAutoCompleting:(BOOL)autoCompleting
{
    if (self.autoCompleting == autoCompleting) {
        return;
    }
    
    _autoCompleting = autoCompleting;
    
    self.scrollViewProxy.scrollEnabled = !autoCompleting;
    
    // Updates the iOS8 QuickType bar mode based on the keyboard height constant
    if (UI_IS_IOS8_AND_HIGHER) {
        [self updateQuicktypeBarMode];
    }
}

- (void)updateQuicktypeBarMode
{
    CGFloat quicktypeBarHeight = self.keyboardHC.constant-minimumKeyboardHeight();
    
    // Updates the QuickType bar mode based on the keyboard height constant
    self.quicktypeBarMode = SLKQuicktypeBarModeForHeight(quicktypeBarHeight);
}

- (void)setQuicktypeBarMode:(SLKQuicktypeBarMode)quicktypeBarMode
{
    _quicktypeBarMode = quicktypeBarMode;
    
    BOOL shouldHide = quicktypeBarMode == SLKQuicktypeBarModeExpanded  && self.autoCompleting;
    
    // Skips if the QuickType Bar is minimised
    if (quicktypeBarMode == SLKQuicktypeBarModeCollapsed) {
        return;
    }
    
    // Hides the iOS8 QuicktypeBar if visible and auto-completing mode is on
    [self.textView disableQuicktypeBar:shouldHide];
}

- (void)setKeyboardPanningEnabled:(BOOL)enabled
{
    if (self.keyboardPanningEnabled == enabled) {
        return;
    }
    
    _keyboardPanningEnabled = enabled;
    self.scrollViewProxy.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)setInverted:(BOOL)inverted
{
    if (self.isInverted == inverted) {
        return;
    }
    
    _inverted = inverted;
    self.scrollViewProxy.transform = CGAffineTransformMake(1, 0, 0, inverted ? -1 : 1, 0, 0);
}

- (void)setKeyboardStatus:(SLKKeyboardStatus)status
{
    // Skips if trying to update the same status
    if (self.keyboardStatus == status) {
        return;
    }
    
    // Skips illogical conditions
    if ((self.keyboardStatus == SLKKeyboardStatusDidShow && status == SLKKeyboardStatusWillShow) ||
        (self.keyboardStatus == SLKKeyboardStatusDidHide && status == SLKKeyboardStatusWillHide)) {
        return;
    }
    
    _keyboardStatus = status;
    [self didChangeKeyboardStatus:status];
}

#pragma mark - IBActions

- (IBAction)messageShelfAction:(id)sender {
    NSMutableDictionary *filterDictionary = [NSMutableDictionary dictionary];
    if (self.roomType == ChatRoomTypeForRoom) {
        [filterDictionary setObject:[TBUtility currentAppDelegate].currentRoom.id forKey:@"_roomId"];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        [filterDictionary setObject:self.currentStory.id forKey:@"_storyId"];
    }
    else{
        [filterDictionary setObject:self.currentToMember.id forKey:@"_toId"];
    }
    
    ItemsViewController *itemsViewController = [[UIStoryboard storyboardWithName:kItemsStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ItemsViewController"];
    itemsViewController.filterDictionary = filterDictionary;
    itemsViewController.filterNameLabel.text = self.title;
    [self.navigationController pushViewController:itemsViewController animated:YES];
}

- (IBAction)SettingAction:(UIBarButtonItem *)sender {
    if (self.roomType == ChatRoomTypeForTeamMember) {
        [self jumpToMemberInfoWithMOUser:self.currentToMember];
    } else if (self.roomType == ChatRoomTypeForRoom) {
        [self performSegueWithIdentifier:@"showTopicSettingVC" sender:nil];
    } else if (self.roomType == ChatRoomTypeForStory) {
        TopicSettingController *topicSettingVC = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"TopicSettingController"];
        topicSettingVC.isStorySetting = YES;
        [self.navigationController pushViewController:topicSettingVC animated:YES];
    }
}

- (IBAction)phoneCall:(UIBarButtonItem *)sender {
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserKey];
    MOUser *currentUser = [MOUser findFirstWithId:currentUserID];
    if (currentUser.phoneForLogin == nil) {
        BindAccountViewController *bindVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"BindAccountViewController"];
        bindVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:bindVC animated:YES];
        return;
    }
    if (self.roomType == ChatRoomTypeForTeamMember) {
        if (self.currentToMember.phoneForLogin) {
            CallingViewController *callingVC = [[CallingViewController alloc] initWithNibName:@"CallingViewController" bundle:nil];
            [callingVC callUser:self.currentToMember];
            [self presentViewController:callingVC animated:NO completion:nil];
        } else {
            [self showBindMobileRemindView];
        }
    } else {
        UINavigationController *temNav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"addMemberToTopicNav"];
        [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
        AddTopicMemberViewController *tempVC = (AddTopicMemberViewController *)[temNav.viewControllers objectAtIndex:0];
        tempVC.isCalling = YES;
        tempVC.currentRoom = self.currentRoom;
        tempVC.phoneCallDelegate = self;
        [self presentViewController:temNav animated:YES completion:^{}];
    }
    
}

- (IBAction)joinTopic:(id)sender {
    if (self.isArchived) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else if(self.isPreView) {
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager POST:[NSString stringWithFormat:@"rooms/%@/join", [TBUtility currentAppDelegate].currentRoom.id]
           parameters:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  DDLogVerbose(@"Successfully joined topic");
                  [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                      NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                      MORoom *moRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                      moRoom.isQuit = [NSNumber numberWithBool:NO];
                  } completion:^(BOOL success, NSError *error) {
                      [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomJoin object:nil];
                      self.isPreView = NO;
                      self.keyboardHC.constant = 0;
                      [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                          [self.view layoutIfNeeded];
                          self.previewPopView.alpha = 0.0f;
                          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                      } completion:^(BOOL finished) {
                          [self.previewPopView removeFromSuperview];
                          self.settingItem.enabled = YES;
                      }];
                  }];
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
                  [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
              }];
    }
}

- (void)jumpToMemberInfoWithMOUser:(MOUser *)user {
    MeInfoViewController *temMeInfoVC = (MeInfoViewController *)[[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"MeInfoViewController"];
    temMeInfoVC.user = user;
    temMeInfoVC.isFromSetting = NO;
    temMeInfoVC.renderColor = chatTintColor;
    [self.navigationController pushViewController:temMeInfoVC animated:YES];
}

#pragma mark - Private Method



#pragma mark - Subclassable Methods

- (void)presentKeyboard:(BOOL)animated
{
    if (![self.textView isFirstResponder])
    {
        if (!animated)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.0];
            [UIView setAnimationDelay:0.0];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            
            [self.textView becomeFirstResponder];
            
            [UIView commitAnimations];
        }
        else {
            [self.textView becomeFirstResponder];
        }
    }
}

- (void)dismissKeyboard:(BOOL)animated
{
    if ([self.textView isFirstResponder])
    {
        if (!animated)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.0];
            [UIView setAnimationDelay:0.0];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            
            [self.textView resignFirstResponder];
            
            [UIView commitAnimations];
        }
        else {
            [self.textView resignFirstResponder];
        }
    }
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status {
    // No implementation here. Meant to be overriden in subclass.
}

- (void)textWillUpdate {
    // No implementation here. Meant to be overriden in subclass.
}

- (void)textDidUpdate:(BOOL)animated {
    CGFloat inputbarHeight = [self appropriateInputbarHeight];
    if (inputbarHeight != self.textInputbarHC.constant) {
        self.textInputbarHC.constant = inputbarHeight;
        self.scrollViewHC.constant = [self appropriateScrollViewHeight];
        [self adjustNewLayoutWithDuration:0.2];
    }
}

- (void)adjustNewLayoutWithDuration:(NSTimeInterval)duration {
    CGSize beforeContentSize = self.tableView.contentSize;
    CGFloat beforeHeight = self.tableView.frame.size.height;
    CGFloat tableviewChangedHeight = beforeHeight - self.scrollViewHC.constant;
    CGFloat beforeOffSetY = self.tableView.contentOffset.y;
    [UIView animateWithDuration:duration delay:0 options:7 animations:^{
        [self.view layoutIfNeeded];
        if (beforeContentSize.height > self.tableView.frame.size.height) {
            CGFloat extendHeight = beforeContentSize.height - beforeHeight;
            if (extendHeight > 0) {
                extendHeight = 0;
            }
            self.tableView.contentOffset = CGPointMake(0, beforeOffSetY + tableviewChangedHeight + extendHeight);
        }
    } completion:NULL];
}

- (BOOL)canShowTypeIndicator
{
    // Don't show if the text is being edited or auto-completed.
    if (self.isEditing || self.isAutoCompleting) {
        return NO;
    }
    
    // Don't show if the content offset is not at top (when inverted) or at bottom (when not inverted)
    if ((self.isInverted && ![self.scrollViewProxy slk_isAtTop]) || (!self.isInverted && ![self.scrollViewProxy slk_isAtBottom])) {
        return NO;
    }
    
    return YES;
}

- (BOOL)canShowAutoCompletion
{
    return NO;
}

- (CGFloat)heightForAutoCompletionView
{
    return 0.0;
}

- (CGFloat)maximumHeightForAutoCompletionView
{
    return 140.0;
}

- (void)didPressReturnKey:(id)sender
{
    [self performRightAction];
}

- (void)didPressCommandZKeys:(id)sender
{
    UIKeyCommand *keyComamnd = (UIKeyCommand *)sender;
    
    if ((keyComamnd.modifierFlags & UIKeyModifierShift) > 0) {
        
        if ([self.textView.undoManager canRedo]) {
            [self.textView.undoManager redo];
        }
    }
    else if ([self.textView.undoManager canUndo]) {
        [self.textView.undoManager undo];
    }
}

- (void)didPressEscapeKey:(id)sender
{
    if (self.isAutoCompleting) {
        [self cancelAutoCompletion];
        return;
    }
    
    [self dismissKeyboard:YES];
}

- (void)didPasteImage:(UIImage *)image
{
    // No implementation here. Meant to be overriden in subclass.
}

- (void)willRequestUndo
{
    UIAlertView *alert = [UIAlertView new];
    [alert setTitle:NSLocalizedString(@"Undo Typing", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Undo", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [alert setCancelButtonIndex:1];
    [alert setDelegate:self];
    [alert show];
}

#pragma mark - InputBar Button Actions
- (void)didPressVoiceButton:(id)sender {
    if (!self.textView.hidden) {
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
        }
        [self.leftButton setImage:[UIImage imageNamed:@"icon-keyboard"] forState:UIControlStateNormal];
        self.textView.hidden = YES;
        self.speakButton.hidden = NO;
    }
    else
    {
        if (!self.textView.isFirstResponder) {
            [self.textView becomeFirstResponder];
        }
        [self.leftButton setImage:[UIImage imageNamed:@"icon-voice"] forState:UIControlStateNormal];
        self.textView.hidden = NO;
        self.speakButton.hidden = YES;
    }
    
    if (self.textView.inputView != nil) {
        self.textView.inputView = nil;
        [self.centerButton setImage:[UIImage imageNamed:@"icon-emoji"] forState:UIControlStateNormal];
    }
}

- (void)didPressCameraButton:(id)sender
{
    NSTimeInterval delay = 0;
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
        delay = 0.2;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showBRNImagePickerSheet];
    });
}

- (void)showBRNImagePickerSheet {
    if (iOS8) {
        PHAuthorizationStatus authorization = [PHPhotoLibrary authorizationStatus];
        if (authorization == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self didPressCameraButton:nil];
            }];
            return;
        }
        if (authorization == PHAuthorizationStatusAuthorized) {
            BRNImagePickerSheet *sheet = [[BRNImagePickerSheet alloc]init];
            sheet.numberOfButtons = 3;
            sheet.delegate = self;
            sheet.tintColor = chatTintColor;
            dispatch_async(dispatch_get_main_queue(), ^{
                [sheet showInView:self.view];
            });
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"An error occurred", @"An error occurred") message:NSLocalizedString(@"Talk needs access to the camera roll", @"Talk needs access to the camera roll") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
        [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        }];
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Choose From Library", @"Choose From Library") withBlock:^(NSInteger theButtonIndex) {
            [self pickerPictureFromLibrary];
        }];
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Take a Photo", @"Take a Photo") withBlock:^(NSInteger theButtonIndex) {
            [self takePictureWith:UIImagePickerControllerSourceTypeCamera];
        }];
        [actionSheet showInView:self.view];
    }
}

- (void)didPressEmojiButton:(id)sender
{
    //deal for voice
    if (self.textView.hidden) {
        [self.leftButton setImage:[UIImage imageNamed:@"icon-voice"] forState:UIControlStateNormal];
        self.textView.hidden = NO;
        self.speakButton.hidden = YES;
    }
    
    if (self.textView.inputView != nil) {
        self.textView.inputView = nil;
        [self.centerButton setImage:[UIImage imageNamed:@"icon-emoji"] forState:UIControlStateNormal];
    } else {
        self.textView.inputView = self.emojiKeyboardView;
        [self.centerButton setImage:[UIImage imageNamed:@"icon-keyboard"] forState:UIControlStateNormal];
    }
    
    if (!self.textView.isFirstResponder) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textView reloadInputViews];
    }
}

- (void)speakTapDown:(id)sender {
    DDLogDebug(@"Speak tap down");
    [self setViewUserInterfaceEnable:NO];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        hasRecordPermission = granted;
    }];
    if (!hasRecordPermission) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Record permission", @"No Record permission")];
        return;
    }
    
    self.voiceRemindImageView.image = [UIImage imageNamed:@"icon-voice-speak"];
    self.voiceReminderLabel.text = NSLocalizedString(@"Slide up to cancel", @"Slide up to cancel");
    [self.speakButton setBackgroundColor:[UIColor tb_borderColor]];
    self.voiceReminderView.hidden = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startRecord];
        });
    });
}

- (void)speakTouchUpInside:(id)sender {
    DDLogDebug(@"speakTouchUpInside");
    [self setViewUserInterfaceEnable:YES];
    if (!hasRecordPermission) {
        return;
    }
    
    [self.speakButton setBackgroundColor:[UIColor whiteColor]];
    self.voiceReminderView.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopRecord];
        });
    });
}

- (void)speakTouchUpOutside:(id)sender {
    DDLogDebug(@"speakTouchUpOutside");
    [self setViewUserInterfaceEnable:YES];
    if (!hasRecordPermission) {
        return;
    }
    
    [self.speakButton setBackgroundColor:[UIColor whiteColor]];
    self.voiceReminderView.hidden = YES;
    DDLogDebug(@"Hide voiceReminderView ");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancelRecordWithISRecording:YES];
        });
    });
}

- (void)setViewUserInterfaceEnable:(BOOL)enable {
    self.navigationController.navigationBar.userInteractionEnabled = enable;
    self.leftButton.userInteractionEnabled = enable;
    self.centerButton.userInteractionEnabled = enable;
    self.rightButton.userInteractionEnabled = enable;
}

- (void)speakDragOutside:(id)sender {
    DDLogDebug(@"speakDragOutside");
    self.voiceRemindImageView.image = [UIImage imageNamed:@"icon-voice-trash"];
    self.voiceReminderLabel.text = NSLocalizedString(@"Release to cancel", @"Release to cancel");
}

- (void)speakDragInside:(id)sender {
    DDLogDebug(@"speakDragInside");
    self.voiceRemindImageView.image = [UIImage imageNamed:@"icon-voice-speak"];
    self.voiceReminderLabel.text = NSLocalizedString(@"Slide up to cancel", @"Slide up to cancel");
}


#pragma mark - Voice related methods

-(void)startRecord {
    [recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    curAudio=nil;;
    
    //start timer
    self.currentPlaySecond = 0;
    if (self.voiceTimer) {
        [self.voiceTimer invalidate];
        self.voiceTimer = nil;
    }
    self.voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateSendingVoiceCell:) userInfo:nil repeats:YES];
    
    //update tableview
    self.sendingVoiceMessage = [self generateVoiceMessage];
    [self insertNewMessage:self.sendingVoiceMessage];
}

-(void)stopRecord {
    if (!recordAudio.recorder.isRecording) {
        return;
    }
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    NSURL *url = [recordAudio stopRecord];
    //stop timer
    [self.voiceTimer invalidate];
    
    endRecordTime -= startRecordTime;
    if (endRecordTime < 1.10f) {
        [self cancelRecordWithISRecording:NO];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Message too short", @"Message too short")];
        return;
    }
    if (url != nil) {
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);
        if (curAudio) {
            curAudio = [curAudio copy];
        }
    }
    if (curAudio.length > 0) {
        NSTimeInterval duration = [RecordAudio getAudioTime: curAudio];
        if (duration < 1.10f) {
            [self cancelRecordWithISRecording:NO];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Message too short", @"Message too short")];
            return;
        } else {
            [self uploadVoiceWithData:curAudio andDuration:duration];
        }
    }
}

- (void)cancelRecordWithISRecording:(BOOL)recording {
    DDLogDebug(@"cancelRecord");
    if (recording) {
        if (!recordAudio.recorder.isRecording) {
            return;
        }
    }
    [recordAudio cancelRecord];
    
    //stop timer
    [self.voiceTimer invalidate];
    self.currentPlaySecond = 0;
    
    NSIndexPath *voicePath = [NSIndexPath indexPathForRow:0 inSection:[self.chatDataArray indexOfObject:self.sendingVoiceMessage]];
    //update tableview
    [self.tableView beginUpdates];
    [self.chatDataArray removeObject:self.sendingVoiceMessage];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:voicePath.section] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)updateSendingVoiceCell:(NSTimer *)timer {
    self.currentPlaySecond+=0.5;
    DDLogDebug(@"sending seconds: %2f",self.currentPlaySecond);
    
    NSIndexPath *voicePath = [NSIndexPath indexPathForRow:0 inSection:[self.chatDataArray indexOfObject:self.sendingVoiceMessage]];
    TBVoiceSendCell *voiceCell = (TBVoiceSendCell *)[self.tableView cellForRowAtIndexPath:voicePath];
    voiceCell.durationLabel.text = [TBUtility getTimeStringWithDuration:self.currentPlaySecond];
    //update  cell length
    int totalDuration = self.currentPlaySecond;
    int minLength = 1;
    if (totalDuration <= minLength) {
        voiceCell.voiceLengthConstraint.constant = voiceMinLength;
        voiceCell.progressLengthConstraint.constant = voiceMinLength;
    } else if (totalDuration > 60) {
        voiceCell.voiceLengthConstraint.constant = voiceMaxLength;
        voiceCell.progressLengthConstraint.constant = voiceMaxLength;
    }
    else {
        voiceCell.voiceLengthConstraint.constant = voiceMinLength + (voiceMaxLength - voiceMinLength)/(60 - minLength) * (totalDuration - minLength);
        voiceCell.progressLengthConstraint.constant = voiceMinLength + (voiceMaxLength - voiceMinLength)/(60 - minLength) * (totalDuration - minLength);
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
        [voiceCell layoutIfNeeded];
    } completion:nil];
    
    [self detectionVoice];
}

- (void)detectionVoice {
    if ([self.voiceReminderLabel.text isEqualToString:NSLocalizedString(@"Release to cancel", @"Release to cancel")]) {
        return;
    }

    int second = self.currentPlaySecond * 2;
    int remainder = second % 3;
    switch (remainder) {
        case 0:
            [self.voiceRemindImageView setImage:[UIImage imageNamed:@"icon-voice-speak-low"]];
            break;
        case 1:
            [self.voiceRemindImageView setImage:[UIImage imageNamed:@"icon-voice-speak"]];
            break;
        case 2:
            [self.voiceRemindImageView setImage:[UIImage imageNamed:@"icon-voice-speak-loud"]];
            break;
            
        default:
            break;
    }
}

- (IBAction)PlayVoice:(id)sender {
    if(curAudio.length>0)[recordAudio play:curAudio];
}

- (void)uploadVoiceWithData:(NSData *)data andDuration:(NSTimeInterval)duration {
    NSString *voicePathName = [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"amr"];
    self.sendingVoiceMessage.duration = duration;
    self.sendingVoiceMessage.voiceLocalAMRPath = [TBUtility getVoiceLocalPathWithFileKey:[[voicePathName componentsSeparatedByString:@"."] firstObject]];
    self.sendingVoiceMessage.sendStatus = sendStatusSending;
    //save voice
    BOOL result = [data writeToFile:self.sendingVoiceMessage.voiceLocalAMRPath atomically:YES];
    if (result) {
        DDLogDebug(@"!!!!!!!!!!!!! success to write data to file......");
    }
    [MessageSendEngine saveGeneratedMessageToDBWith:self.sendingVoiceMessage];
    
    NSIndexPath *voiceCellPath = [NSIndexPath indexPathForRow:0 inSection:[self.chatDataArray indexOfObject:self.sendingVoiceMessage]];
    TBVoiceSendCell *sendCell = (TBVoiceSendCell *)[self.tableView cellForRowAtIndexPath:voiceCellPath];
    [sendCell setMessage:self.sendingVoiceMessage];
    NSIndexPath *timeCellPath = [NSIndexPath indexPathForRow:1 inSection:[self.chatDataArray indexOfObject:self.sendingVoiceMessage]];
    TBTimeSendCell *timeCell = (TBTimeSendCell *)[self.tableView cellForRowAtIndexPath:timeCellPath];
    [timeCell setMessage:self.sendingVoiceMessage];
    
    //tell recent sending message
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendingMessageNotification object:self.sendingVoiceMessage];
    
    //send request
    NSMutableDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         nil];
    } else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         self.currentStory.id,@"_storyId",
                         nil];
    } else {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         nil];
    }
    [MessageSendEngine sendVoiceWithData:data Name:voicePathName message:self.sendingVoiceMessage andPatameters:tempParamsDic];
}

#pragma - mark RecordAudioDelegate

-(void)RecordStatus:(int)status {
    if (status==0){
        //Playing
    } else if(status==1){
        //Done
        self.playingVoiceMessage = nil;
    }else if(status==2){
        //Error
        self.playingVoiceMessage = nil;
    }
}

#pragma mark - Auto-Completion Text Processing

- (void)registerPrefixesForAutoCompletion:(NSArray *)prefixes
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.registeredPrefixes];
    
    for (NSString *prefix in prefixes) {
        // Skips if the prefix is not a valid string
        if (![prefix isKindOfClass:[NSString class]] || prefix.length == 0) {
            continue;
        }
        
        // Adds the prefix if not contained already
        if (![array containsObject:prefix]) {
            [array addObject:prefix];
        }
    }
    
    if (_registeredPrefixes) {
        _registeredPrefixes = nil;
    }
    
    _registeredPrefixes = [[NSArray alloc] initWithArray:array];
}

- (void)processTextForAutoCompletion
{
    // Avoids text processing for autocompletion if the registered prefix list is empty.
    if (self.registeredPrefixes.count == 0) {
        return;
    }
    
    NSString *text = self.textView.text;
    
    // No need to process for autocompletion if there is no text to process
    if (text.length == 0) {
        return [self cancelAutoCompletion];
    }
    
    NSRange range;
    NSString *word = [self.textView slk_wordAtCaretRange:&range];
    
    for (NSString *sign in self.registeredPrefixes) {
        
        NSRange keyRange = [word rangeOfString:sign];
        
        if (keyRange.location == 0 || (keyRange.length >= 1)) {
            
            // Captures the detected symbol prefix
            _foundPrefix = sign;
            
            // Used later for replacing the detected range with a new string alias returned in -acceptAutoCompletionWithString:
            _foundPrefixRange = NSMakeRange(range.location, sign.length);
        }
    }
    
    // Cancel autocompletion if the cursor is placed before the prefix
    if (self.textView.selectedRange.location <= _foundPrefixRange.location) {
        return [self cancelAutoCompletion];
    }
    
    if (self.foundPrefix.length > 0) {
        if (range.length == 0 || range.length != word.length) {
            return [self cancelAutoCompletion];
        }
        
        if (word.length > 0) {
            // Removes the first character, containing the symbol prefix
            _foundWord = [word substringFromIndex:1];
            
            // If the prefix is still contained in the word, cancels
            if ([_foundWord rangeOfString:_foundPrefix].location != NSNotFound) {
                return [self cancelAutoCompletion];
            }
        }
        else {
            return [self cancelAutoCompletion];
        }
    }
    else {
        return [self cancelAutoCompletion];
    }
    
    if ([@"@" isEqualToString:self.slkTextViewChangedStr]) {
        DDLogDebug(@"textView.selectedRange:%lu",(unsigned long)self.textView.selectedRange.location);
        UINavigationController *temNav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"chooseAtMemberNav"];
        ChooseAtMemberController *choooseAtVC  = [temNav.viewControllers objectAtIndex:0];
        choooseAtVC.tintColor = chatTintColor;
        if (self.roomType == ChatRoomTypeForStory) {
            choooseAtVC.chooseAtCategory = ChooseAtMemberForStory;
        } else if (self.roomType == ChatRoomTypeForTeamMember) {
            choooseAtVC.chooseAtCategory = ChooseAtMemberForDMS;
            choooseAtVC.chatUser = self.currentToMember;
        } else {
            choooseAtVC.chooseAtCategory = ChooseAtMemberForRoom;
        }
        [self presentViewController:temNav animated:YES completion:^{}];
        self.slkTextViewChangedStr = @"";
    }
}

- (void)cancelAutoCompletion {
    _foundPrefix = nil;
    _foundWord = nil;
    _foundPrefixRange = NSMakeRange(0,0);
    if (self.isAutoCompleting) {
        [self showAutoCompletionView:NO];
    }
    self.autoCompleting = NO;
}

- (void)acceptAutoCompletionWithString:(NSString *)string {
    if (string.length == 0) {
        return;
    }
    SLKTextView *textView = self.textView;
    NSRange range = NSMakeRange(self.foundPrefixRange.location+1, 0);
    NSRange insertionRange = [textView slk_insertText:string inRange:range];
    textView.selectedRange = NSMakeRange(insertionRange.location, 0);
    [self cancelAutoCompletion];
    [textView slk_scrollToCaretPositonAnimated:NO];
}

- (void)hideAutoCompletionView
{
    [self showAutoCompletionView:NO];
}

- (void)showAutoCompletionView:(BOOL)show
{
    CGFloat viewHeight = show ? [self heightForAutoCompletionView] : 0.0;
    
    self.autoCompleting = show;
    
    // If the autocompletion view height is bigger than the maximum height allows, it is reduce to that size. Default 140 pts.
    if (viewHeight > [self maximumHeightForAutoCompletionView]) {
        viewHeight = [self maximumHeightForAutoCompletionView];
    }
    
    CGFloat tableHeight = self.scrollViewHC.constant;
    
    // If the the view controller extends it layout beneath it navigation bar and/or status bar, we then reduce it from the table view height
    if (self.edgesForExtendedLayout == UIRectEdgeAll || self.edgesForExtendedLayout == UIRectEdgeTop) {
        tableHeight -= CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        tableHeight -= self.navigationController.navigationBar.frame.size.height;
    }
    
    // On iPhone, the autocompletion view can't extend beyond the table view height
    if (viewHeight > tableHeight) {
        viewHeight = tableHeight;
    }
    
    [self.view slk_animateLayoutIfNeededWithBounce:self.bounces
                                           options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                                        animations:NULL];
}


#pragma mark - Private Actions

- (void)didTapScrollView:(UIGestureRecognizer *)gesture
{
    // Skips if using an external keyboard
    if (self.isExternalKeyboard) {
        return;
    }
    
    [self dismissKeyboard:YES];
}

- (void)performRightAction
{
    NSArray *actions = [self.rightButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    
    if (actions.count > 0) {
        [self.rightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)insertNewLineBreak
{
    [self.textView slk_insertNewLineBreak];
}

- (void)prepareForInterfaceRotation
{
    [self.view layoutIfNeeded];
    
    if ([self.textView isFirstResponder]) {
        [self.textView slk_scrollToCaretPositonAnimated:NO];
    }
    else {
        [self.textView slk_scrollToBottomAnimated:NO];
    }
}

// refresh recent tableview after update or delete message
-(void)refreshRecentTableView
{
    //tell recentMessageView have send a message
    TBMessage *latestMessage = [self.chatDataArray firstObject];
    if (latestMessage) {
        NSDictionary *latestMessageDic = [MTLJSONAdapter JSONDictionaryFromModel:latestMessage];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageSucceedNotification object:latestMessageDic];
    }
}

- (void)dealNewestMessageForChatStyleSearchWithMessages:(NSArray *)messageArray {
    [self.neweastMessageArray removeAllObjects];
    [messageArray.reverseObjectEnumerator.allObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TBMessage *tempTBMessage  = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:obj error:NULL];
        [self.neweastMessageArray addObject:tempTBMessage];
    }];
}

- (void)showUnreadButton {
    NSString *unreadString = [NSString stringWithFormat:NSLocalizedString(@"Unread Messages", @"Unread Messages"),self.searchUnreadNum];
    
    if (self.unreadButton) {
        [self.unreadButton setTitle:unreadString forState:UIControlStateNormal];
        [self.unreadButton.superview bringSubviewToFront:self.unreadButton];
    } else {
        UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat top = 20.0f;
        UIEdgeInsets imageInsets  = UIEdgeInsetsMake(top, top, top, top);
        UIImage * backgroundImage  = [[UIImage imageNamed:@"icon-unread-backgroud"] resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
        UIImage *arrowImage = [[UIImage imageNamed:@"icon-unread-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [unreadButton setTintColor:[UIColor jl_redColor]];
        [unreadButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [unreadButton setImage:arrowImage forState:UIControlStateNormal];
        [unreadButton setTitle:unreadString forState:UIControlStateNormal];
        [unreadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 16.0, 0, 16.0)];
        [unreadButton addTarget:self action:@selector(readUnread:) forControlEvents:UIControlEventTouchUpInside];
        unreadButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.unreadButton = unreadButton;
        
        [self.view addSubview:self.unreadButton];
        UIView *window = self.view;
        [window addConstraint:[NSLayoutConstraint constraintWithItem:unreadButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8]];
        [window addConstraint:[NSLayoutConstraint constraintWithItem:unreadButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.textInputbar.frame.size.height]];
        [window addConstraint:[NSLayoutConstraint constraintWithItem:unreadButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
    }
}

- (void)readUnread:(UIButton *)sender {
    [self cleanUnreadButton];
    
    if (self.chatStyle == ChatStyleSearch) {
        [self scrollToBottomForChatStyleSearch];
        self.chatStyle = ChatStyleCommon;
    } else {
        [self scrollToBottom];
    }
}

- (void)cleanUnreadButton {
    [self.unreadButton removeFromSuperview];
    self.searchUnreadNum = 0;
}

- (void)scrollToBottomForChatStyleSearch {
    [self.chatDataArray removeAllObjects];
    [self.chatDataArray addObjectsFromArray:self.neweastMessageArray];
    [self.tableView reloadData];
    
    [self scrollToBottom];
    self.canLoadNewest = NO;
}

- (void)scrollToBottom {
    NSInteger section = self.chatDataArray.count -1;
    NSInteger row = [self tableView:self.tableView numberOfRowsInSection:section] -1;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Notification Events

- (void)applicationWillResignActive:(NSNotification *)notification {
    //deal for recording
    if (recordAudio.recorder.isRecording) {
        [self speakTouchUpOutside:nil];
    }
}

- (void)willShowOrHideKeyboard:(NSNotification *)notification
{
    // Skips if textview did refresh only
    if (self.textView.didNotResignFirstResponder) {
        return;
    }
    
    // Skips if is edit message only
    if (isEditingMessage) {
        return;
    }
    
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Checks if it's showing or hidding the keyboard
    BOOL willShow = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    
    // Programatically stops scrolling before updating the view constraints (to avoid scrolling glitch)
    [self.scrollViewProxy slk_stopScrolling];
    
    // Updates the height constraints' constants
    self.keyboardHC.constant = [self appropriateKeyboardHeight:notification];
    self.scrollViewHC.constant = [self appropriateScrollViewHeight];
    
    // Hides autocompletion mode if the keyboard is being dismissed
    if (!willShow && self.isAutoCompleting) {
        [self hideAutoCompletionView];
    }
    
    // Only for this animation, we set bo to bounce since we want to give the impression that the text input is glued to the keyboard.
    [self adjustNewLayoutWithDuration:duration];
    
    // Updates and notifies about the keyboard status update
    self.keyboardStatus = willShow ? SLKKeyboardStatusWillShow : SLKKeyboardStatusWillHide;
}

- (void)didShowOrHideKeyboard:(NSNotification *)notification {
    // Skips if textview did refresh only
    if (self.textView.didNotResignFirstResponder) {
        return;
    }
    
    // Skips if is edit message only
    if (isEditingMessage) {
        return;
    }
    
    // Checks if it's showing or hidding the keyboard
    BOOL didShow = [notification.name isEqualToString:UIKeyboardDidShowNotification];
    // After showing keyboard, check if the current cursor position could diplay autocompletion
    if (didShow) {
        [self processTextForAutoCompletion];
        [self.view addGestureRecognizer:self.singleTapGesture];
        
        if (self.chatStyle == ChatStyleSearch) {
            [self scrollToBottomForChatStyleSearch];
        } else {
            [self.scrollViewProxy slk_scrollToBottomAnimated:YES];
        }
    } else {
        [self.view removeGestureRecognizer:self.singleTapGesture];
    }
    // Updates and notifies about the keyboard status update
    self.keyboardStatus = didShow ? SLKKeyboardStatusDidShow : SLKKeyboardStatusDidHide;
}

- (void)didChangeKeyboardFrame:(NSNotification *)notification {
    // Checking the keyboard height constant helps to disable the view constraints update on iPad when the keyboard is undocked.
    if (![self.textView isFirstResponder] || self.keyboardHC.constant == 0) {
        return;
    }
    
    self.movingKeyboard = self.scrollViewProxy.isDragging;
    
    self.keyboardHC.constant = [self appropriateKeyboardHeight:notification];
    self.scrollViewHC.constant = [self appropriateScrollViewHeight];
    
    if (self.isInverted && self.isMovingKeyboard && !CGPointEqualToPoint(self.scrollViewProxy.contentOffset, _draggingOffset)) {
        self.scrollViewProxy.contentOffset = _draggingOffset;
    }
    
    [self.view layoutIfNeeded];
}

- (void)willChangeTextView:(NSNotification *)notification {
    SLKTextView *textView = (SLKTextView *)notification.object;
    self.slkTextViewChangedStr = [[notification userInfo] objectForKey:@"text"];
    if (![textView isEqual:self.textView]) {
        return;
    }
    [self textWillUpdate];
}

- (void)didChangeTextViewText:(NSNotification *)notification {
    SLKTextView *textView = (SLKTextView *)notification.object;
    if (![textView isEqual:self.textView]) {
        return;
    }
    [self textDidUpdate:YES];
}

- (void)didChangeTextViewContentSize:(NSNotification *)notification {
    if (![self.textView isEqual:notification.object]) {
        return;
    }
    [self textDidUpdate:YES];
}

- (void)didChangeTextViewSelection:(NSNotification *)notification {
    NSRange selectedRange = [notification.userInfo[@"range"] rangeValue];
    if (selectedRange.length == 0 && [self.textView isFirstResponder]) {
        [self processTextForAutoCompletion];
    }
}

- (void)didChangeTextViewPasteboard:(NSNotification *)notification {
    if (![self.textView isFirstResponder]) {
        return;
    }
    UIImage *image = notification.object;
    if ([image isKindOfClass:[UIImage class]]) {
        [self didPasteImage:image];
    }
}

- (void)didShakeTextView:(NSNotification *)notification {
    if (![self.textView isFirstResponder]) {
        return;
    }
    if (self.undoShakingEnabled && self.textView.text.length > 0) {
        [self willRequestUndo];
    }
}

/**
 *  did press send btn to send message
 *
 *  @param notification slackTextView press returnKey notification
 */
-(void)TextViewDidPressReturnKey:(NSNotification *)notification {
    DDLogVerbose(@"CHAT-VC-TITLE:%@",self.title);
    if (self == [TBUtility currentAppDelegate].currentChatViewController) {
        SLKTextView *tempTextView = [notification object];
        [self sendTextMessageToServer:tempTextView.text];
    }
}

/**
 *  send text message to server
 *
 *  @param messageText
 */
-(void)sendTextMessageToServer:(NSString *)messageText {
    //return if no message
    if (messageText.length == 0) {
        return;
    }
    if (messageText.length > 1000) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Text too long", @"Text too long")];
        return;
    }

    //generate a message
    TBMessage *sendingMessage =[[TBMessage alloc]init];
    NSString *tempUUIDStr = [[NSUUID UUID] UUIDString];
    sendingMessage.uuid = tempUUIDStr;
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserKey];
    MOUser *currentMOUser = [MOUser findFirstWithId:currentUserID];
    TBUser *tbuser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:currentMOUser error:nil];
    sendingMessage.creator = tbuser;
    sendingMessage.createdAt = [NSDate date];
    sendingMessage.creatorID = currentUserID;
    sendingMessage.messageStr = messageText;
    sendingMessage.isSend = YES;
    sendingMessage.displayMode = kDisplayModeMessage;
    sendingMessage.cellHeight = [TbChatTableViewCell calculateCellHeightWithMessage:sendingMessage];
    sendingMessage.sendStatus = sendStatusSending;
    sendingMessage.teamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    sendingMessage.numbersOfRows = 2;
    if (self.roomType == ChatRoomTypeForRoom) {
        sendingMessage.roomID = [TBUtility currentAppDelegate].currentRoom.id;
    } else if (self.roomType == ChatRoomTypeForTeamMember) {
        sendingMessage.toID = self.currentToMember.id;
    } else {
        sendingMessage.storyID = self.currentStory.id;
    }
    //save generated message to dataBase
    [MessageSendEngine saveGeneratedMessageToDBWith:sendingMessage];
    
    //clear textview
    [self.textView setText:nil];
    //update tableView
    [self insertNewMessage:sendingMessage];
    
    //send request
    NSString *sendStr = [messageText stringByReplacingEmojiUnicodeWithCheatCodes];
    NSString *regularString  =[self getRegularExpressionFromMessageStr:sendStr];
    [self.avatarAtMemberArray removeAllObjects];
    [self sendTextWithMessageContent:regularString message:sendingMessage andRoomType:self.roomType];
}

- (void)insertNewMessage:(TBMessage *)message {
    [self.chatDataArray addObject:message];
    NSInteger section = self.chatDataArray.count -1;
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationBottom];
    [self scrollToBottom];
}

- (void)sendTextWithMessageContent:(NSString *)regularString message:(TBMessage *)message andRoomType:(ChatRoomType)roomType {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSendingMessageNotification object:message];
    NSDictionary *tempParamsDic;
    if (roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:[TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         regularString,kMessageBody,nil];
    } else if (roomType == ChatRoomTypeForTeamMember)  {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         regularString,kMessageBody,nil];
    } else {
        tempParamsDic = @{
                          @"_storyId":self.currentStory.id,
                          kMessageBody:regularString
                          };
    }
    [MessageSendEngine sendTextMessageToServerWithParameters:tempParamsDic andMessage:message];
}


-(void)selectedAtMember:(NSNotification *)notification {
    NSString *tempStr = [notification object];
    [self acceptAutoCompletionWithString:tempStr];
    self.showKeyboardWhenViewDidAppear = YES;
}

//tap other media not ChatMessageMediaTypeText
-(void)TapOtherMedia:(NSNotification *)notification {
    TBAttachment *attachment =(TBAttachment *)[notification object];
    NSString *fileCategory =  attachment.data[kFileCategory];
    if ([fileCategory isEqualToString:kFileCategoryImage]) {
        // Create browser (must be done each time photo browser is
        // displayed. Photo browser objects cannot be re-used)
        self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        self.browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
        self.browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        self.browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
        self.browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        self.browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        self.browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        self.browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        //browser.wantsFullScreenLayout = YES;// iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
        
        // Optionally set the current visible photo before displaying
        int currentPhotoIndex = -1;
        for (TBMessage *model in self.chatDataArray) {
            BOOL isFound = NO;
            for (TBAttachment *tempAttchment in model.attachments) {
                NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
                if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                    currentPhotoIndex++;
                    NSString *tempAttachmentKey = (NSString *)tempAttchment.data[kFileKey];
                    NSString *attachmentKey = (NSString *)attachment.data[kFileKey];
                    if ([tempAttachmentKey isEqualToString:attachmentKey]) {
                        isFound = YES;
                        break;
                    }
                }
            }
            if (isFound) {
                break;
            }
        }
        [self.browser setCurrentPhotoIndex:currentPhotoIndex];
        // Present
        [self.morePhotos removeAllObjects];
        [self.navigationController pushViewController:self.browser animated:YES];
        
        // Manipulate
        [self.browser showNextPhotoAnimated:YES];
        [self.browser showPreviousPhotoAnimated:YES];
        
    } else {
        // Remote files
        NSURL *filePreviewItemURL = [NSURL URLWithString:attachment.data[kFileDownloadUrl]];
        NSString *fileName = attachment.data[kFileName];
        NSString *fileKey = attachment.data[kFileKey];
        CGFloat fileSize = [attachment.data[kFileSize] floatValue];
        AZAPreviewItem *filePreviewItem = [AZAPreviewItem previewItemWithURL:filePreviewItemURL
                                                                       title:fileName
                                                                       fileKey:fileKey];
        filePreviewItem.fileSize = fileSize;
        [_previewItems removeAllObjects];
        [_previewItems addObjectsFromArray:[NSArray arrayWithObjects:filePreviewItem, nil]];
        // preview controller
        AZAPreviewController *previewController = [[AZAPreviewController alloc] init];
        previewController.navigationController.navigationBar.translucent = NO;
        previewController.dataSource = self;
        previewController.delegate = self;
        [self.navigationController pushViewController:previewController animated:YES];
    }
}

//send message result deal
- (void)sendMessageSucceed:(NSNotification *)notification {
    if (![notification.object isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray *objectArray = (NSArray *)notification.object;
    TBMessage *sendmessage = [objectArray objectAtIndex:1];
    TBMessage *returnMessage = [objectArray objectAtIndex:2];
    if ([self.chatDataArray containsObject:sendmessage]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateCellWithOriginMessage:sendmessage ReturnMessage:returnMessage];
        });
    } else {
        for (TBMessage *model in self.chatDataArray) {
            if (model.uuid && [model.uuid isEqualToString:sendmessage.uuid]) {
                NSInteger sendSucceedMessageIndex = [self.chatDataArray indexOfObject:model];
                if ([self.chatDataArray containsObject:returnMessage]) {
                    [self.chatDataArray removeObject:model];
                    [self.tableView beginUpdates];
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sendSucceedMessageIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                } else {
                    [self updateCellWithOriginMessage:sendmessage ReturnMessage:returnMessage];
                }
                break;
            }
        }
    }
}

- (void)updateCellWithOriginMessage:(TBMessage *)sendmessage ReturnMessage:(TBMessage *)returnMessage {
    NSInteger sendMessageIndex = [self.chatDataArray indexOfObject:sendmessage];
    if (sendmessage.displayMode == kDisplayModeMessage) {
        [self.chatDataArray replaceObjectAtIndex:sendMessageIndex withObject:returnMessage];
        //update cell
        TBChatSendTableViewCell *updateCell = (TBChatSendTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
        if (sendmessage.mentions.count > 0) {
            updateCell.isMentionMessage = YES;
        }
        [updateCell setMessage:returnMessage];
    } else {
        sendmessage.attachments = returnMessage.attachments;
        sendmessage.id = returnMessage.id;
        sendmessage.sendStatus = sendStatusSucceed;
        if (sendmessage.displayMode == kDisplayModeImage) {
            TBImageSendTableViewCell *imageSendCell = (TBImageSendTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
            [imageSendCell setMessage:sendmessage andAttachment:[sendmessage.attachments firstObject]];
        } else if(sendmessage.displayMode == kDisplayModeSpeech) {
            TBVoiceSendCell *voiceSendCell = (TBVoiceSendCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
            [voiceSendCell setMessage:sendmessage];
        }
    }
    TBTimeCell *timeCell = (TBTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:sendMessageIndex]];
    [timeCell setMessage:returnMessage];
}

- (void)sendMessageFailed:(NSNotification *)notification {
    if (![notification.object isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray *objectArray = (NSArray *)notification.object;
    TBMessage *failedMessage = objectArray.firstObject;
    
    if ([self.chatDataArray containsObject:failedMessage]) {
        NSError *error = [objectArray objectAtIndex:1];
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        
        NSInteger sendMessageIndex = [self.chatDataArray indexOfObject:failedMessage];
        failedMessage.sendStatus = sendStatusFailed;
        //update cell
        if (failedMessage.displayMode == kDisplayModeMessage) {
            TBChatSendTableViewCell *updateCell = (TBChatSendTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
            [updateCell setMessage:failedMessage];
            TBTimeCell *timeCell = (TBTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:sendMessageIndex]];
            [timeCell setMessage:failedMessage];
        } else {
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sendMessageIndex] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    } else {
        for (TBMessage *model in self.chatDataArray) {
            if (model.uuid && [model.uuid isEqualToString:failedMessage.uuid]) {
                NSInteger sendMessageIndex = [self.chatDataArray indexOfObject:model];
                failedMessage.sendStatus = sendStatusFailed;
                //update cell
                TBChatSendTableViewCell *updateCell = (TBChatSendTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
                [updateCell setMessage:failedMessage];
                TBTimeCell *timeCell = (TBTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:sendMessageIndex]];
                [timeCell setMessage:failedMessage];
                
                break;
            }
        }
    }
}

//resend failed message
-(void)resendFailedMessage:(NSNotification *)notification
{
    TBMessage *failedMessage =(TBMessage *)[notification object];
    if (failedMessage.sendStatus != sendStatusFailed) {
        return;
    }
    //update cell
    NSInteger resendMessageIndex = [self.chatDataArray indexOfObject:failedMessage];
    failedMessage.sendStatus = sendStatusSending;
    TBTimeSendCell *updateCell = (TBTimeSendCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:resendMessageIndex]];
    [updateCell setMessage:failedMessage];
    
    //send request
    NSString *sendStr = [failedMessage.messageStr stringByReplacingEmojiUnicodeWithCheatCodes];
    NSString *regularString  =[self getRegularExpressionFromMessageStr:sendStr];
    [self sendTextWithMessageContent:regularString message:failedMessage andRoomType:self.roomType];
}

//resend failed image
-(void)resendFailedImage:(NSNotification *)notification
{
    TBMessage *resendImageMessage =(TBMessage *)[notification object];
    NSInteger resendMessageIndex = [self.chatDataArray indexOfObject:resendImageMessage];
    if (resendImageMessage.sendStatus != sendStatusFailed) {
        return;
    }
    resendImageMessage.sendStatus = sendStatusSending;
    //update cell
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:resendMessageIndex] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    //tell recent sending message
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendingMessageNotification object:resendImageMessage];
    
    //resend to server
    TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
    imageModel.image = resendImageMessage.sendImage;
    TBAttachment *imageAttachment = resendImageMessage.attachments.firstObject;
    imageModel.imageName = imageAttachment.data[kFileName];
    
    //send request
    NSMutableDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [TBUtility currentAppDelegate].currentRoom.id,@"_roomId",nil];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         self.currentStory.id,@"_storyId",nil];
    }
    else {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",nil];
    }
    [MessageSendEngine sendImageWithImageModel:imageModel andMessage:resendImageMessage andPatameters:tempParamsDic];
}

//resend failed voice
-(void)resendFailedVoice:(NSNotification *)notification {
    TBMessage *resendMessage =(TBMessage *)[notification object];
    NSInteger resendMessageIndex = [self.chatDataArray indexOfObject:resendMessage];
    if (resendMessage.sendStatus != sendStatusFailed) {
        return;
    }
    resendMessage.sendStatus = sendStatusSending;
    //update cell
    TBVoiceSendCell *voiceSendCell = (TBVoiceSendCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:resendMessageIndex]];
    [voiceSendCell setMessage:resendMessage];
    TBTimeCell *timeCell = (TBTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:resendMessageIndex]];
    [timeCell setMessage:resendMessage];
    
    //tell recent sending message
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendingMessageNotification object:resendMessage];
    
    //send request
    NSData *voiceData = [NSData dataWithContentsOfFile:resendMessage.voiceLocalAMRPath];
    NSString *fileName = [[NSURL URLWithString:resendMessage.voiceLocalAMRPath] lastPathComponent];
    NSMutableDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         nil];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         self.currentStory.id,@"_storyId",
                         nil];
    }
    else {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         nil];
    }
    [MessageSendEngine sendVoiceWithData:voiceData Name:fileName message:resendMessage andPatameters:tempParamsDic];
}

- (void)acceptSocketMessage:(NSNotification *)notification {
    if (self == [TBUtility currentAppDelegate].currentChatViewController) {
        NSDictionary *mesageDic = [notification object];
        [self parseNewMessageJsonDictionaryAndRefreshMessageTableViewWith:mesageDic withIsSend:NO];
    }
}

- (void)acceptSocketRemove:(NSNotification *)notification {
    NSString *deleteID = [notification object];
    NSUInteger deleteIndex = -1;
    for (TBMessage *model in self.chatDataArray) {
        if ([model.id isEqual:deleteID]) {
            deleteIndex = [self.chatDataArray indexOfObject:model];
            break;
        }
    }
    if (deleteIndex != -1) {
        [self.chatDataArray removeObjectAtIndex:deleteIndex];
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }

    [self refreshRecentTableView];
}

- (void)acceptSocketUpdate:(NSNotification *)notification {
    [self refreshMessageWithNotification:notification];
    [self refreshRecentTableView];
}

- (void)refreshMessageWithNotification:(NSNotification *)notification {
    TBMessage *updateMessage = (TBMessage *)[notification object];
    NSUInteger updateIndex = [self indexForMessage:updateMessage inChatArray:self.chatDataArray];
    if (updateIndex != -1) {
        [self.chatDataArray replaceObjectAtIndex:updateIndex withObject:updateMessage];
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:updateIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

/**
 *  check message in chatArray or not
 *
 *  @param chatArray All current message array
 *  @param message   one TBMessage
 *
 *  @return NSUInteger if returnValue = -1,message not in chat Array ,else in chatArray
 */
- (NSUInteger)indexForMessage:(TBMessage *)message inChatArray:(NSArray *)chatArray  {
    NSString *updateID = message.id;
    NSUInteger updateIndex = -1;
    for (TBMessage *model in chatArray) {
        if ([model.id isEqual:updateID]) {
            updateIndex = [chatArray indexOfObject:model];
            break;
        }
    }
    return updateIndex;
}

//removed by other from current private topic
- (void)leftPrivateRoom:(NSNotification *)notification {
    [UIAlertView showWithTitle:NSLocalizedString(@"Remind", @"Remind")
                       message:[NSString stringWithFormat:NSLocalizedString(@"Removed from topic", @"Removed from topic"),self.currentRoom.topic]
             cancelButtonTitle:nil
             otherButtonTitles:@[NSLocalizedString(@"OK", @"OK")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 0) {
                              [self.navigationController popToRootViewControllerAnimated:YES];
                          }
                      }];
}

- (void)addTagSucceed:(NSNotification *)notification {
    [self refreshMessageWithNotification:notification];
}

// Dynamic type Notification Action
- (void)handleContentSizeCategoryDidChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

// Edit Story
- (void)hasEditedStory {
    self.currentStory = [TBUtility currentAppDelegate].currentStory;
    
    [self.storyView setViewWithStory:self.currentStory];
    [self.titleText setText:self.currentStory.title];
}

//Edit Topic
- (void)hasEditTopicInfo:(NSNotification *)aNotification {
    [self customTitleView];
}

#pragma mark - Helper
/**
 *  convert sendMessage to content string for sendMessage contain @"at"
 *
 *  @param Sendmessage string
 *
 *  @return RegularExpression string
 */
-(NSString *)getRegularExpressionFromMessageStr:(NSString *)sendmessage {
    [self.avatarAtMemberArray addObjectsFromArray:self.currentRoomMembers];
    
    __block NSString *regularExpression = [NSString stringWithString:sendmessage];
    NSArray *atMemberArray = [sendmessage componentsSeparatedByString:@"@"];
    [atMemberArray enumerateObjectsUsingBlock:^(NSString *atName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *allMemeberString = NSLocalizedString(@"Allmembers", nil);
        NSRange allRange = [atName rangeOfString:allMemeberString];
        if (allRange.location == 0) {
            NSString *atString = [NSString stringWithFormat:kAtRegularString,@"all",allMemeberString];
            regularExpression = [regularExpression stringByReplacingOccurrencesOfString:[@"@" stringByAppendingString:allMemeberString] withString:atString];
        }

        __block TBUser *matchestUser;
        __block NSString *matchestFinalName;
        [self.avatarAtMemberArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TBUser *tempUSer = (TBUser *)obj;
            NSString *finalName = [TBUtility getFinalUserNameWithTBUser:tempUSer];
            NSRange userNameRange = [atName rangeOfString:finalName];
            if (userNameRange.location != NSNotFound) {
                if (matchestUser) {
                    if (finalName.length > matchestFinalName.length) {
                        matchestUser = tempUSer;
                        matchestFinalName = finalName;
                    }
                } else {
                    matchestUser = tempUSer;
                    matchestFinalName = finalName;
                }
            }
        }];
        if (matchestUser) {
            NSRange matchestUserNameRange = [atName rangeOfString:matchestFinalName];
            if (matchestUserNameRange.location == 0) {
                NSString *atString = [NSString stringWithFormat:kAtRegularString,matchestUser.id,matchestFinalName];
                NSRange replaceRange = [regularExpression rangeOfString:[@"@" stringByAppendingString:matchestFinalName]];
                regularExpression = [regularExpression stringByReplacingCharactersInRange:replaceRange withString:atString];
            }
        }
    }];
    
    return regularExpression;
}

//call
-(void)callWithNumber:(NSString *)phoneNum
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}

//send mail
- (void)sendEmail:(NSString *)emailAddress {
    if (![MFMailComposeViewController canSendMail]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can not send Email", @"Can not send Email")];
    } else {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.navigationBar.tintColor = [UIColor whiteColor];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:[NSArray arrayWithObjects:emailAddress, nil]];
        [self presentViewController:mc animated:YES completion:nil];
    }
}

- (void)setHeaderViewForTableView {
    self.isReloadTableView = NO;
    self.canLoadMore = NO;
    
    CGSize beforeContentSize = self.tableView.contentSize;
    
    if (self.roomType == ChatRoomTypeForRoom || self.roomType == ChatRoomTypeForStory) {
        self.roomHeaderView.transform = self.tableView.transform;
        self.tableView.tableHeaderView = self.roomHeaderView;
    } else {
        self.privateHeaderView.transform = self.tableView.transform;
        self.tableView.tableHeaderView = self.privateHeaderView;
    }
    
    CGSize afterContentSize = self.tableView.contentSize;
    CGPoint afterContentOffset = self.tableView.contentOffset;
    CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
    [self.tableView setContentOffset:newContentOffset animated:NO];
    if (self.chatDataArray.count == 0 || self.tableView.contentSize.height < self.tableView.frame.size.height) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
}

- (NSString *)chatDraft {
    NSString *targetID;
    switch (self.roomType) {
        case ChatRoomTypeForTeamMember:{
            targetID = self.currentToMember.id;
            break;
        }
        case ChatRoomTypeForRoom:{
            targetID = [TBUtility currentAppDelegate].currentRoom.id;
            break;
        }
        case ChatRoomTypeForStory:{
            targetID = [TBUtility currentAppDelegate].currentStory.id;
            break;
        }
    }
    if (!targetID) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetID = %@", targetID];
    MONotification *relatedNotification = [MONotification MR_findFirstWithPredicate:predicate];
    return relatedNotification.draft.content;
}

- (void)updateDraftIfNeeded:(NSString *)content {
    NSString *targetID;
    switch (self.roomType) {
        case ChatRoomTypeForTeamMember:{
            targetID = self.currentToMember.id;
            break;
        }
        case ChatRoomTypeForRoom:{
            targetID = [TBUtility currentAppDelegate].currentRoom.id;
            break;
        }
        case ChatRoomTypeForStory:{
            targetID = [TBUtility currentAppDelegate].currentStory.id;
            break;
        }
    }
    if (!targetID) {
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetID = %@", targetID];
    MONotification *relatedNotification = [MONotification MR_findFirstWithPredicate:predicate];
    if (relatedNotification.draft && [relatedNotification.draft.content isEqualToString:content]) {
        return;
    }
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MONotification *localNotification = [relatedNotification MR_inContext:localContext];
        MODraft *draft = localNotification.draft;
        if (content.length > 0) {
            if (!draft) {
                draft = [MODraft MR_createInContext:localContext];
                localNotification.draft = draft;
            }
            draft.content = content;
            draft.updatedAt = [NSDate date];
            draft.id = localNotification.id;
        } else {
            if (draft) {
                [draft MR_deleteInContext:localContext];
            }
        }
    } completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDraftUpdate object:relatedNotification.targetID];
    }];
}

#pragma mark - Remind Bind Mobile

- (void)showBindMobileRemindView {
    TBMemberInfoView *remindNoBindPhoneView = (TBMemberInfoView *)[[[NSBundle mainBundle] loadNibNamed:@"TBMemberInfoView" owner:self options:nil] objectAtIndex:0];
    [remindNoBindPhoneView displayOneButton];
    [remindNoBindPhoneView.midButton setTitle:NSLocalizedString(@"Finish", @"Finish") forState:UIControlStateNormal];
    [remindNoBindPhoneView.midButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [remindNoBindPhoneView.dialogView setBackgroundColor:[UIColor tb_blueColor]];
    [remindNoBindPhoneView.midButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    [remindNoBindPhoneView.userAvator setImage:[UIImage imageNamed:@"bindPhoneRobot"]];
    [remindNoBindPhoneView.userName setTextColor:[UIColor whiteColor]];
    [remindNoBindPhoneView.userName setText:NSLocalizedString(@"No linked mobilephone", @"No linked mobilephone")];
    [remindNoBindPhoneView.userPhone setTextColor:[UIColor whiteColor]];
    [remindNoBindPhoneView.userPhone setText:NSLocalizedString(@"You cannot call him now", @"You cannot call him now")];
    remindNoBindPhoneView.userEmail.hidden = YES;
    [self.tabBarController.view addSubview:remindNoBindPhoneView];
    remindNoBindPhoneView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        remindNoBindPhoneView.alpha = 1;
    } completion:^(BOOL finished) {
        remindNoBindPhoneView.alpha = 1;
    }];
}

#pragma mark - Loading
/**
 *  loading for first enter to load data
 *
 *  @return
 */

-(void)startLoading {
    [self.tableView startLoadingAnimation];
    self.canLoadMore = NO;
}

/**
 *  stop  Loading
 */
-(void)stopLoading {
    [self.tableView stopLoadingAnimation];
    self.canLoadMore = YES;
}

#pragma mark - fetch data

- (NSMutableDictionary *)getChatRequestParameters {
    NSMutableDictionary *tempParamsDic;
    switch (self.roomType) {
        case ChatRoomTypeForRoom:
            tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[TBUtility currentAppDelegate].currentRoom.id,@"_roomId", nil];
            break;
        case ChatRoomTypeForStory:
            tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentStory.id,@"_storyId", nil];
            break;
        case ChatRoomTypeForTeamMember:
            tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                             [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId", nil];
            break;
        default:
            tempParamsDic = [NSMutableDictionary dictionary];
            break;
    }
    return tempParamsDic;
}

- (void)getNeighborhoodMessage {
    [self startLoading];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        NSMutableDictionary *tempParamsDic = [self getChatRequestParameters];
        [tempParamsDic setObject:[NSString stringWithFormat:@"%d",FetchSize] forKey:@"limit"];
        [manager GET:kSendMessageURLString
          parameters:tempParamsDic
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 NSArray *messagesArray = responseObject;
                 [self dealNewestMessageForChatStyleSearchWithMessages:messagesArray];
                 dispatch_group_leave(group);
             }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                 DDLogError(@"error: %@", error.localizedRecoverySuggestion);
                 dispatch_group_leave(group);
             }];
    });
    
    __block NSMutableArray *besideMessages = [[NSMutableArray alloc]init];
    __block NSInteger searchedMessageIndex;
    NSString *originMessageId = self.searchedMessage.originMessageId ?: self.searchedMessage.id;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        NSMutableDictionary *tempParamsDic = [self getChatRequestParameters];
        [tempParamsDic setObject:[NSString stringWithFormat:@"%d",SearchFetchSize] forKey:@"limit"];
        [tempParamsDic setObject:originMessageId forKey:@"_besideId"];
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager GET:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {;
            NSMutableArray *responseTBMessages = [NSMutableArray arrayWithArray:[MTLJSONAdapter modelsOfClass:[TBMessage class] fromJSONArray:responseObject error:NULL]];
            NSArray *reverseArray = responseTBMessages.reverseObjectEnumerator.allObjects;
            for (TBMessage *tempMessage in reverseArray) {
                [besideMessages addObject:tempMessage];
                if ([tempMessage.id isEqualToString:originMessageId]) {
                    searchedMessageIndex = [reverseArray indexOfObject:tempMessage];
                }
            }
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_group_leave(group);
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.chatDataArray addObjectsFromArray:besideMessages];
        [self.tableView reloadData];
        
        if (searchedMessageIndex) {
            NSIndexPath *searchedIndexPath = [NSIndexPath indexPathForRow:0  inSection:searchedMessageIndex];
            [self.tableView scrollToRowAtIndexPath:searchedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        [self stopLoading];
    });
}

/**
 *  get related data for first enter
 */
- (void)fetchData {
    self.canLoadMore = NO;
    
    NSArray*messageArray = [self fetchMessageDataWithPageSize:FetchSize].reverseObjectEnumerator.allObjects;
    if (messageArray.count != 0) {
        [self getTableViewDataAndReloadWith:messageArray and:YES];
    } else {
        self.refreshWhenViewDidLoad = NO;
        [self fetchDataFromServerWithRefresh:NO andIsViewDidLoad:YES];
    }
}

- (void)fetchDataFromServerWithRefresh:(BOOL)isRefresh  andIsViewDidLoad:(BOOL)isViewDidLoad {
    if (!isRefresh) {
        [self startLoading];
    }
    
    NSDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:[TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",nil];
    } else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentStory.id,@"_storyId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",nil];
    } else {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",nil];
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [self processData:responseObject withRefresh:isRefresh andIsViewDidLoad:isViewDidLoad];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (!isRefresh) {
            [self stopLoading];
        }
    }];
}

/**
 *  parse data to save for chatRoomTypeForRoom
 *
 *  @param responseObject http responseObject
 */
- (void)processData:(id)responseObject withRefresh:(BOOL)isRefresh andIsViewDidLoad:(BOOL)isViewDidLoad {
    // process latest message data
    NSArray *messagesArray = responseObject;
    if (!isRefresh) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [messagesArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:obj error:NULL];
                NSError *error;
                NSManagedObject *managedObject = [MTLManagedObjectAdapter
                                                  managedObjectFromModel:message
                                                  insertingIntoContext:localContext
                                                  error:&error];
                if (managedObject==nil) {
                    DDLogDebug(@"[NSManagedObject] Error:%@",error);
                }
            }];
        }];
        [self stopLoading];
        [self updateTableViewDataWith:isViewDidLoad];
        if (messagesArray.count < FetchSize) {
            [self setHeaderViewForTableView];
        }
        [self refreshTabBarbadgeWithReduceNum:1];
    }
}

/**
 *  update messageTableView data and relaod
 */
- (void)updateTableViewDataWith:(BOOL)isViewDidLoad {
    [self.chatDataArray removeAllObjects];
    NSArray *messageArray = [self fetchMessageDataWithPageSize:FetchSize].reverseObjectEnumerator.allObjects;
    [self getTableViewDataAndReloadWith:messageArray and:isViewDidLoad];
}

- (void)getTableViewDataAndReloadWith:(NSArray *)messageArray and:(BOOL)isViewDidLoad {
    [messageArray enumerateObjectsUsingBlock:^(MOMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TBMessage *message = [MTLManagedObjectAdapter modelOfClass:[TBMessage class] fromManagedObject:obj error:nil];
        [self.chatDataArray addObject:message];
    }];
    [self reloadDataForViewDidLoad:isViewDidLoad];
    self.canLoadMore = YES;
    
    if (isViewDidLoad) {
        if (messageArray.count < FetchSize) {
            self.shouldLoadMoreForViewDidLoad = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadMore];
            });
        }
    }
}

- (void)reloadDataForViewDidLoad:(BOOL)isViewDidLoad {
    self.isReloadTableView = YES;
    CGSize beforeContentSize = self.tableView.contentSize;
    [self.tableView reloadData];
    CGSize afterContentSize = self.tableView.contentSize;
    CGPoint afterContentOffset = self.tableView.contentOffset;
    CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
    [self.tableView setContentOffset:newContentOffset animated:NO];
    if (isViewDidLoad) {
        if ([self.tableView slk_canScrollToBottom]) {
            DDLogDebug(@"self.bounds.size.height: %f",self.tableView.bounds.size.height);
            CGFloat offSetY = 0;
            if (CGRectGetHeight(self.tableView.tableHeaderView.frame) > 30) {
                offSetY = CGRectGetHeight(self.tableView.tableHeaderView.frame) - 30;
            }
            CGPoint bottomOffset = CGPointMake(0.0, self.tableView.contentSize.height - self.tableView.bounds.size.height + offSetY);
            [self.tableView setContentOffset:bottomOffset animated:NO];
        } else {
            [self.tableView setContentOffset:CGPointZero animated:NO];

        }
    }
}

/**
 *  get data from CoreData
 *
 *  @param pageSize    size for every page
 *
 *  @return search result
 */
- (NSArray*)fetchMessageDataWithPageSize:(int)pageSize {
    TBMessage *firstMessageModel = [self getLastSucceedMessageModel];
    NSPredicate *predicate;
    if (self.roomType == ChatRoomTypeForRoom) {
        if (firstMessageModel) {
            predicate = [NSPredicate predicateWithFormat:@"roomID = %@ AND id < %@",[TBUtility currentAppDelegate].currentRoom.id,firstMessageModel.id];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"roomID = %@",[TBUtility currentAppDelegate].currentRoom.id];
        }
    } else if (self.roomType == ChatRoomTypeForStory) {
        if (firstMessageModel) {
            predicate = [NSPredicate predicateWithFormat:@"storyID = %@ AND id < %@",self.currentStory.id,firstMessageModel.id];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"storyID = %@",self.currentStory.id];
        }
    } else {
        NSString *currentUserID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *currentTeamID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
        if (firstMessageModel) {
            predicate = [NSPredicate predicateWithFormat:@"creatorID IN {%@, %@} AND toID IN {%@, %@} AND teamID = %@ AND id < %@",self.currentToMember.id,currentUserID,self.currentToMember.id,currentUserID,currentTeamID,firstMessageModel.id];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"creatorID IN {%@, %@} AND toID IN {%@, %@} AND teamID = %@",self.currentToMember.id,currentUserID,self.currentToMember.id,currentUserID,currentTeamID];
        }
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"createdAt" ascending:NO];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TBMessage managedObjectEntityName]];
    [fetchRequest setFetchLimit:pageSize];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:predicate];
    NSArray*messageArray = [MOMessage MR_executeFetchRequest:fetchRequest];
    return messageArray;
}

- (void)parseNewMessageJsonDictionaryAndRefreshMessageTableViewWith:(NSDictionary *)obj withIsSend:(BOOL)isSend {
    TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                   fromJSONDictionary:obj
                                                error:NULL];
    message.isUnread = YES;
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
    if (!isSend) {
        //jadge the accept message is current room message or not
        if (self.roomType == ChatRoomTypeForRoom) {
            if (message.roomID) {
                if (![message.roomID isEqualToString: [TBUtility currentAppDelegate].currentRoom.id]) {
                    return;
                }
            } else {
                return;
            }
        } else if (self.roomType == ChatRoomTypeForStory) {
            if (message.storyID) {
                if (![message.storyID isEqualToString: self.currentStory.id]) {
                    return;
                }
            } else {
                return;
            }
        } else {
            if (message.roomID) {
                return;
            } else {
                if (![message.creatorID isEqualToString: currentUserID] && ![message.creatorID isEqualToString:self.currentToMember.id]) {
                    return;
                }
                if (![message.toID isEqualToString: currentUserID] && ![message.toID isEqualToString:self.currentToMember.id]) {
                    return;
                }
            }
        }
    }
    
    //when message is current room ,save data and refresh tableview ,
    if (self.chatStyle == ChatStyleSearch) {
        NSUInteger existIndex = [self indexForMessage:message inChatArray:self.neweastMessageArray];
        if (existIndex == -1) {
            NSInteger lastIndex = self.neweastMessageArray.count;
            [self.neweastMessageArray insertObject:message atIndex:lastIndex];
            self.searchUnreadNum ++;
            [self showUnreadButton];
        }
    } else {
        NSUInteger existIndex = [self indexForMessage:message inChatArray:self.chatDataArray];
        if (existIndex == -1) {
            BOOL isbottom = [self.tableView slk_isAtBottom];
            [self insertNewMessage:message];
            if (!isbottom) {
                self.searchUnreadNum ++;
                [self showUnreadButton];
            }
        }
    }
}

#pragma mark- Get frist of last send successful message

- (TBMessage *)getFirstSucceedMessageModel {
    if (self.chatDataArray.count == 0) {
        return nil;
    }
    
    NSInteger firstSuccedIndex = 0;
    BOOL found;
    for (int i = (int)(self.chatDataArray.count - 1); i >= 0; i--) {
        TBMessage *tempModel = [self.chatDataArray objectAtIndex:i];
        if (tempModel.sendStatus == sendStatusSucceed) {
            firstSuccedIndex = i;
            found = YES;
            break;
        }
    }
    if (found) {
        return [self.chatDataArray objectAtIndex:firstSuccedIndex];
    } else {
        return nil;
    }
}

- (TBMessage *)getLastSucceedMessageModel {
    if (self.chatDataArray.count == 0) {
        return nil;
    }
    
    int lastSuccedIndex = 0;
    BOOL found;
    for (int i = 0; i < self.chatDataArray.count; i++) {
        TBMessage *tempModel = [self.chatDataArray objectAtIndex:i];
        if (tempModel.sendStatus == sendStatusSucceed) {
            lastSuccedIndex = i;
            found = YES;
            break;
        }
    }
    if (found) {
        return [self.chatDataArray objectAtIndex:lastSuccedIndex];
    } else {
        return nil;
    }
}

#pragma mark - load newest
- (void)loadNewestCompleted {
    [super loadNewestCompleted];
}

- (BOOL)loadNewest {
    if (!self.canLoadNewest) {
        return NO;
    }
    if (![super loadNewest])
        return NO;
    [self performSelector:@selector(loadNewestMessage) withObject:nil afterDelay:0];
    return YES;
}

- (void)loadNewestMessage {
    DDLogDebug(@"*****load newest messages*****");
    TBMessage *firstMessageModel = [self getFirstSucceedMessageModel];
    NSDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:[TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_minId",nil];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentStory.id,@"_storyId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_minId",nil];
    }
    else
    {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_minId",nil];
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        NSMutableArray *responseArray = (NSMutableArray *)responseObject;
        if (responseArray.count < FetchSize) {
            self.canLoadNewest = NO;
            [self loadNewestCompleted];
            
            [self saveNewestMessageWith:responseArray];
            if (self.unreadButton) {
                [self readUnread:self.unreadButton];
            }
        } else {
            [self saveNewestMessageWith:responseArray];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"error%@",error);
        [self loadNewestCompleted];
    }];}

-(void)saveNewestMessageWith:(NSMutableArray *)responseMessagesArray {
    NSMutableArray *responseTBMessages = [NSMutableArray arrayWithArray:[MTLJSONAdapter modelsOfClass:[TBMessage class] fromJSONArray:responseMessagesArray error:NULL]];
    DDLogDebug(@"afterMessages Count:%lu",(unsigned long)responseTBMessages.count);
    [self.chatDataArray addObjectsFromArray:responseTBMessages];
    [self reloadDataForViewDidLoad:NO];
    if (responseMessagesArray.count < FetchSize) {
        self.canLoadNewest = NO;
    } else {
        self.canLoadNewest = YES;
    }
    [self loadNewestCompleted];
}

#pragma mark - load more
- (void)loadMoreCompleted {
    [super loadMoreCompleted];
}

- (BOOL)loadMore {
    if (!self.canLoadMore) {
        return NO;
    }
    if (![super loadMore])
        return NO;
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:0];
    return YES;
}

- (void)addItemsOnBottom {
    NSArray *localMoreMessageArray = [self fetchMessageDataWithPageSize:FetchSize];
    if (localMoreMessageArray.count > 0) {
        [localMoreMessageArray enumerateObjectsUsingBlock:^(MOMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TBMessage *message = [MTLManagedObjectAdapter modelOfClass:[TBMessage class] fromManagedObject:obj error:nil];
            if (self.chatDataArray.count == 0) {
                [self.chatDataArray addObject:message];
            } else {
                [self.chatDataArray insertObject:message atIndex:0];
            }
        }];
        self.canLoadMore = YES;
        [self loadMoreCompleted];
        [self reloadDataForViewDidLoad:NO];
    } else {
        [self getMoreMessageFromRemoteServer];
    }
}

- (void)getMoreMessageFromRemoteServer {
    TBMessage *firstMessageModel = [self getLastSucceedMessageModel];
    NSDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:[TBUtility currentAppDelegate].currentRoom.id,@"_roomId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_maxId",nil];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentStory.id,@"_storyId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_maxId",nil];
    }
    else
    {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [NSString stringWithFormat:@"%d",FetchSize],@"limit",
                         firstMessageModel.id,@"_maxId",nil];
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        NSMutableArray *responseArray = (NSMutableArray *)responseObject;
        if (responseArray.count < FetchSize) {
            [self saveMoreMessageResponseObjectWith:responseArray canLoadMore:NO];
        } else {
            [self saveMoreMessageResponseObjectWith:responseArray canLoadMore:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"error%@",error);
        [self loadMoreCompleted];
    }];
}

- (void)saveMoreMessageResponseObjectWith:(NSMutableArray *)responseMessagesArray canLoadMore:(BOOL)canLoadMore{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSDictionary *obj in responseMessagesArray) {
            TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:obj error:NULL];
            NSError *error;
            NSManagedObject *managedObject = [MTLManagedObjectAdapter managedObjectFromModel:message insertingIntoContext:localContext
                                              error:&error];
            if (managedObject==nil) {
                DDLogDebug(@"[NSManagedObject] Error:%@",error);
            } else {
                if (self.chatDataArray.count == 0) {
                    [self.chatDataArray addObject:message];
                } else {
                    [self.chatDataArray insertObject:message atIndex:0];
                }
            }
            
        }
    } completion:^(BOOL success, NSError *error) {
        self.canLoadMore = canLoadMore;
        [self loadMoreCompleted];
        [self reloadDataForViewDidLoad:NO];
        if (!canLoadMore) {
            [self setHeaderViewForTableView];
        }
        if (self.shouldLoadMoreForViewDidLoad) {
            self.shouldLoadMoreForViewDidLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottom];
            });
        }
    }];
}

#pragma mark - Scroll to top

- (void)scrollToTop {
    if (self.chatStyle != ChatStyleSearch) {
        [self cleanUnreadButton];
    }
}

#pragma mark - get New Message

- (void)getLatestMessageAfterSync {
    self.canLoadMore = YES;
    [self.chatDataArray removeAllObjects];
    [self updateTableViewDataWith:YES];
    [self refreshTabBarbadgeWithReduceNum:0];
}

- (void)saveUnreadDataWith:(NSMutableArray *)unReadMessageArray {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [unReadMessageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TBMessage *message = (TBMessage *)obj;
            NSError *error;
            message.isUnread = YES;
            NSManagedObject *managedObject = [MTLManagedObjectAdapter
                                              managedObjectFromModel:message
                                              insertingIntoContext:localContext
                                              error:&error];
            if (managedObject==nil) {
                DDLogDebug(@"[NSManagedObject] Error:%@",error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self insertNewMessage:message];
            });
        }];
    } completion:^(BOOL success, NSError *error) {
        [self refreshTabBarbadgeWithReduceNum:unReadMessageArray.count];
    }];
}

#pragma mark - Delete Message

- (void)deleteMessageWithMessageID:(NSString *)deletedMessageID andPhotoBrowser:(MWPhotoBrowser *)browser {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting", @"Deleting")];
    [[TBHTTPSessionManager sharedManager]DELETE:[NSString stringWithFormat:@"%@/%@",kSendMessageURLString,deletedMessageID] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Success to delete message");
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            MOMessage *moMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:deletedMessageID inContext:localContext];
            if (moMessage) {
                [moMessage MR_deleteInContext:localContext];
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketMessageRemove object:deletedMessageID];
            } else {
                DDLogDebug(@"haven't find message");
            }
            [SVProgressHUD dismiss];
        }];
        if (browser) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Fail to delete message");
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
    
}

#pragma mark - refresh Tabbar badge

- (void)refreshTabBarbadgeWithReduceNum:(NSInteger)reduceNum {
    if (self.chatDataArray.count == 0) {
        return;
    }
    NSDictionary *paramsDic;
    TBMessage *lastMessage = self.chatDataArray[0];
    if (self.roomType == ChatRoomTypeForRoom) {
        paramsDic = [NSDictionary dictionaryWithObjectsAndKeys:@"_roomId",@"messageType",
                     lastMessage.id,@"lastMessageId",
                     [TBUtility currentAppDelegate].currentRoom.id,@"id",nil];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        paramsDic = [NSDictionary dictionaryWithObjectsAndKeys:@"_storyId",@"messageType",
                     lastMessage.id,@"lastMessageId",
                     self.currentStory.id,@"id",nil];
    }
    else {
        paramsDic = [NSDictionary dictionaryWithObjectsAndKeys:@"_toId",@"messageType",
                     lastMessage.id,@"lastMessageId",
                     self.currentToMember.id,@"id",nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kHaveReadMessage object:paramsDic];
}

#pragma mark - upload  photo related
- (void)takePictureWith:(UIImagePickerControllerSourceType) type {
    UIImagePickerController * controlerPicker = [[UIImagePickerController alloc]init];
    controlerPicker.navigationBar.tintColor = [UIColor whiteColor];
    controlerPicker.delegate  = self;
    controlerPicker.sourceType = type;
    [self presentViewController:controlerPicker animated:YES completion:nil];
}

- (void)pickerPictureFromLibrary {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allPhotos];
    picker.showsCancelButton    = YES;
    picker.delegate             = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)uploadImageWithImageModel:(TBChatImageModel *)imageModel andMessage:(TBMessage *)sendMessage {
    [SVProgressHUD dismiss];
    //update tableview
    [self insertNewMessage:sendMessage];
    //tell recent sending message
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendingMessageNotification object:sendMessage];
    
    //send request
    NSMutableDictionary *tempParamsDic;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         [TBUtility currentAppDelegate].currentRoom.id,@"_roomId",nil];
    } else if (self.roomType == ChatRoomTypeForStory) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",
                         self.currentStory.id,@"_storyId",nil];
    }
    else {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.currentToMember.id,@"_toId",
                         [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",nil];
    }
    [MessageSendEngine sendImageWithImageModel:imageModel andMessage:sendMessage andPatameters:tempParamsDic];
}

#pragma mark - deal for send image and failed Message or voice

- (void)dealForMessageSendFailedWith:(TBMessage *)tempChatModel {
    NSInteger sendMessageIndex = [self.chatDataArray indexOfObject:tempChatModel];
    tempChatModel.sendStatus = sendStatusFailed;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sendMessageIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    //tell recentMessageView fail to send a message
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:tempChatModel];
}

- (TBMessage *)dealForSendImageMessageWith:(TBChatImageModel *)imageModel {
    DDLogDebug(@"*** photo begin");
    CGSize captureImageSize = imageModel.image.size;
    NSString *imageCategory = [[[imageModel.imageName componentsSeparatedByString:@"."] lastObject] lowercaseString];
    //generate a message
    TBMessage *tempChatModel =[[TBMessage alloc]init];
    NSString *tempUUIDStr = [[NSUUID UUID] UUIDString];
    tempChatModel.uuid = tempUUIDStr;
    if (self.roomType == ChatRoomTypeForRoom) {
        tempChatModel.roomID = [TBUtility currentAppDelegate].currentRoom.id;
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        tempChatModel.storyID = self.currentStory.id;
    }
    else {
        tempChatModel.toID = self.currentToMember.id;
    }
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserKey];
    MOUser *currentUser = [MOUser findFirstWithId:currentUserID];
    TBUser *tbUSer = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:currentUser error:nil];
    tempChatModel.creator = tbUSer;
    tempChatModel.createdAt = [NSDate date];
    tempChatModel.messageStr = @"";
    tempChatModel.creatorID = currentUserID;
    tempChatModel.isSend = YES;
    tempChatModel.displayMode = kDisplayModeImage;
    tempChatModel.sendImageCategory = imageCategory;
    tempChatModel.sendImage  = imageModel.image;
    tempChatModel.sendStatus = sendStatusSending;
    tempChatModel.teamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    TBAttachment *imageAttachment = [[TBAttachment alloc]init];
    imageAttachment.category = kDisplayModeFile;
    imageAttachment.data = [NSDictionary dictionaryWithObjectsAndKeys:kFileCategoryImage, kFileCategory,
                            imageModel.imageName, kFileName,
                            [NSNumber numberWithFloat:captureImageSize.width], kImageWidth,
                            [NSNumber numberWithFloat:captureImageSize.height], kImageHeight,
                            nil];
    tempChatModel.cellHeight = [TBImageTableViewCell calculateCellHeightWithMessage:tempChatModel andAttachment:imageAttachment];
    imageAttachment.cellHeight = tempChatModel.cellHeight;
    tempChatModel.attachments = [NSArray arrayWithObject:imageAttachment];
    tempChatModel.numbersOfRows = [TBUtility numberofRowsWithMessageModel:tempChatModel];
    
    [MessageSendEngine saveGeneratedMessageToDBWith:tempChatModel];
    return tempChatModel;
}

- (TBMessage *)generateVoiceMessage {
    TBMessage *sendVoiceMessage =[[TBMessage alloc]init];
    NSString *tempUUIDStr = [[NSUUID UUID] UUIDString];
    sendVoiceMessage.uuid = tempUUIDStr;
    if (self.roomType == ChatRoomTypeForRoom) {
        sendVoiceMessage.roomID = [TBUtility currentAppDelegate].currentRoom.id;
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        sendVoiceMessage.storyID = self.currentStory.id;
    }
    else
    {
        sendVoiceMessage.toID = self.currentToMember.id;
    }
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserKey];
    MOUser *currentUser = [MOUser findFirstWithId:currentUserID];
    TBUser *tbUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:currentUser error:nil];
    sendVoiceMessage.creator = tbUser;
    sendVoiceMessage.createdAt = [NSDate date];
    sendVoiceMessage.messageStr = @"";
    sendVoiceMessage.creatorID = currentUserID;
    sendVoiceMessage.isSend = YES;
    sendVoiceMessage.displayMode = kDisplayModeSpeech;
    sendVoiceMessage.cellHeight = [TBVoiceCell calculateCellHeight];
    sendVoiceMessage.sendStatus = sendStatusRecording;
    sendVoiceMessage.teamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    sendVoiceMessage.duration = 0;
    TBAttachment *imageAttachment = [[TBAttachment alloc]init];
    imageAttachment.category = kDisplayModeSpeech;
    imageAttachment.cellHeight = [TBVoiceCell calculateCellHeight];
    sendVoiceMessage.attachments = [NSArray arrayWithObject:imageAttachment];
    sendVoiceMessage.numbersOfRows = 2;
    return sendVoiceMessage;
}

#pragma mark - Handle avatar long presses and Tap press

- (void)handleAvatarLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        DDLogDebug(@"avatar longPress");
        NSIndexPath *pressedIndexPath =[self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        TBMessage * tempModel = [self.chatDataArray objectAtIndex:pressedIndexPath.section];
        MOUser *tapMOUser = [MOUser findFirstWithId:tempModel.creatorID];
        if (tapMOUser) {
            if (!tapMOUser.isRobotValue) {
                TBUser *tempTBUSer = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:tapMOUser error:NULL];
                [self.avatarAtMemberArray addObject:tempTBUSer];
                
                NSString *tempStr = [NSString stringWithFormat:@"@%@ ",[TBUtility getCreatorNameForMessage:tempModel]];
                self.textView.text = [self.textView.text stringByAppendingString:tempStr];
                [self.textView becomeFirstResponder];
            }
        }
    }
}

- (void)handleAvatarTapPress:(UITapGestureRecognizer *)tapPressRecognizer {
    if (tapPressRecognizer.state == UIGestureRecognizerStateEnded) {
        DDLogDebug(@"avatar  tap Press");
        NSIndexPath *pressedIndexPath =[self.tableView indexPathForRowAtPoint:[tapPressRecognizer locationInView:self.tableView]];
        TBMessage * message = [self.chatDataArray objectAtIndex:pressedIndexPath.section];
        MOUser *tapMOUser = [MOUser findFirstWithId:message.creatorID];
        if (tapMOUser) {
            [self jumpToMemberInfoWithMOUser:tapMOUser];
        }
    }
}

#pragma mark - Handle message long press

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    //deal for preview mode
    if (self.isPreView) {
        return;
    }
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *pressedIndexPath =[self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        [self showMenuControllerWithIndexPath:pressedIndexPath];
    }
}
    
- (void)showMenuControllerWithIndexPath:(NSIndexPath *)pressedIndexPath {
    if ([self.textView isFirstResponder]) {
        self.textView.overrideNextResponder = self;
    } else {
        [self becomeFirstResponder];
    }
    self.selectedIndexPathForMenu = pressedIndexPath;
    TBMessage * tempModel = [self.chatDataArray objectAtIndex:pressedIndexPath.section];
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    
    if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
        TBMenuItem *favoriteItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Favorite", @"Favorite") action:@selector(favoriteMenuButtonPressed:)];
        favoriteItem.indexPath = pressedIndexPath;
        
        if (tempModel.id && self.messageIdToFavoriteId[tempModel.id]) {
            favoriteItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Cancel Favorite", @"Cancel Favorite") action:@selector(favoriteMenuButtonPressed:)];
            favoriteItem.indexPath = pressedIndexPath;
        }
        
        TBMenuItem *tagItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Add tag", @"Add tag") action:@selector(addTagButtonPressed:)];
        tagItem.indexPath = pressedIndexPath;
        
        TBMenuItem *copyItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"Copy") action:@selector(copyMenuButtonPressed:)];
        copyItem.indexPath = pressedIndexPath;
        
        TBMenuItem *forwardItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"Forward") action:@selector(forwardMenuButtonPressed:)];
        forwardItem.indexPath = pressedIndexPath;
        
        TBMenuItem *editItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") action:@selector(editMenuButtonPressed:)];
        editItem.indexPath = pressedIndexPath;
        
        TBMenuItem *deleteItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete") action:@selector(deleteMenuButtonPressed:)];
        deleteItem.indexPath = pressedIndexPath;
        
        TBMenuItem *reportItem =
        [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Report", @"Report") action:@selector(reportMenuButtonPressed:)];
        reportItem.indexPath = pressedIndexPath;
        
        TBChatBaseCell *cell = (TBChatBaseCell *)[self.tableView cellForRowAtIndexPath:pressedIndexPath];
        ChatMessageMediaType tempMediaType = [self getCellMediaTypeFromCell:cell];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([tempModel.creatorID isEqualToString:currentUserID]) {
            switch (tempMediaType) {
                case ChatMessageMediaTypeText:
                    menuController.menuItems = @[favoriteItem,tagItem,copyItem,forwardItem,editItem,deleteItem,reportItem];
                    break;
                case ChatMessageMediaTypeFile:case ChatMessageMediaTypeImage:case ChatMessageMediaTypeVoice:
                    menuController.menuItems = @[favoriteItem,tagItem,forwardItem,deleteItem,reportItem];
                    break;
                case ChatMessageMediaTypeWeibo:
                    menuController.menuItems = @[favoriteItem,tagItem,forwardItem,deleteItem,reportItem];
                    break;
                    default:
                    break;
            }
        } else {
            MOUser *currentUser =[MOUser findFirstWithId:currentUserID];
            if ([currentUser.role isEqualToString:@"owner"] ||[currentUser.role isEqualToString:@"admin"]) {
                switch (tempMediaType) {
                    case ChatMessageMediaTypeText:
                        menuController.menuItems = @[favoriteItem,tagItem,copyItem,forwardItem,deleteItem,reportItem];
                        break;
                    case ChatMessageMediaTypeFile:case ChatMessageMediaTypeImage:case ChatMessageMediaTypeVoice:
                        menuController.menuItems = @[favoriteItem,tagItem,forwardItem,deleteItem,reportItem];
                        break;
                    case ChatMessageMediaTypeWeibo:
                        menuController.menuItems = @[favoriteItem,tagItem,forwardItem,deleteItem,reportItem];
                        break;
                        default:
                        break;
                }
                
            } else {
                switch (tempMediaType) {
                    case ChatMessageMediaTypeText:
                        menuController.menuItems = @[favoriteItem,tagItem,copyItem,forwardItem,reportItem];
                        break;
                    case ChatMessageMediaTypeFile:case ChatMessageMediaTypeImage:
                    case ChatMessageMediaTypeVoice:
                        menuController.menuItems = @[favoriteItem,tagItem,forwardItem,reportItem];
                        break;
                    case ChatMessageMediaTypeWeibo:
                        menuController.menuItems = @[favoriteItem,tagItem,forwardItem,reportItem];
                        break;
                        default:
                        break;
                }
            }
        }
        
        //deal for sendFail Message
        if (tempModel.sendStatus == sendStatusFailed) {
            if (tempMediaType == ChatMessageMediaTypeText) {
                menuController.menuItems = @[copyItem,deleteItem];
            } else {
                menuController.menuItems = @[deleteItem];
            }
        }
        CGRect cellRect = [cell convertRect:cell.bubbleContainer.frame toView:self.tableView];
        [menuController setTargetRect:cellRect inView:self.tableView];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (ChatMessageMediaType)getCellMediaTypeFromCell:(TBChatBaseCell *)cell {
    ChatMessageMediaType tempMediaType;
    if ([cell isKindOfClass:[TBFileTableViewCell class]]) {
        tempMediaType = ChatMessageMediaTypeFile;
    }
    else if ([cell isKindOfClass:[TBImageTableViewCell class]]) {
        tempMediaType = ChatMessageMediaTypeImage;
    }
    else if ([cell isKindOfClass:[TBVoiceCell class]]) {
        tempMediaType = ChatMessageMediaTypeVoice;
    }
    else if ([cell isKindOfClass:[TbChatTableViewCell class]]) {
        tempMediaType = ChatMessageMediaTypeText;
    }
    else {
        tempMediaType = ChatMessageMediaTypeWeibo;
    }
    return tempMediaType;
}

- (void)favoriteMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *message = [self.chatDataArray objectAtIndex:item.indexPath.section];
        [self favoriteMessageWithID:message.id];
    }
}

- (void)favoriteMessageWithID:(NSString *)messageID {
    if (!messageID) {
        return;
    }
    if (!self.messageIdToFavoriteId[messageID]) {
        //Favorite message
        [[TBHTTPSessionManager sharedManager] POST:kFavoritesURLString parameters:@{@"_messageId": messageID} success:^(NSURLSessionDataTask *task, id responseObject) {
            self.messageIdToFavoriteId[messageID] = responseObject[@"id"];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added", @"Added")];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
        }];
    } else {
        //Cancel favorite messgae
        [[TBHTTPSessionManager sharedManager] DELETE:[NSString stringWithFormat:kFavoritesDeleteURLString, self.messageIdToFavoriteId[messageID]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            self.messageIdToFavoriteId[messageID] = nil;
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Favorite Canceled", @"Favorite Canceled")];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
        }];
    }
}

- (void)addTagButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *message = [self.chatDataArray objectAtIndex:item.indexPath.section];
        [self addTagWithID:message.id withArray:message.tags];
    }
}

- (void)addTagWithID:(NSString *)messageID withArray:(NSArray *)tags {
    AddTagViewController *addTagVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTagViewController"];
    addTagVC.viewModel = [[AddTagViewModel alloc] init];
    addTagVC.viewModel.messageId = messageID;
    NSArray *tbTagsArray = [MTLJSONAdapter modelsOfClass:[TBTag class] fromJSONArray:tags error:NULL];
    [addTagVC.viewModel.selectedTags addObjectsFromArray:tbTagsArray];
    [self.navigationController pushViewController:addTagVC animated:YES];
}

- (void)copyMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *menuItem = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (menuItem.indexPath) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        TBMessage * message = [self.chatDataArray objectAtIndex:menuItem.indexPath.section];
        [pasteboard setString:message.messageStr];
    }
}

- (void)forwardMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *menuItem = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (menuItem.indexPath) {
        TBMessage * message = [self.chatDataArray objectAtIndex:menuItem.indexPath.section];
        [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:message.id]];
    }
}

- (void)forwardMessageWithMessageIdArray:(NSArray *)messageIdArray {
    UINavigationController *shareNavigationController = [[UIStoryboard storyboardWithName:kShareStoryboard bundle:nil] instantiateInitialViewController];
    ShareToTableViewController *shareViewController = [shareNavigationController.viewControllers objectAtIndex:0];
    shareViewController.forwardMessageIdArray = [NSArray arrayWithArray:messageIdArray];
    [self.navigationController presentViewController:shareNavigationController animated:YES completion:nil];
}

-(void)editMenuButtonPressed:(UIMenuController *)menuController {
    NSArray *shareMenuArray = [[UIMenuController sharedMenuController] menuItems];
    TBMenuItem *editItem = [shareMenuArray objectAtIndex:0];
    if (editItem.indexPath) {
        TBMessage * message = [self.chatDataArray objectAtIndex:editItem.indexPath.section];
        DDLogDebug(message.messageStr);
        
        MessageEditViewController *messageEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageEditViewController"];
        messageEditController.tintColor = chatTintColor;
        messageEditController.delegate = self;
        messageEditController.editMessage = message;
        messageEditController.transitioningDelegate = self;
        messageEditController.modalPresentationStyle = UIModalPresentationCustom;
        [self.navigationController presentViewController:messageEditController
                                                animated:YES
                                              completion:NULL];
        isEditingMessage = YES;
    }
}

-(void)deleteMenuButtonPressed:(UIMenuController *)menuController{
    NSArray *shareMenuArray = [[UIMenuController sharedMenuController] menuItems];
    TBMenuItem *deleteItem = [shareMenuArray objectAtIndex:0];
    if (deleteItem.indexPath) {
        TBMessage * tempModel = [self.chatDataArray objectAtIndex:deleteItem.indexPath.section];
        if (tempModel.sendStatus == sendStatusFailed || tempModel.sendStatus == sendStatusSending) {
            [MessageSendEngine removeGeneratedMessageFromDBWith:tempModel];
            
            [self.chatDataArray removeObjectAtIndex:deleteItem.indexPath.section];
            [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:deleteItem.indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            //refresh recent tableview after remove message
            [self refreshRecentTableView];
        } else {
            UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure to Delete", @"Sure to Delete")];
            [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
            }];
            [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Delete", @"Delete") withBlock:^(NSInteger theButtonIndex) {
                [self deleteMessageWithMessageID:tempModel.id andPhotoBrowser:nil];
            }];
            [actionSheet showInView:self.view];
        }
    }
}

-(void)reportMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *menuItem = (TBMenuItem *)[[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        TBMessage * tempModel = [self.chatDataArray objectAtIndex:menuItem.indexPath.section];
        TBAttachment *attachment;
        if (tempModel.attachments.count > 0) {
            attachment = tempModel.attachments.firstObject;
        }
        TBChatBaseCell *cell = (TBChatBaseCell *)[self.tableView cellForRowAtIndexPath:menuItem.indexPath];
        ChatMessageMediaType tempMediaType = [self getCellMediaTypeFromCell:cell];
        
        FeedbackTableViewController *tempFeedbackVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"FeedbackTableViewController"];
        tempFeedbackVC.title = NSLocalizedString(@"Report", @"Report");
        tempFeedbackVC.reportMessageID = tempModel.id;
        NSString *name = [TBUtility getCreatorNameForMessage:tempModel];
        switch (tempMediaType) {
            case ChatMessageMediaTypeText:
                tempFeedbackVC.reportContentStr = [NSString stringWithFormat:@"%@: %@\n%@: %@",NSLocalizedString(@"User", @"User"),name,NSLocalizedString(@"Objectionable content", @"Objectionable content"),tempModel.messageStr];
                break;
            case ChatMessageMediaTypeFile:case ChatMessageMediaTypeVoice:case ChatMessageMediaTypeImage: {
                tempFeedbackVC.reportContentStr = [NSString stringWithFormat:@"%@: %@\n%@: %@",NSLocalizedString(@"User", @"User"),name,NSLocalizedString(@"Objectionable content", @"Objectionable content"),attachment.data[kFileName]];
            }
                break;
            case ChatMessageMediaTypeWeibo:
                tempFeedbackVC.reportContentStr = [NSString stringWithFormat:@"%@: %@\n%@: %@ ",NSLocalizedString(@"User", @"User"),name,NSLocalizedString(@"Objectionable content", @"Objectionable content"),attachment.data[kQuoteTitle]];
                break;
            default:
                break;
        }
        tempFeedbackVC.isReport = YES;
        [self.navigationController pushViewController:tempFeedbackVC animated:YES];
    }
}

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    self.textView.isShowCustomMenu = YES;
    [menu setMenuVisible:YES animated:YES];
    self.textView.isShowCustomMenu = NO;
    
    TBChatBaseCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPathForMenu];
    selectedCell.showMenu = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)didReceiveMenuWillHideNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    TBChatBaseCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPathForMenu];
    selectedCell.showMenu = NO;
    UIMenuController *menu = [notification object];
    [menu update];
    menu.menuItems = nil;
    self.selectedIndexPathForMenu = nil;
    self.textView.overrideNextResponder = nil;
}

#pragma mark - View Auto-Layout

- (void)setupViewConstraints {
    [self.view addSubview:self.textInputbar];
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *views = @{@"scrollView": self.scrollViewProxy,
                            @"textInputbar": self.textInputbar,
                            };
    CGFloat topOffset;
    if (self.roomType == ChatRoomTypeForStory) {
        topOffset = CGRectGetHeight(self.storyDisplayView.frame);
    } else {
        topOffset = 0;
    }
    NSDictionary *metrics = @{@"top" : @(topOffset)};

    [self.view removeConstraints:self.tableView.constraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==top)-[scrollView(==0@750)]-0@999-[textInputbar(>=0)]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textInputbar]|" options:0 metrics:nil views:views]];
    
    NSArray *bottomConstraints = [self.view slk_constraintsForAttribute:NSLayoutAttributeBottom];
    NSArray *heightConstraints = [self.view slk_constraintsForAttribute:NSLayoutAttributeHeight];
    
    self.scrollViewHC = heightConstraints[0];
    self.textInputbarHC = heightConstraints[1];
    self.keyboardHC = bottomConstraints[0];
    self.textInputbarHC.constant = [self minimumInputbarHeight];
    self.scrollViewHC.constant = [self appropriateScrollViewHeight];
    
    //deal for preview
    if (self.isPreView || self.isArchived) {
        self.keyboardHC.constant = - [self minimumInputbarHeight];
    } else {
        self.keyboardHC.constant = 0;
    }
}

#pragma mark - NSNotificationCenter register/unregister

- (void)registerNotifications
{
    //UIApplication Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowOrHideKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowOrHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowOrHideKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowOrHideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    
    // TextView notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeTextView:) name:SLKTextViewTextWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewContentSize:) name:SLKTextViewContentSizeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewSelection:) name:SLKTextViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewPasteboard:) name:SLKTextViewDidPasteImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShakeTextView:) name:SLKTextViewDidShakeNotification object:nil];
    
    //textView did press return key to send message notication
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextViewDidPressReturnKey:) name:SLKTextViewTextDidPressReturnKey object:nil];
    
    //socket Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptSocketMessage:) name:kSocketMessageCreate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptSocketRemove:) name:kSocketMessageRemove object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptSocketUpdate:) name:kSocketMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftPrivateRoom:) name:kLeftPrivateRoomNotification object:nil];
    
    //tag add Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTagSucceed:) name:kAddTagSucceedNotification object:nil];
    
    //UIMenuController notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenuWillShowNotification:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenuWillHideNotification:)name:UIMenuControllerWillHideMenuNotification  object:nil];
    
    //Dynamic System Font
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    DDLogVerbose(@"*****addAllRegisterNotifications****");
    
    //send message notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageSucceed:) name:kSendMessageSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageFailed:) name:kSendMessageFailedNotification object:nil];
    //resend message or image notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendFailedMessage:) name:kResendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendFailedImage:) name:kResendImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendFailedVoice:) name:kResendVoiceNotification object:nil];
    
    //other notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAutoCompletion) name:KCancelAt object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAtMember:) name:KSelectedAtMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TapOtherMedia:) name:kTapOtherMedia object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLatestMessageAfterSync) name:kTeamDataStored object:nil];
    
    //edit story
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasEditedStory) name:kEditStoryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasEditTopicInfo:) name:kEditTopicInfoNotification object:nil];
    
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLogVerbose(@"*****removeAllRegisterNotifications****");
}


#pragma mark - View Auto-Rotation
// iOS8 only
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self prepareForInterfaceRotation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark- Delegate & Protocol

#pragma mark- MFMailComposedelegate
//the delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DDLogDebug(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            DDLogDebug(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            DDLogDebug(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            DDLogDebug(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AGEmojiKeyboardViewDataSource & AGEmojiKeyboardViewDelegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.textView.text = [self.textView.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.textView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSend:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self sendTextMessageToServer:self.textView.text];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *selectedIamge;
    switch (category) {
        case AGEmojiKeyboardViewCategoryImageRecent:
            selectedIamge = [UIImage imageNamed:@"recent_s"];
            break;
        case AGEmojiKeyboardViewCategoryImageFace:
            selectedIamge = [UIImage imageNamed:@"face_s"];
            break;
        case AGEmojiKeyboardViewCategoryImageBell:
            selectedIamge = [UIImage imageNamed:@"bell_s"];
            break;
        case AGEmojiKeyboardViewCategoryImageFlower:
            selectedIamge = [UIImage imageNamed:@"flower_s"];
            break;
        case AGEmojiKeyboardViewCategoryImageCar:
            selectedIamge = [UIImage imageNamed:@"car_s"];
            break;
        case AGEmojiKeyboardViewCategoryImageCharacters:
            selectedIamge = [UIImage imageNamed:@"characters_s"];
            break;
        default:
            break;
    }
    return selectedIamge;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *noneSelectedIamge;
    switch (category) {
        case AGEmojiKeyboardViewCategoryImageRecent:
            noneSelectedIamge = [UIImage imageNamed:@"recent_n"];
            break;
        case AGEmojiKeyboardViewCategoryImageFace:
            noneSelectedIamge = [UIImage imageNamed:@"face_n"];
            break;
        case AGEmojiKeyboardViewCategoryImageBell:
            noneSelectedIamge = [UIImage imageNamed:@"bell_n"];
            break;
        case AGEmojiKeyboardViewCategoryImageFlower:
            noneSelectedIamge = [UIImage imageNamed:@"flower_n"];
            break;
        case AGEmojiKeyboardViewCategoryImageCar:
            noneSelectedIamge = [UIImage imageNamed:@"car_n"];
            break;
        case AGEmojiKeyboardViewCategoryImageCharacters:
            noneSelectedIamge = [UIImage imageNamed:@"characters_n"];
            break;
        default:
            break;
    }
    return noneSelectedIamge;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *deleteImage = [UIImage imageNamed:@"backspace_n"];
    return deleteImage;
}

#pragma mark - BRNImagePickerSheetDelegate
- (NSString *)imagePickerSheet:(BRNImagePickerSheet *)imagePickerSheet titleForButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL photosSelected = imagePickerSheet.numberOfSelectedPhotos > 0;
    
    if (buttonIndex == 0) {
        if (photosSelected) {
            return [NSString localizedStringWithFormat:NSLocalizedString(@"send %lu Photo", @ "The secondary title to send the photos"),imagePickerSheet.numberOfSelectedPhotos];
        } else {
            return NSLocalizedString(@"Take a Photo", @"Take a Photo");
        }
    }
    else {
        return NSLocalizedString(@"Choose From Library", @"Choose From Library");
    }
}

- (void)imagePickerSheet:(BRNImagePickerSheet *)imagePickerSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL photosSelected = imagePickerSheet.numberOfSelectedPhotos > 0;
    
    if (buttonIndex == 0) {
        if (photosSelected) {
            [imagePickerSheet.selectedPhotoIndices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAsset *asset = imagePickerSheet.assets[[obj intValue]];
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // Download from cloud if necessary
                options.networkAccessAllowed = YES;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showProgress:progress status:NSLocalizedString(@"Loading from iCloud", @"Loading from iCloud") maskType:SVProgressHUDMaskTypeNone];;
                    });
                };
                
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Dealing", @"Dealing")];
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    NSURL *captureImageURL = (NSURL *)[info objectForKey:@"PHImageFileURLKey"];
                    NSString *captureImageURLStr = captureImageURL.absoluteString;
                    UIImage *captureImage = [UIImage fixOrientation:[UIImage imageWithData:imageData]];
                    TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
                    imageModel.image = captureImage;
                    imageModel.imageName = [[captureImageURLStr componentsSeparatedByString:@"/"] lastObject];
                    TBMessage *sendImageMessage = [self dealForSendImageMessageWith:imageModel];
                    if (idx == imagePickerSheet.selectedPhotoIndices.count - 1) {
                        [SVProgressHUD dismiss];
                    }
                    [self uploadImageWithImageModel:imageModel andMessage:sendImageMessage];
                }];
            }];
        } else {
            [self takePictureWith:UIImagePickerControllerSourceTypeCamera];
        }
    }
    else if (buttonIndex == 1)
    {
        [self pickerPictureFromLibrary];
    }
}

- (void)imagePickerSheetCancel:(BRNImagePickerSheet *)imagePickerSheet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
            imageModel.image = [UIImage fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
            imageModel.imageName = [NSString stringWithFormat:@"tbfile%u.png",(arc4random() % 10000) + 1];
            TBMessage *sendImageMessage = [self dealForSendImageMessageWith:imageModel];
            [self uploadImageWithImageModel:imageModel andMessage:sendImageMessage];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *tempAsset = (ALAsset *)obj;
        CGImageRef ref = [[tempAsset  defaultRepresentation]fullResolutionImage];
        TBChatImageModel *imageModel = [[TBChatImageModel alloc]init];
        imageModel.image = [[UIImage alloc]initWithCGImage:ref];
        imageModel.imageName = [[tempAsset defaultRepresentation] filename];
        TBMessage *sendImageMessage = [self dealForSendImageMessageWith:imageModel];
        [self uploadImageWithImageModel:imageModel andMessage:sendImageMessage];
    }];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remind", @"Remind")
                                   message:NSLocalizedString(@"Not more than 10 photos", @"Not more than 10 photos")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [self.previewItems count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewItems[ index ];
}

#pragma mark - AZAPreviewControllerDelegate

- (void)AZA_previewController:(AZAPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error
{
    NSString *alertTitle = NSLocalizedString(@"Failed to load", @"Failed to load");
    NSString *alertMessage = [error localizedDescription];
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count + self.morePhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = nil;
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    if (index < allPhotoArray.count) {
        photo = [allPhotoArray objectAtIndex:index];
    }
    if (photo.messageID && self.messageIdToFavoriteId[photo.messageID]) {
        photo.isFavorite = YES;
    }
    return photo;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    return nil;
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    MWPhoto *photo = [allPhotoArray objectAtIndex:index];
    return photo.caption;
}

// star、tag、forward and delete action
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser starPhotoAtIndex:(NSUInteger)index {
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    MWPhoto *photo = [allPhotoArray objectAtIndex:index];

    [self favoriteMessageWithID:photo.messageID];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser tagPhotoAtIndex:(NSUInteger)index {
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    MWPhoto *photo = [allPhotoArray objectAtIndex:index];

    [self addTagWithID:photo.messageID withArray:photo.tagsArray];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser forwardPhototAtIndex:(NSUInteger)index {
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    MWPhoto *photo = [allPhotoArray objectAtIndex:index];

    [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:photo.messageID]];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletePhototAtIndex:(NSUInteger)index {
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];
    MWPhoto *photo = [allPhotoArray objectAtIndex:index];

    [self deleteMessageWithMessageID:photo.messageID andPhotoBrowser:photoBrowser];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    DDLogDebug(@"Did start viewing photo at index %lu", (unsigned long)index);
    NSMutableArray *allPhotoArray = [NSMutableArray arrayWithArray:self.morePhotos];
    [allPhotoArray addObjectsFromArray:self.photos];

    if (index == 0 && self.photosTotal != allPhotoArray.count) {
        [self loadMoreImage];
        self.browser.needToReload = YES;
    }
}

- (void)loadMoreImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    unsigned long photosPage = (self.photos.count + self.morePhotos.count)/10 + 1;
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  teamID,@"_teamId",
                                  @"file",@"type",
                                  @"image",@"fileCategory",
                                  [[NSString alloc] initWithFormat:@"%lul",photosPage],@"page",
                                  [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"createdAt", nil],@"sort",
                                  nil];
    if (self.roomType == ChatRoomTypeForRoom) {
        [paras setValue:[TBUtility currentAppDelegate].currentRoom.id forKey:@"_roomId"];
    }
    else if (self.roomType == ChatRoomTypeForStory) {
        [paras setValue:self.currentStory.id forKey:@"_storyId"];
    }
    else {
        [paras setValue:self.currentToMember.id forKey:@"_toId"];
    }
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSearchURLString parameters:paras success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        self.photosTotal = [(NSNumber *)[responseObject objectForKey:@"total"] integerValue];
        NSArray *responseFileArray = (NSArray *)[responseObject objectForKey:@"messages"];
        int beginIndex = (self.photos.count + self.morePhotos.count) % 10;
        NSInteger newCurrentIndex = self.browser.currentIndex;
        for (int i = beginIndex; i < responseFileArray.count; i++) {
            TBMessage *fileMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                               fromJSONDictionary:responseFileArray[i]
                                                            error:NULL];
            for (TBAttachment *tempAttchment in fileMessage.attachments) {
                NSString *fileName = (NSString *)tempAttchment.data[kFileName];
                NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
                NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
                
                MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
                photo.messageID = fileMessage.id;
                photo.creatorID = fileMessage.creatorID;
                photo.caption = fileName;
                photo.tagsArray = fileMessage.tags;
                if (self.morePhotos == 0) {
                    [self.morePhotos addObject:photo];
                } else {
                    [self.morePhotos insertObject:photo atIndex:0];
                }
                newCurrentIndex ++;
            }
        }
        [self.browser setContenSizeWithNumber:(self.photos.count + self.morePhotos.count)];
        [self.browser reloadData];
        [self.browser setCurrentPhotoIndex:newCurrentIndex];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chatDataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TBMessage *tempModel = [self.chatDataArray objectAtIndex:section];
    NSInteger rowCount = tempModel.numbersOfRows;
    return rowCount;
}

//cell height
- (CGFloat)cellHeightOfModel:(TBMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    BOOL isEnterBackGroud =[TBUtility currentAppDelegate].isEnterBackGroud;
    if (message.isSystem) {
        return isEnterBackGroud ? [TBSystemMessageCell calculateCellHeightWithMessage:message] : message.cellHeight;
    }
    
    NSInteger rowCount = message.numbersOfRows;
    CGFloat cellHeight;
    if (indexPath.row == 0) {
        if (message.messageStr.length == 0) {
            TBAttachment *attachment = [message.attachments firstObject];
            if (isEnterBackGroud) {
                cellHeight = [TBUtility getCellHeightWithAttachment:attachment forModel:message];
            } else {
                cellHeight = attachment.cellHeight;
            }
        } else {
            cellHeight = isEnterBackGroud ? [TbChatTableViewCell calculateCellHeightWithMessage:message] : message.cellHeight;
        }
    } else if (indexPath.row == rowCount -1) {
        cellHeight = [TBTimeCell calculateCellHeight];
        
    } else {
        NSInteger attachmentIndex;
        if (message.messageStr.length == 0) {
            attachmentIndex = indexPath.row;
        } else {
            attachmentIndex = indexPath.row - 1;
        }
        TBAttachment *attachment = [message.attachments objectAtIndex:attachmentIndex];
        if (isEnterBackGroud) {
            cellHeight = [TBUtility getCellHeightWithAttachment:attachment forModel:message];
        } else {
            cellHeight = attachment.cellHeight;
        }
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMessage * message = [self.chatDataArray objectAtIndex:indexPath.section];
    CGFloat cellHeight = [self cellHeightOfModel:message atIndexPath:indexPath];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   TBMessage * message = [self.chatDataArray objectAtIndex:indexPath.section];
    CGFloat cellHeight = [self cellHeightOfModel:message atIndexPath:indexPath];
    return cellHeight;
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMessage * message = [self.chatDataArray objectAtIndex:indexPath.section];
    //system cell
    if (message.isSystem) {
        TBSystemMessageCell *systemChatCell = (TBSystemMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:systemCellIdentifier];
        systemChatCell.transform = self.tableView.transform;
        systemChatCell.message = message;
        return systemChatCell;
    }
    
    /*******other cell*******/
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    UILongPressGestureRecognizer *avatarLongPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarLongPress:)];
    UITapGestureRecognizer *avatarTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapPress:)];
    
    NSInteger rowCount = message.numbersOfRows;
    //text cell
    if (indexPath.row == 0) {
        if (message.messageStr.length == 0) {
            TBAttachment *attachment = [message.attachments firstObject];
            TBChatBaseCell *baseCell =  [self cellForAttachment:attachment fromMessage:message atIndexPath:indexPath andCount:rowCount];
            return baseCell;
        } else {
            TbChatTableViewCell *chatCell;
            if (message.isSend) {
                chatCell = (TBChatSendTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:sendCellIdentifier];
            } else {
                chatCell = (TbChatTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
                if (chatCell.avatarGestureRecognizer == nil) {
                    chatCell.avatarGestureRecognizer = avatarTapRecognizer;
                }
                if (chatCell.avatarLongPressRecognizer == nil) {
                    chatCell.avatarLongPressRecognizer = avatarLongPressRecognizer;
                }
            }
            if (chatCell.longPressRecognizer == nil) {
                chatCell.longPressRecognizer = longPressRecognizer;
            }
            
            //receipt @message
            if (message.mentions.count > 0) {
                chatCell.receiptDelegate = self;
                chatCell.isMentionMessage = YES;
                [self sendReceiptToServerWithMessage:message atIndex:indexPath];
            } else {
                chatCell.isMentionMessage = NO;
            }
            
            chatCell.transform = self.tableView.transform;
            chatCell.messageContentLabel.delegate = self;
            chatCell.messageContentLabel.userInteractionEnabled = YES;
            chatCell.bubbleTintColor = chatTintColor;
            chatCell.message = message;
            return chatCell;
            }
    }
    //time cell
    else if (indexPath.row == rowCount -1) {
        TBTimeCell *timeCell;
        if (message.isSend) {
            timeCell = (TBTimeSendCell *)[self.tableView dequeueReusableCellWithIdentifier:timeSendCellIdentifier];
        } else {
            timeCell = (TBTimeCell *)[self.tableView dequeueReusableCellWithIdentifier:timeCellIdentifier];
        }
        timeCell.transform = self.tableView.transform;
        timeCell.message = message;
        [self checkTagWithModel:message forCell:timeCell];
        return timeCell;
    }
    // bubble(attachment) cell
    else {
        NSInteger attachIndex;
        if (message.messageStr.length == 0) {
            attachIndex = indexPath.row;
        } else {
            attachIndex = indexPath.row - 1;
        }
        TBAttachment *attachment = [message.attachments objectAtIndex:attachIndex];
        TBChatBaseCell *baseCell =  [self cellForAttachment:attachment fromMessage:message atIndexPath:indexPath andCount:rowCount];
        return baseCell;
    }
}

- (void)sendReceiptToServerWithMessage:(TBMessage *)message atIndex:(NSIndexPath *)indexPath {
    if ([message.mentions containsObject:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey]] && ![message.receiptors containsObject:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey]]) {
        //receipt
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager POST:[NSString stringWithFormat:kMessageReceiptURLString,message.id] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            TBMessage *newMessage = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:responseObject error:NULL];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                NSError *error;
                [MTLManagedObjectAdapter managedObjectFromModel:newMessage insertingIntoContext:localContext error:&error];
            } completion:^(BOOL success, NSError *error) {
                self.chatDataArray[indexPath.section] = newMessage;
            }];
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            if (error) {
                DDLogDebug(error.localizedRecoverySuggestion);
            }
        }];
    }
}

- (TBChatBaseCell *)cellForAttachment:(TBAttachment *)attachment fromMessage:(TBMessage *)message atIndexPath:(NSIndexPath *)indexPath andCount:(NSInteger)rowCount {
    // gesture
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    UILongPressGestureRecognizer *avatarLongPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarLongPress:)];
    UITapGestureRecognizer *avatarTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapPress:)];
    
    NSString *category = attachment.category;
    //file
    if ([category isEqualToString:kDisplayModeFile]) {
        NSString *fileCategory = attachment.data[kFileCategory];
        if ([fileCategory isEqualToString:kFileCategoryImage]) {
            TBImageTableViewCell *imageCell;
            if (message.isSend) {
                imageCell = (TBImageSendTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:imageSendCellIdentifier ];
            } else {
                imageCell = (TBImageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier ];
                if (imageCell.avatarLongPressRecognizer == nil) {
                    imageCell.avatarLongPressRecognizer = avatarLongPressRecognizer;
                }
                if (imageCell.avatarGestureRecognizer == nil) {
                    imageCell.avatarGestureRecognizer = avatarTapRecognizer;
                }
            }
            imageCell.transform = self.tableView.transform;
            [imageCell setMessage:message andAttachment:attachment];
            if (imageCell.longPressRecognizer == nil) {
                imageCell.longPressRecognizer = longPressRecognizer;
            }
            //set image
            switch (message.sendStatus) {
                case sendStatusSucceed:
                {
                    if (!message.sendImage) {
                        NSString *fileType = attachment.data[kFileType];
                        NSString *imageThumbnailUrlString = attachment.data[kFileThumbnailUrl];
                        NSURL *thumbnailURL = [NSURL URLWithString:imageThumbnailUrlString];
                        if ([fileType.lowercaseString isEqualToString:@"gif"]) {
                            [imageCell.mediaImageView sd_setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"photoDefault"] completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    FLAnimatedImage *flaImage = [FLAnimatedImage animatedImageWithGIFData:data];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        TBImageSendTableViewCell *tempCell = (TBImageSendTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                        tempCell.mediaImageView.animatedImage = flaImage;
                                    });
                                });
                            }];
                        } else {
                            CGFloat imageHieght = [attachment.data[kImageHeight] floatValue];
                            CGFloat imageWidth = [attachment.data[kImageWidth] floatValue];
                            CGFloat maxHieght = MAX(imageHieght, imageWidth);
                            CGFloat multiple = 1;
                            if (maxHieght > 240) {
                                multiple = 240.0/maxHieght;
                            }
                            NSString *thumbnalString = [thumbnailURL.absoluteString stringByReplacingOccurrencesOfString:@"w/200" withString:[NSString stringWithFormat:@"w/%f",imageWidth *multiple ]];
                            thumbnalString = [thumbnalString stringByReplacingOccurrencesOfString:@"h/200" withString:[NSString stringWithFormat:@"h/%f",imageHieght * multiple]];
                            [imageCell.mediaImageView sd_setImageWithURL:[NSURL URLWithString:thumbnalString]  placeholderImage:[UIImage imageNamed:@"photoDefault"]];
                        }
                    } else {
                        [imageCell.mediaImageView setImage:message.sendImage];
                    }
                }
                    break;
                case sendStatusSending:
                {
                    UIImage *sendImage = message.sendImage;
                    [imageCell.mediaImageView setImage:sendImage];
                }
                    break;
                case sendStatusFailed:
                {
                    UIImage *sendImage = message.sendImage;
                    [imageCell.mediaImageView setImage:sendImage];
                }
                    break;
                    
                default:
                    break;
            }
    
            return imageCell;
        } else {
            TBFileTableViewCell *fileCell;
            if (message.isSend) {
                fileCell = (TBFileSendTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:fileSendCellIdentifier];
            } else {
                fileCell = (TBFileTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
                if (fileCell.avatarLongPressRecognizer == nil) {
                    fileCell.avatarLongPressRecognizer = avatarLongPressRecognizer;
                }
                if (fileCell.avatarGestureRecognizer == nil) {
                    fileCell.avatarGestureRecognizer = avatarTapRecognizer;
                }
            }
            fileCell.transform = self.tableView.transform;
            [fileCell setMessage:message andAttachment:attachment];
            if (fileCell.longPressRecognizer == nil) {
                fileCell.longPressRecognizer = longPressRecognizer;
            }
            
            return fileCell;
        }
        
    }
    // speech
    else if ([category isEqualToString:kDisplayModeSpeech]) {
        TBVoiceCell *voiceCell;
        if (message.isSend) {
            voiceCell = (TBVoiceSendCell *)[self.tableView dequeueReusableCellWithIdentifier:voiceSendCellIdentifier];
        } else {
            voiceCell = (TBVoiceCell *)[self.tableView dequeueReusableCellWithIdentifier:voiceCellIdentifier];
            if (voiceCell.avatarGestureRecognizer == nil) {
                voiceCell.avatarGestureRecognizer = avatarTapRecognizer;
            }
            if (voiceCell.avatarLongPressRecognizer == nil) {
                voiceCell.avatarLongPressRecognizer = avatarLongPressRecognizer;
            }
        }
        voiceCell.transform = self.tableView.transform;
        voiceCell.bubbleTintColor = chatTintColor;
        voiceCell.message = message;
        voiceCell.delegate = self;
        if (voiceCell.longPressRecognizer == nil) {
            voiceCell.longPressRecognizer = longPressRecognizer;
        }
        
        return voiceCell;
    }
    //rtf,snippet,quote
    else if ([category isEqualToString:kDisplayModeRtf] || [category isEqualToString:kDisplayModeQuote] || [category isEqualToString:kDisplayModeSnippet]) {
        TBWeiboCell *weiboChatCell;
        if (message.isSend) {
            weiboChatCell = (TBWeiboSendCell *)[self.tableView dequeueReusableCellWithIdentifier:weiboSendCellIdentifier];
        } else {
            weiboChatCell = (TBWeiboCell *)[self.tableView dequeueReusableCellWithIdentifier:weiboCellIdentifier];
        }
        weiboChatCell.transform = self.tableView.transform;
        weiboChatCell.delegate = self;
        weiboChatCell.bubbleTintColor = chatTintColor;
        [weiboChatCell setMessage:message andAttachment:attachment];
        if (weiboChatCell.longPressRecognizer == nil) {
            weiboChatCell.longPressRecognizer = longPressRecognizer;
        }
        
        return weiboChatCell;
    }
    //message attachment
    else if ([category isEqualToString:kDisplayModeMessage]) {
        TBAttachementMessageCell *achementMessageCell;
        if (message.isSend) {
            achementMessageCell = (TBAttatchmentMessageSendCell *)[self.tableView dequeueReusableCellWithIdentifier:attachmentMessageSendCellIdentifier];
        } else {
            achementMessageCell = (TBAttachementMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:attachmentMessageCellIdentifier];
        }
        achementMessageCell.transform = self.tableView.transform;
        achementMessageCell.delegate = self;
        [achementMessageCell setMessage:message andAttachment:attachment];
        return achementMessageCell;
    }
    /* message attachment and other unknown category*/
    else {
        TbChatTableViewCell *chatCell;
        if (message.isSend) {
            chatCell = (TBChatSendTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:sendCellIdentifier];
        } else {
            chatCell = (TbChatTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        chatCell.transform = self.tableView.transform;
        chatCell.messageContentLabel.delegate = self;
        chatCell.messageContentLabel.userInteractionEnabled = YES;
        chatCell.bubbleTintColor = chatTintColor;
        chatCell.message = message;
        chatCell.messageContentLabel.text = NSLocalizedString(@"Not Support this attachment", @"Not Support this attachment");
        chatCell.userAvatorImageView.hidden = YES;
        chatCell.imageShadowView.hidden = YES;
        return chatCell;
    }
}

- (void)checkTagWithModel:(TBMessage *)model forCell:(TBChatBaseCell *)cell {
    if (model.tags.count > 0) {
        cell.tagImg.hidden = NO;
    } else {
        cell.tagImg.hidden = YES;
    }
}

#pragma mark - MessageEditViewControllerDelegate

-(void)messageEditCancel
{
    isEditingMessage = NO;
}
-(void)messageEditSaveWith:(NSString *)changedMessageStr andOriginMessage:(TBMessage *)originMessage
{
    isEditingMessage = NO;
    DDLogDebug(@"%@",changedMessageStr);
    NSString *sendStr = [changedMessageStr stringByReplacingEmojiUnicodeWithCheatCodes];
    NSString *regularString  =[self getRegularExpressionFromMessageStr:sendStr];
    NSDictionary *tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:regularString,@"body",nil];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:@"%@/%@",kSendMessageURLString,originMessage.id] parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        TBMessage *updateMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                             fromJSONDictionary:responseObject
                                                          error:NULL];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSError *error;
            MOMessage *moMessage = [MTLManagedObjectAdapter
                                    managedObjectFromModel:updateMessage
                                    insertingIntoContext:localContext
                                    error:&error];
            if (moMessage==nil) {
                DDLogDebug(@"[NSManagedObject] Error:%@",error);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kSocketMessageUpdate object:updateMessage];
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"error%@",error);
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Edit fail", @"Edit fail")];
    }];
}

#pragma mark - TbChatTableViewCellDelegate

- (void)checkReceiptForMessage:(TBMessage *)message {
    MentionReceiptViewController *mentionReceiptVC = [[MentionReceiptViewController alloc] init];
    mentionReceiptVC.receiptMembers = [MOUser findUsersWithIds:message.receiptors];
    mentionReceiptVC.otherMembers = [MOUser findUsersWithIds:message.mentions NotIncludeIds:message.receiptors];
    [self.navigationController pushViewController:mentionReceiptVC animated:YES];
}

#pragma mark - TBQuoteTableViewCellDelegate

-(void)jumpToQuoteURLWithAttachment:(TBAttachment *)attachment
{
    NSString *quoteCategory = attachment.category;
    NSString *redirectURLString = attachment.data[kQuoteRedirectUrl];
    if (redirectURLString) {
        NSURL *directURL = [NSURL URLWithString:redirectURLString];
        if (directURL) {
            [self attributedLabel:nil didSelectLinkWithURL:directURL];
        } else {
            [self jumpToHyperDetailWith:attachment.data[kQuoteText]];
        }
    }
    else if([quoteCategory isEqualToString:kDisplayModeSnippet]) {
        NSString *codeType = attachment.data[kCodeType];
        CodeViewController *codeVC = [[CodeViewController alloc]init];
        codeVC.codeTitle = attachment.data[kQuoteTitle];
        codeVC.language = codeType;
        codeVC.snippet = attachment.data[kQuoteText];
        [self.navigationController pushViewController:codeVC animated:YES];
    }
    else {
        [self jumpToHyperDetailWith:attachment.data[kQuoteText]];
    }
}

#pragma mark - TBVoiceCellDelegate
- (void)stopVoicePlay {
    [recordAudio stopPlay];
}

- (void)playVoiceWithMessage:(TBMessage *)message {
    if (self.playingVoiceMessage) {
        NSInteger sendMessageIndex = [self.chatDataArray indexOfObject:self.playingVoiceMessage];
        TBVoiceCell *voiceCell = (TBVoiceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendMessageIndex]];
        [voiceCell playMessage:nil];
        [recordAudio stopPlay];
    }
    self.playingVoiceMessage = message;
    
    if (message.sendStatus == sendStatusFailed) {
        NSData *voiceData = [NSData dataWithContentsOfFile:message.voiceLocalAMRPath];
        [recordAudio play:voiceData];
        return;
    }
    
    TBAttachment *attachment = [message.attachments firstObject];
    NSString *fileKey = attachment.data[kFileKey];
    NSURL *downloadURL = [NSURL URLWithString:attachment.data[kFileDownloadUrl]];
    NSString *localVoicePath = [TBUtility getVoiceLocalPathWithFileKey:fileKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localVoicePath]) {
        NSData *voiceData = [NSData dataWithContentsOfFile:localVoicePath];
        [recordAudio play:voiceData];
        return;
    }
    // If it's not a local file, put a placeholder instead
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    
    AFHTTPRequestOperation * tempRequest = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    tempRequest.outputStream = [NSOutputStream outputStreamToFileAtPath:localVoicePath append:NO];
    [tempRequest setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat progress = (totalBytesRead*1.0) / totalBytesExpectedToRead;
        DDLogDebug(@"voice downloading:%2f",progress);
    }];
    
    [tempRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *voiceData = [NSData dataWithContentsOfFile:localVoicePath];
            [recordAudio play:voiceData];
        });
        if (message.isUnread) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MOMessage *voiceMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:message.id inContext:localContext];
                voiceMessage.isUnreadValue = NO;
            } completion:^(BOOL success, NSError *error) {
                message.isUnread = NO;
                DDLogDebug(@"Has read this voice message");
            }];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           if ([[NSFileManager defaultManager] fileExistsAtPath:localVoicePath]) {
                                               [[NSFileManager defaultManager] removeItemAtPath:localVoicePath error:NULL];
                                           }
                                       }];
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:tempRequest];
}

#pragma mark - TBAttachementMessageCellDelegate

- (void)enterRoomWithId:(NSString *)roomId {
    MORoom *room = [MORoom MR_findFirstByAttribute:@"id" withValue:roomId];
    if (room) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareForTopic object:room];
    }
}

-(void)jumpToHyperDetailWith:(NSString *)hyperText
{
    HyperDetailViewController *hyperDeatailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HyperDetailViewController"];
    hyperDeatailVC.hyperString = hyperText;
    [self.navigationController pushViewController:hyperDeatailVC animated:YES];
}

#pragma mark - TTTAttributedLabelDelegate
//URL
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *mailPrefix = @"mailto:";
    if ([url.absoluteString hasPrefix:mailPrefix]) {
        [self sendEmail:[url.absoluteString stringByReplacingOccurrencesOfString:mailPrefix withString:@""]];
    } else {
        //support jump to other APP
        NSString *urlScheme = [url scheme];
        if (![[urlScheme lowercaseString] isEqualToString:@"http"] && ![[urlScheme lowercaseString] isEqualToString:@"https"])
        {
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            return;
        }
        
        //support jump to AppStore
        NSString *requestedURL = [url absoluteString];
        if([requestedURL  rangeOfString:@"itunes"].location != NSNotFound ||[requestedURL  rangeOfString:@"appsto.re"].location != NSNotFound)
        {
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            return;
        }
        
        JLWebViewController *jsViewController = [[JLWebViewController alloc]init];
        jsViewController.urlString = url.absoluteString;
        [self.navigationController pushViewController:jsViewController animated:YES];
    }
}

//phone
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    DDLogDebug(phoneNumber);
    BOOL canCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
    }];
    if (canCall) {
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Call", @"Call") withBlock:^(NSInteger theButtonIndex) {
            [self callWithNumber:phoneNumber];
        }];
    }
    [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Copy", @"Copy") withBlock:^(NSInteger theButtonIndex) {
        [[UIPasteboard generalPasteboard] setString:phoneNumber];
    }];
    [actionSheet showInView:self.view];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point {
    DDLogDebug(@"long press url");
    NSIndexPath *pressedIndexPath =[self.tableView indexPathForRowAtPoint:[label.longPressGestureRecognizer locationInView:self.tableView]];
    [self showMenuControllerWithIndexPath:pressedIndexPath];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithPhoneNumber:(NSString *)phoneNumber
                atPoint:(CGPoint)point {
    DDLogDebug(@"long press phone");
    NSIndexPath *pressedIndexPath =[self.tableView indexPathForRowAtPoint:[label.longPressGestureRecognizer locationInView:self.tableView]];
    [self showMenuControllerWithIndexPath:pressedIndexPath];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex] ) {
        [self.textView setText:nil];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

#pragma mark - MultiplePhoneCallDelegate

-(void)selectUserArray:(NSArray *)userArray {
    CallingViewController *callingVC = [[CallingViewController alloc] initWithNibName:@"CallingViewController" bundle:nil];
    [callingVC callGroup:userArray];
    [self presentViewController:callingVC animated:YES completion:nil];
}

#pragma mark - UIPreviewActionItem

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *okAction = [UIPreviewAction actionWithTitle:[NSString stringWithFormat:@"\"%@\"",NSLocalizedString(@"OK", @"OK")] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self sendTextMessageToServer:NSLocalizedString(@"OK", @"OK")];
    }];
    
    UIPreviewAction *thanksAction = [UIPreviewAction actionWithTitle:[NSString stringWithFormat:@"\"%@\"",NSLocalizedString(@"Thanks!", @"Thanks!")] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self sendTextMessageToServer:NSLocalizedString(@"Thanks!", @"Thanks!")];
    }];
    
    UIPreviewAction *talkLaterAction = [UIPreviewAction actionWithTitle:[NSString stringWithFormat:@"\"%@\"",NSLocalizedString(@"Talk later?", @"Talk later?")] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self sendTextMessageToServer:NSLocalizedString(@"Talk later?", @"Talk later?")];
    }];
    
    return @[okAction,thanksAction,talkLaterAction];
}


@end
