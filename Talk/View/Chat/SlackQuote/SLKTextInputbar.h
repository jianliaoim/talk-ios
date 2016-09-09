//
//   Copyright 2014 Slack Technologies, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <UIKit/UIKit.h>

@class ChatViewController;
@class SLKTextView;

extern NSString * const SCKInputAccessoryViewKeyboardFrameDidChangeNotification;

/** @name A custom tool bar encapsulating messaging controls. */
@interface SLKTextInputbar : UIToolbar

/** A weak reference to the core view controller. */
@property (nonatomic, weak) ChatViewController *controller;

/** The centered text input view.
 @discussion The maximum number of lines is configured by default, to best fit each devices dimensions.
 For iPhone 4       (<=480pts): 4 lines
 For iPhone 5 & 6   (>=568pts): 6 lines
 For iPad           (>=768pts): 8 lines: 8 lines
 */
@property (nonatomic, strong) SLKTextView *textView;

/** The left action button . */
@property (nonatomic, strong) UIButton *leftButton;

/** The center action button . */
@property (nonatomic, strong) UIButton *centerButton;

/** The right action button . */
@property (nonatomic, strong) UIButton *rightButton;

/** The voice action button . */
@property (nonatomic, strong) UIButton *speakButton;

/** The inner padding to use when laying out content in the view. Default is {5, 8, 5, 8}. */
@property (nonatomic, assign) UIEdgeInsets contentInset;

@end
