/*
 * Copyright (c) 2012, Arash Payan
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 * 
 * +Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 * +Redistributions in binary form must reproduce the above
 *  copyright notice, this list of conditions and the following
 *  disclaimer in the documentation and/or other materials provided
 *  with the distribution.
 * +Neither the name of Arash Payan nor the names of its 
 *  contributors may be used to endorse or promote products derived
 *  from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

@protocol APTokenFieldDataSource;
@protocol APTokenFieldDelegate;
@class APShadowView;

#import <UIKit/UIKit.h>

@interface APSolidLine : UIView

@property(nonatomic) UIColor *color;

@end

@interface APTokenView : UIView

@end

@interface APTokenField : UIControl <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate> {
    UILabel *label;
    NSUInteger numberOfResults;
}

@property(nonatomic, strong) NSDictionary *tokenColors;
@property(nonatomic) NSUInteger tokensLimit;
@property(nonatomic, strong) NSMutableArray *tokens;
@property(nonatomic, strong) UIView *backingView;
@property(nonatomic) APSolidLine *solidLine;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, copy) NSString *labelText;
@property(nonatomic, strong) UILabel *placeholder;
@property(nonatomic, readonly) UITableView *resultsTable;
@property(nonatomic, strong) UIView *rightView;
@property(weak, nonatomic, readonly) NSString *text;
@property(nonatomic, weak) id <APTokenFieldDataSource> tokenFieldDataSource;
@property(nonatomic, weak) id <APTokenFieldDelegate> tokenFieldDelegate;

- (void)addObject:(id)object;

- (void)resetField;

- (void)removeObject:(id)object;

- (NSUInteger)objectCount;

- (id)objectAtIndex:(NSUInteger)index;

@end

@protocol APTokenFieldDataSource <NSObject>

@required
- (NSString *)tokenField:(APTokenField *)tokenField titleForObject:(id)anObject;

- (NSUInteger)numberOfResultsInTokenField:(APTokenField *)tokenField;

- (id)tokenField:(APTokenField *)tokenField objectAtResultsIndex:(NSUInteger)index;

- (void)tokenField:(APTokenField *)tokenField searchQuery:(NSString *)query;

@optional
/* If you don't implement this method, then the results table will use
 UITableViewCellStyleDefault with the value provided by
 tokenField:titleForObject: as the textLabel of the UITableViewCell. */
- (UITableViewCell *)tokenField:(APTokenField *)tokenField tableView:(UITableView *)tableView cellForIndex:(NSUInteger)index;

- (CGFloat)resultRowsHeightForTokenField:(APTokenField *)tokenField;

@end


@protocol APTokenFieldDelegate <NSObject>

@optional
- (void)tokenField:(APTokenField *)tokenField tableView:(UITableView *)tableView didSelectIndex:(NSUInteger)index;

/* Called when the user adds an object from the results list. */
- (void)tokenField:(APTokenField *)tokenField didAddObject:(id)object;

/* Called when the user deletes an object from the token field. */
- (void)tokenField:(APTokenField *)tokenField didRemoveObject:(id)object;

- (void)tokenFieldDidBeginEditing:(APTokenField *)tokenField;

- (void)tokenFieldDidEndEditing:(APTokenField *)tokenField;

/* Called when the user taps the 'enter'. */
- (void)tokenFieldDidReturn:(APTokenField *)tokenField;

- (BOOL)tokenField:(APTokenField *)tokenField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end