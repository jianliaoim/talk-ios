//
//  ChatViewController.h
//  Talk
//
//  Created by zhangxiaolian on 14/10/9.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextInputbar.h"
#import "SLKTypingIndicatorView.h"
#import "SLKTextView.h"
#import "UIScrollView+SLKAdditions.h"
#import "UITextView+SLKAdditions.h"
#import "UIView+SLKAdditions.h"
#import "TBRefreshViewController.h"

#import "TBMessage.h"
#import "TBRoom.h"
#import "MOUser.h"
#import "MOStory.h"

@class RecentMessagesViewController;

typedef NS_ENUM(NSUInteger, SLKKeyboardStatus) {
    SLKKeyboardStatusDidHide,
    SLKKeyboardStatusWillShow,
    SLKKeyboardStatusDidShow,
    SLKKeyboardStatusWillHide
};

typedef NS_ENUM(NSUInteger, ChatRoomType) {
    ChatRoomTypeForTeamMember,  //chat for  one team member
    ChatRoomTypeForRoom,        //chat for a room
    ChatRoomTypeForStory,       //chat for a story
};

typedef NS_ENUM(NSUInteger, ChatStyle) {
    ChatStyleCommon,        // common chat, default
    ChatStyleSearch,        // Search chat
    ChatStyleLeft,
};

@interface ChatViewController : TBRefreshViewController<UITableViewDataSource,UITableViewDelegate>
@property (assign, nonatomic) ChatStyle chatStyle;         // chat Style
@property (assign, nonatomic) ChatRoomType roomType;       // chat roomType
@property (strong, nonatomic) MOUser *currentToMember;     // for team member
@property (strong, nonatomic) MORoom *currentRoom;         //current room chat
@property (strong, nonatomic) MOStory *currentStory;       //current room chat
@property (strong, nonatomic) TBMessage *searchedMessage;
@property (assign, nonatomic) BOOL refreshWhenViewDidLoad;  //refresh or not when view DidLoad
@property (assign, nonatomic) BOOL isPreView;               //is Preview model or not
@property (assign, nonatomic) BOOL isArchived;              //is Archived model or not

/** The bottom toolbar containing a text view and buttons. */
@property (strong, nonatomic) SLKTextInputbar *textInputbar;

/** YES if control's animation should have bouncy effects. Default is YES. */
@property (assign, nonatomic) BOOL bounces;

/** YES if text view's content can be cleaned with a shake gesture. Default is NO. */
@property (assign, nonatomic) BOOL undoShakingEnabled;

/** YES if keyboard can be dismissed gradually with a vertical panning gesture. Default is YES. */
@property (assign, nonatomic) BOOL keyboardPanningEnabled;

/** YES if an external keyboard has been detected (this value only changes when the text view becomes first responder). */
@property (nonatomic, readonly, getter=isExternalKeyboard) BOOL externalKeyboard;

/**
 YES if the main table view is inverted. Default is YES.
 @discussion This allows the table view to start from the bottom like any typical messaging interface.
 If inverted, you must assign the same transform property to your cells to match the orientation (ie: cell.transform = tableView.transform;)
 Inverting the table view will enable some great features such as content offset corrections automatically when resizing the text input and/or showing autocompletion.
 
 Updating this value also changes 'edgesForExtendedLayout' value. When inverted, it must be UIRectEdgeNone, to display correctly all the elements. Otherwise, UIRectEdgeAll is set.
 */
@property (nonatomic, assign, getter = isInverted) BOOL inverted;

/** YES if the view controller is presented inside of a popover controller. If YES, the keyboard won't move the text input bar and tapping on the tableView/collectionView will not cause the keyboard to be dismissed. This doesn't do anything on iPhone. */
@property (nonatomic, getter = isPresentedInPopover) BOOL presentedInPopover;

/** Convenience accessors (accessed through the text input bar) */
@property (nonatomic, readonly) SLKTextView *textView;
@property (nonatomic, readonly) UIButton *leftButton;
@property (nonatomic, readonly) UIButton *centerButton;
@property (nonatomic, readonly) UIButton *rightButton;
@property (nonatomic, readonly) UIButton *speakButton;


/**
 Presents the keyboard, if not already, animated.
 
 @param animated YES if the keyboard should show using an animation.
 */
- (void)presentKeyboard:(BOOL)animated;

/**
 Dimisses the keyboard, if not already, animated.
 
 @param animated YES if the keyboard should be dismissed using an animation.
 */
- (void)dismissKeyboard:(BOOL)animated;

/**
 Notifies the view controller that the keyboard changed status.
 @discussion You can override this method to perform additional tasks associated with presenting the view. You don't need call super since this method doesn't do anything.
 
 @param status The new keyboard status.
 */
- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status;


///------------------------------------------------
/// @name Text Typing Notifications
///------------------------------------------------

/**
 Notifies the view controller that the text will update.
 @discussion You can override this method to perform additional tasks associated with presenting the view. You don't need call super since this method doesn't do anything.
 */
- (void)textWillUpdate;

/**
 Notifies the view controller that the text did update.
 @discussion You can override this method to perform additional tasks associated with presenting the view. You MUST call super at some point in your implementation.
 
 @param If YES, the text input bar will be resized using an animation.
 */
- (void)textDidUpdate:(BOOL)animated;

/**
 Notifies the view controller when the user has pasted an image inside of the text view.
 @discussion You can override this method to perform additional tasks associated with image pasting.
 
 @param image The image that has been pasted. Only JPG or PNG are supported.
 */
- (void)didPasteImage:(UIImage *)image;

/**
 Verifies that the typing indicator view should be shown. Default is YES, if meeting some requierements.
 @discussion You must override this method to perform perform additional verifications before displaying the typing indicator.
 
 @return YES if the typing indicator view should be shown.
 */
- (BOOL)canShowTypeIndicator;

/**
 Notifies the view controller when the user has shaked the device for undoing text typing.
 @discussion You can override this method to perform additional tasks associated with the shake gesture. Calling super will prompt a system alert view with undo option. This will not be called if 'undoShakingEnabled' is set to NO and/or if the text view's content is empty.
 */
- (void)willRequestUndo;

/**
 Notifies the view controller when the user has pressed the Return key (↵) with an external keyboard.
 @discussion You can override this method to perform additional tasks.
 */
- (void)didPressReturnKey:(id)sender;

/**
 Notifies the view controller when the user has pressed the Escape key (Esc) with an external keyboard.
 @discussion You can override this method to perform additional tasks.
 */
- (void)didPressEscapeKey:(id)sender;

///------------------------------------------------
/// @name Text Typing Auto-Completion
///------------------------------------------------


//*******add by zhangxiaolian*********

@property (nonatomic, strong) NSString *slkTextViewChangedStr;

/** The recently found prefix symbol used as prefix for autocompletion mode. */
@property (nonatomic, readonly) NSString *foundPrefix;

/** The range of the found prefix in the text view content. */
@property (nonatomic, readonly) NSRange foundPrefixRange;

/** The recently found word at the textView caret position. */
@property (nonatomic, readonly) NSString *foundWord;

/** YES if the autocompletion mode is active. */
@property (nonatomic, readonly, getter = isAutoCompleting) BOOL autoCompleting;

/** An array containing all the registered prefix strings for autocompletion. */
@property (nonatomic, readonly) NSArray *registeredPrefixes;

/**
 Registers any string prefix for autocompletion detection, useful for user mentions and/or hashtags autocompletion.
 @discussion The prefix must be valid NSString (i.e: '@', '#', '\', and so on)
 This also checks if no repeated prefix is inserted.
 
 @param prefixes An array of prefix strings.
 */
- (void)registerPrefixesForAutoCompletion:(NSArray *)prefixes;

/**
 Verifies that the autocompletion view should be shown. Default is NO.
 @discussion You must override this method to perform additional tasks, before autocompletion is shown, like populating the data source.
 
 @return YES if the autocompletion view should be shown.
 */
- (BOOL)canShowAutoCompletion;

/**
 Returns a custom height for the autocompletion view. Default is 0.0.
 @discussion You can override this method to return a custom height.
 
 @return The autocompletion view's height.
 */
- (CGFloat)heightForAutoCompletionView;

/**
 Returns the maximum height for the autocompletion view. Default is 140.0.
 @discussion You can override this method to return a custom max height.
 
 @return The autocompletion view's max height.
 */
- (CGFloat)maximumHeightForAutoCompletionView;

/**
 Cancels and hides the autocompletion view, animated
 */
- (void)cancelAutoCompletion;

/**
 Accepts the autocompletion, replacing the detected key and word with a new string.
 
 @param string The string to be used for replacing autocompletion placeholders.
 */
- (void)acceptAutoCompletionWithString:(NSString *)string;


///------------------------------------------------
/// @name Miscellaneous
///------------------------------------------------

/**
 Allows subclasses to use the super implementation of this method.
 */
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;


//RecentViewController for 3d touch
@property (weak, nonatomic) RecentMessagesViewController *recentMessagesViewController;


@end
