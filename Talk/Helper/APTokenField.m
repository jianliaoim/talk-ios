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

#import "APTokenField.h"
#import "UIColor+TBColor.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

static NSString *const kHiddenCharacter = @"\u200B";

@interface APTextField : UITextField {
}
@end

@implementation APTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([self.text isEqualToString:kHiddenCharacter]) {
        return (action == @selector(paste:)) ? YES : NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end

@implementation APSolidLine

- (void)drawRect:(CGRect)rect {
    CGFloat red = 204.0 / 255.0, green = 204.0 / 255.0, blue = 204.0 / 255.0, alpha = 1.0;

    if (_color != nil) {
        [_color getRed:&red green:&green blue:&blue alpha:&alpha];
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat lineColor[4] = {red, green, blue, alpha};
    CGContextSetFillColor(ctx, lineColor);
    CGContextFillRect(ctx, rect);
}

@end

@interface APShadowView : UIView {
    CAGradientLayer *shadowLayer;
}

@end

@implementation APShadowView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        shadowLayer = [[CAGradientLayer alloc] init];
        shadowLayer.colors = @[(id) [UIColor colorWithRed:10.0/255.f green:11.0/255.f blue:11.0/255.f alpha:0.3].CGColor,
                (id) [UIColor colorWithWhite:1 alpha:0].CGColor];
        [self.layer addSublayer:shadowLayer];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    shadowLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

@end

#define TOKEN_HZ_PADDING 8.5
#define TOKEN_VT_PADDING 2.5

@interface APTokenView ()

@property(nonatomic, strong) NSDictionary *colors;
@property(nonatomic, assign) BOOL highlighted;
@property(nonatomic, strong) id object;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, weak) APTokenField *tokenField;

+ (APTokenView *)tokenWithTitle:(NSString *)aTitle object:(id)anObject colors:(NSDictionary *)colors;

- (id)initWithTitle:(NSString *)aTitle object:(id)anObject colors:(NSDictionary *)colors;

@end

@implementation APTokenView

+ (APTokenView *)tokenWithTitle:(NSString *)aTitle object:(id)anObject colors:(NSDictionary *)colors {
    return [[APTokenView alloc] initWithTitle:aTitle object:anObject colors:colors];
}

- (id)initWithTitle:(NSString *)aTitle object:(id)anObject colors:(NSDictionary *)colors {
    if (self = [super initWithFrame:CGRectZero]) {
        _highlighted = NO;
        self.title = aTitle;
        self.backgroundColor = [UIColor clearColor];
        self.object = anObject;
        self.colors = colors;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGSize titleSize = [_title sizeWithFont:_tokenField.font];

    CGRect bounds = CGRectMake(0, 0, titleSize.width + TOKEN_HZ_PADDING * 2.0, titleSize.height + TOKEN_VT_PADDING * 2.0);
    CGRect textBounds = bounds;
    textBounds.origin.x = (bounds.size.width - titleSize.width) / 2;
    textBounds.origin.y += 4;

    CGFloat arcValue = (bounds.size.height / 2) + 1;

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGPoint endPoint = CGPointMake(1, self.bounds.size.height + 10);

    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, arcValue, arcValue, arcValue, (M_PI / 2), (3 * M_PI / 2), NO);
    CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue, 3 * M_PI / 2, M_PI / 2, NO);
    CGContextClosePath(context);

    if (_highlighted) {
        UIColor *highlightedColor = [UIColor jl_redColor];
        CGFloat r, g, b, a;
        [highlightedColor getRed:&r green:&g blue:&b alpha:&a];

        if ([_colors valueForKey:@"highlightedBorderColor"] != nil) {
            [[_colors valueForKey:@"highlightedBorderColor"] getRed:&r green:&g blue:&b alpha:&a];
        }
        CGContextSetFillColor(context, (CGFloat[8]) {r, g, b, a});
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    } else {
        CGContextClip(context);
        CGFloat locations[2] = {0, 0.95};
        CGFloat red = 0.631, green = 0.733, blue = 1.0, alpha = 1.0, aRed = 0.463, aGreen = 0.510, aBlue = 0.839, aAlpha = 1.0;
        if ([_colors valueForKey:@"normalBorderTopColor"] != nil) {
            [[_colors valueForKey:@"normalBorderTopColor"] getRed:&red green:&green blue:&blue alpha:&alpha];
        }
        if ([_colors valueForKey:@"normalBorderBottomColor"] != nil) {
            [[_colors valueForKey:@"normalBorderBottomColor"] getRed:&aRed green:&aGreen blue:&aBlue alpha:&aAlpha];
        }
//        CGFloat components[8] = {red, green, blue, alpha, aRed, aGreen, aBlue, aAlpha};
        [[UIColor jl_redColor] setFill];
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }

    UIColor *normalFontColor = [UIColor blackColor], *highlightedFontColor = [UIColor whiteColor];
    if ([_colors valueForKey:@"normalFontColor"] != nil) {
        normalFontColor = [_colors valueForKey:@"normalFontColor"];
    }
    if ([_colors valueForKey:@"highlightedFontColor"] != nil) {
        highlightedFontColor = [_colors valueForKey:@"highlightedFontColor"];
    }
    [(_highlighted ? highlightedFontColor : normalFontColor) set];
    [_title drawInRect:textBounds withFont:_tokenField.font];
}

- (CGSize)desiredSize {
    CGSize titleSize = [_title sizeWithFont:_tokenField.font];
    titleSize.width += TOKEN_HZ_PADDING * 2.0;
    titleSize.height += TOKEN_VT_PADDING * 2.0 + 2;
    return titleSize;
}

@end

@interface APTokenField ()

@property(nonatomic, strong) APShadowView *shadowView;
@property(nonatomic, strong) APTextField *textField;
@property(nonatomic, strong) UIScrollView *tokenContainer;

@end

@implementation APTokenField

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _backingView = [[UIView alloc] initWithFrame:CGRectZero];
        _backingView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backingView];

        numberOfResults = 0;
        self.font = [UIFont systemFontOfSize:14];

        _tokenContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _tokenContainer.scrollsToTop = NO;
        _tokenContainer.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedTokenContainer)];
        [_tokenContainer addGestureRecognizer:tapGesture];
        [self addSubview:_tokenContainer];

        _resultsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _resultsTable.dataSource = self;
        _resultsTable.delegate = self;
        [self addSubview:_resultsTable];

        _placeholder = [[UILabel alloc] init];
        _placeholder.font = [UIFont systemFontOfSize:15];
        _placeholder.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        _placeholder.textAlignment = NSTextAlignmentCenter;
        _placeholder.backgroundColor = [UIColor clearColor];
        [self addSubview:_placeholder];

        self.shadowView = [[APShadowView alloc] initWithFrame:CGRectZero];
        [self addSubview:_shadowView];
        self.textField = [[APTextField alloc] initWithFrame:CGRectZero];
        _textField.text = kHiddenCharacter;
        _textField.delegate = self;
        _textField.font = _font;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeEmailAddress;
        if ([UITextField respondsToSelector:@selector(setSpellCheckingType:)])
            _textField.spellCheckingType = UITextSpellCheckingTypeNo;
        [_tokenContainer addSubview:_textField];

        self.tokens = [[NSMutableArray alloc] init];

        _solidLine = [[APSolidLine alloc] initWithFrame:CGRectZero];
        [self addSubview:_solidLine];
    }

    return self;
}

- (void)addObject:(id)object {
    if (object == nil)
        [NSException raise:@"IllegalArgumentException" format:@"You can't add a nil object to an APTokenField"];

    NSString *title = nil;
    if (_tokenFieldDataSource != nil)
        title = [_tokenFieldDataSource tokenField:self titleForObject:object];

    // if we still don't have a title for it, we'll use the Obj-c name
    if (title == nil)
        title = [NSString stringWithFormat:@"%@", object];

    APTokenView *token = [APTokenView tokenWithTitle:title object:object colors:_tokenColors];
    token.tokenField = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedToken:)];
    [token addGestureRecognizer:tapGesture];
    [_tokens addObject:token];
    [_tokenContainer addSubview:token];

    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenField:didAddObject:)])
        [_tokenFieldDelegate tokenField:self didAddObject:object];

    [self resetField];

}

- (void)resetField {
    [_tokenFieldDataSource tokenField:self searchQuery:@""];
    _textField.text = kHiddenCharacter;

    [self setNeedsLayout];
}

- (void)removeObject:(id)object {
    if (object == nil)
        return;

    for (int i = 0; i < [_tokens count]; i++) {
        APTokenView *t = _tokens[i];
        if ([t.object isEqual:object]) {
            [t removeFromSuperview];
            [_tokens removeObjectAtIndex:i];
            [self setNeedsLayout];

            if ([_tokenFieldDelegate respondsToSelector:@selector(tokenField:didRemoveObject:)])
                [_tokenFieldDelegate tokenField:self didRemoveObject:object];

            return;
        }
    }
}

- (NSUInteger)objectCount {
    return [_tokens count];
}

- (id)objectAtIndex:(NSUInteger)index {
    APTokenView *t = _tokens[index];
    return t.object;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_textField isFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [_textField canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

#define CONTAINER_PADDING      8
#define CONTAINER_PADDING_VT      12
#define MINIMUM_TEXTFIELD_WIDTH   40
#define CONTAINER_ELEMENT_VT_MARGIN 8
#define CONTAINER_ELEMENT_HZ_MARGIN 8

- (void)layoutSubviews {
    CGRect bounds = self.bounds;

    // calculate the starting x (containerWidth) and y (containerHeight) for our layout
    float containerWidth = 0;
    if (label != nil)   // we adjust the starting y in case the user specified labelText
    {
        [label sizeToFit];
        CGRect labelBounds = label.bounds;
        // we want the base of the label text to be the same as the token label base
        label.frame = CGRectMake(CONTAINER_PADDING,
                /* the +2 is because [label sizeToFit] isn't a tight fit (2 pixels of gap) */
                CONTAINER_PADDING_VT + TOKEN_VT_PADDING + _font.lineHeight - label.font.lineHeight + 2,
                labelBounds.size.width,
                labelBounds.size.height);
        containerWidth = CGRectGetMaxX(label.frame) + CONTAINER_PADDING;
    }
    else
        containerWidth = CONTAINER_PADDING;
    float containerHeight = CONTAINER_PADDING_VT;
    APTokenView *lastToken = nil;
    float rightViewWidth = 0;
    if (_rightView)
        rightViewWidth = _rightView.bounds.size.width + CONTAINER_ELEMENT_HZ_MARGIN;
    // layout each of the tokens
    for (APTokenView *token in _tokens) {
        CGSize desiredTokenSize = [token desiredSize];
        if (containerWidth + desiredTokenSize.width > bounds.size.width - CONTAINER_PADDING - rightViewWidth) {
            containerHeight += desiredTokenSize.height + CONTAINER_ELEMENT_VT_MARGIN;
            containerWidth = CONTAINER_PADDING;
        }

        token.frame = CGRectMake(containerWidth, containerHeight, desiredTokenSize.width, desiredTokenSize.height);
        containerWidth += desiredTokenSize.width + CONTAINER_ELEMENT_HZ_MARGIN;

        lastToken = token;
    }

    // let's place the textfield now
    if (containerWidth + MINIMUM_TEXTFIELD_WIDTH > bounds.size.width - CONTAINER_PADDING - rightViewWidth) {
        containerHeight += lastToken.bounds.size.height + CONTAINER_ELEMENT_VT_MARGIN;
        containerWidth = CONTAINER_PADDING;
    }
    _textField.frame = CGRectMake(containerWidth, containerHeight + TOKEN_VT_PADDING, CGRectGetMaxX(bounds) - CONTAINER_PADDING - containerWidth, _font.lineHeight);

    // now that we know the size of all the tokens, we can set the frame for our container
    // if there are some results, then we'll only show the last row of the container, otherwise, we'll show all of it
    float minContainerHeight = _font.lineHeight + TOKEN_VT_PADDING * 2.0 + 2 + CONTAINER_PADDING_VT * 2.0;
    float maxContainerHeight = (_font.lineHeight + TOKEN_VT_PADDING * 2.0 + 2) * 2 + CONTAINER_ELEMENT_VT_MARGIN + CONTAINER_PADDING_VT * 2.0;
    float tokenContainerWidth = 0;
    if (_rightView)
        tokenContainerWidth = bounds.size.width - 5 - _rightView.bounds.size.width - 5;
    else
        tokenContainerWidth = bounds.size.width;
//    if (numberOfResults == 0)
//        _tokenContainer.frame = CGRectMake(0, 0, tokenContainerWidth, MAX(minContainerHeight, containerHeight + lastToken.bounds.size.height + CONTAINER_ELEMENT_VT_MARGIN));
//    else
//        _tokenContainer.frame = CGRectMake(0, -containerHeight + CONTAINER_ELEMENT_VT_MARGIN, tokenContainerWidth, MAX(minContainerHeight, containerHeight + lastToken.bounds.size.height + CONTAINER_ELEMENT_VT_MARGIN));
    _tokenContainer.frame = CGRectMake(0, 0, tokenContainerWidth, MAX(minContainerHeight, MIN(maxContainerHeight, containerHeight + lastToken.bounds.size.height + CONTAINER_PADDING_VT)));
    _tokenContainer.contentSize = CGSizeMake(tokenContainerWidth, MAX(minContainerHeight, containerHeight + lastToken.bounds.size.height + CONTAINER_PADDING_VT));
    CGPoint offset = CGPointMake(0, _tokenContainer.contentSize.height - _tokenContainer.frame.size.height);
    [_tokenContainer setContentOffset:offset animated:YES];

    // layout the backing view
    _backingView.frame = CGRectMake(_tokenContainer.frame.origin.x,
            _tokenContainer.frame.origin.y,
            bounds.size.width,
            _tokenContainer.frame.size.height);

    /* If there's a rightView, place it at the bottom right of the tokenContainer.
     We made sure to provide enough space for it in the logic above, so it should fit just right. */
    _rightView.center = CGPointMake(bounds.size.width - CONTAINER_PADDING / 2.0 - _rightView.bounds.size.width / 2.0,
            CGRectGetMaxY(_tokenContainer.frame) - 5 - _rightView.bounds.size.height / 2.0);

    // the solid line should be 1 pt at the bottom of the token container
    _solidLine.frame = CGRectMake(0,
            CGRectGetMaxY(_tokenContainer.frame) - 1,
            bounds.size.width,
            1);

    // the shadow view always goes below the token container
    _shadowView.frame = CGRectMake(0,
            CGRectGetMaxY(_tokenContainer.frame),
            bounds.size.width,
            4);

    // the table view always goes below the token container and fills up the rest of the view
    CGRect resultsFrame = CGRectMake(0,
            CGRectGetMaxY(_tokenContainer.frame),
            bounds.size.width,
            CGRectGetMaxY(bounds) - CGRectGetMaxY(_tokenContainer.frame));
    _resultsTable.frame = resultsFrame;
    _placeholder.frame = resultsFrame;
}

- (void)userTappedBackspaceOnEmptyField {
    if (!self.enabled)
        return;

    // check if there are any highlighted tokens. If so, delete it and reveal the textfield again
    for (int i = 0; i < [_tokens count]; i++) {
        APTokenView *t = _tokens[i];
        if (t.highlighted) {
            [self removeObject:t.object];
            _textField.hidden = NO;
            return;
        }
    }

    // there was no highlighted token, so highlight the last token in the list
    if ([_tokens count] > 0) // if there are any tokens in the list
    {
        APTokenView *t = [_tokens lastObject];
        t.highlighted = YES;
        _textField.hidden = YES;
        [t setNeedsDisplay];
    }
}

- (void)userTappedTokenContainer {
    if (!self.enabled)
        return;

    if (![self isFirstResponder])
        [self becomeFirstResponder];

    if (_textField.hidden)
        _textField.hidden = NO;

    // if there is a highlighted token, turn it off
    for (APTokenView *t in _tokens) {
        if (t.highlighted) {
            t.highlighted = NO;
            [t setNeedsDisplay];
            break;
        }
    }
}

- (void)userTappedToken:(UITapGestureRecognizer *)gestureRecognizer {
    if (!self.enabled)
        return;

    _textField.enabled = YES;
    APTokenView *token = (APTokenView *) gestureRecognizer.view;

    // if any other token is highlighted, remove the highlight
    for (APTokenView *t in _tokens) {
        if (t.highlighted) {
            t.highlighted = NO;
            [t setNeedsDisplay];
            break;
        }
    }

    // now highlight the tapped token
    token.highlighted = YES;
    [token setNeedsDisplay];

    // make sure the textfield is hidden
    [_textField becomeFirstResponder];
    _textField.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_tokenFieldDataSource respondsToSelector:@selector(tokenField:tableView:cellForIndex:)]) {
        return [_tokenFieldDataSource tokenField:self
                                       tableView:aTableView
                                    cellForIndex:indexPath.row];
    }
    else {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        id object = [_tokenFieldDataSource tokenField:self objectAtResultsIndex:indexPath.row];
        cell.textLabel.text = [_tokenFieldDataSource tokenField:self titleForObject:object];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    numberOfResults = 0;
    if (_tokenFieldDataSource != nil)
        numberOfResults = [_tokenFieldDataSource numberOfResultsInTokenField:self];

    _resultsTable.hidden = (numberOfResults == 0);
    _shadowView.hidden = (numberOfResults == 0);
    _placeholder.hidden = (numberOfResults != 0);
    _solidLine.hidden = (numberOfResults != 0);

    return numberOfResults;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];

    // get the object for that result row
    id object = [_tokenFieldDataSource tokenField:self objectAtResultsIndex:indexPath.row];

    // did select object
    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenField:tableView:didSelectIndex:)]) {
        [_tokenFieldDelegate tokenField:self tableView:aTableView didSelectIndex:indexPath.row];
    } else {
        [self addObject:object];
    }
    [_resultsTable reloadData];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_tokenFieldDataSource respondsToSelector:@selector(resultRowsHeightForTokenField:)])
        return [_tokenFieldDataSource resultRowsHeightForTokenField:self];

    return 44;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!self.enabled)
        return NO;

    if ([aTextField.text isEqualToString:kHiddenCharacter] && [string length] == 0) {
        [self userTappedBackspaceOnEmptyField];
        return NO;
    }

    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenField:shouldChangeCharactersInRange:replacementString:)]) {
        BOOL shouldChange = [_tokenFieldDelegate tokenField:self
                              shouldChangeCharactersInRange:range
                                          replacementString:string];
        if (!shouldChange)
            return NO;
    }

    /* If the textfield is hidden, it means that a token is highlighted. And if the user
     entered a character, then we need to delete that token and begin a new search. */
    if (_textField.hidden) {
        // find the highlighted token, remove it, then make the textfield visible again
        for (int i = 0; i < [_tokens count]; i++) {
            APTokenView *t = _tokens[i];
            if (t.highlighted) {
                [self removeObject:t.object];
                break;
            }
        }
        _textField.hidden = NO;
    }

    NSString *newString = nil;
    BOOL newQuery = NO;
    if ([_textField.text isEqualToString:kHiddenCharacter]) {
        newString = string;
        _textField.text = newString;
        newQuery = YES;
    }
    else
        newString = [_textField.text stringByReplacingCharactersInRange:range withString:string];

    if (_tokenFieldDataSource != nil) {
        [_tokenFieldDataSource tokenField:self searchQuery:newString];
        [_resultsTable reloadData];
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsLayout];
        }];
    }

    if ([newString length] == 0) {
        aTextField.text = kHiddenCharacter;
        return NO;
    }

    if (newQuery)
        return NO;
    else
        return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
        [_tokenFieldDelegate tokenFieldDidBeginEditing:self];
    }

    if ([_textField.text length] == 0)
        _textField.text = kHiddenCharacter;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([_tokens count] >= _tokensLimit) {
        _textField.enabled = NO;
    }
    if ([_tokens count] > 0) {
        for (APTokenView *t in _tokens) {
            t.highlighted = NO;
            [t setNeedsDisplay];
        }
    }
    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenFieldDidEndEditing:)])
        [_tokenFieldDelegate tokenFieldDidEndEditing:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!self.enabled)
        return NO;

    if ([_tokenFieldDelegate respondsToSelector:@selector(tokenFieldDidReturn:)])
        [_tokenFieldDelegate tokenFieldDidReturn:self];

    return YES;
}

#pragma mark - Accessors

- (void)setTokenFieldDataSource:(id <APTokenFieldDataSource>)aTokenFieldDataSource {
    if (_tokenFieldDataSource == aTokenFieldDataSource)
        return;

    _tokenFieldDataSource = aTokenFieldDataSource;
    [_resultsTable reloadData];
}

- (void)setFont:(UIFont *)aFont {
    if (_font == aFont)
        return;

    _font = aFont;

    _textField.font = _font;
}

- (void)setLabelText:(NSString *)someText {
    if ([_labelText isEqualToString:someText])
        return;

    _labelText = someText;

    // remove the current label
    [label removeFromSuperview];
    label = nil;

    // if there is some new text, then create and add a new label
    if ([_labelText length] != 0) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        // the label's font is 15% bigger than the token font
        label.font = [UIFont systemFontOfSize:_font.pointSize * 1.15];
        label.text = _labelText;
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        [_tokenContainer addSubview:label];
    }

    [self setNeedsLayout];
}

- (void)setRightView:(UIView *)aView {
    if (aView == _rightView)
        return;

    [_rightView removeFromSuperview];
    _rightView = nil;

    if (aView) {
        _rightView = aView;
        [self addSubview:_rightView];
    }

    [self setNeedsLayout];
}

- (NSString *)text {
    if ([_textField.text isEqualToString:kHiddenCharacter])
        return @"";

    return _textField.text;
}

@end
