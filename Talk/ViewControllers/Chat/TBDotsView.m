//
//  TBDotsView.m
//  Talk
//
//  Created by Suric on 14/11/2.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBDotsView.h"

@interface DotView : UIView
@property(nonatomic,strong) UIColor *fillColor;
@property(nonatomic,assign) CGFloat diameter;
@end

@implementation DotView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.fillColor = [UIColor blackColor];
        self.diameter = 1;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.fillColor setFill];
    CGContextAddEllipseInRect(context,(CGRectMake (0, 0, self.diameter, self.diameter)));
    CGContextDrawPath(context, kCGPathFill);
    CGContextStrokePath(context);
}

@end

@implementation TBDotsView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dotsColor = [UIColor lightGrayColor];
        [self buildView];
    }
    return self;
}

-(void)buildView
{
    for(UIView *subview in self.subviews)
        {
            [subview removeFromSuperview];
        }
    int numberDots = 3;
    CGFloat  width = (self.bounds.size.width)/numberDots;
    CGFloat dotDiameter = 12;
    CGRect frame = CGRectMake(width+width/7, self.bounds.size.height/2 - dotDiameter/2, dotDiameter, dotDiameter);
        
    for (int i=0; i<numberDots;i++) {
        DotView *dot = [[DotView alloc]initWithFrame:frame];
        dot.diameter = frame.size.width;
        dot.fillColor = self.dotsColor;
        dot.backgroundColor = [UIColor clearColor];
        [self addSubview:dot];
        frame.origin.x += width*2/7;
    }
}

-(void)startAnimating
{
    int i = 0;
    
    for (DotView *dot in self.subviews) {
        dot.transform = CGAffineTransformMakeScale(0.01, 0.01);
        NSTimeInterval delay =  0.1*(double)i;
        
       [UIView animateWithDuration:(double)0.5 delay:delay options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
            dot.transform = CGAffineTransformMakeScale(1,1);
       } completion:nil];
        i++;
    }
}

-(void)stopAnimating
{
     for (DotView *dot in self.subviews)
     {
         dot.transform = CGAffineTransformMakeScale(1, 1);
         [dot.layer removeAllAnimations];
     }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
