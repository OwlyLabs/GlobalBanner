//
//  PopupLoading.m
//  dukan
//
//  Created by iSerg on 3/25/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "PopupLoading.h"
#import "SRActivityIndicatorView.h"
#import "UIColor+HEX.h"


@interface PopupLoading (){
    UIView *alphaView;
}
@end
@implementation PopupLoading
SRActivityIndicatorView *activitiIndicator;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)setBackground {
    [alphaView setBackgroundColor:[UIColor clearColor]];
    if (IOS8_AND_LATER) {
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = alphaView.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.alpha = 1;
            [alphaView addSubview:blurEffectView];
        } else {
            alphaView.backgroundColor = [UIColor colorWithRed:5 green:5 blue:5 alpha:0.55];
        }
    } else {
        alphaView.backgroundColor = [UIColor colorWithRed:5 green:5 blue:5 alpha:0.55];
    }
}


- (void)drawRect:(CGRect)rect{
    if (!alphaView) {
        alphaView = [[UIView alloc] initWithFrame:self.frame];
        alphaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //alphaView.backgroundColor = [UIColor blackColor];
        //alphaView.alpha = alphaViewAlpha;
        [alphaView removeFromSuperview];
    }
    [self setBackground];
    [self addSubview:alphaView];
    
    
    if (!activitiIndicator) {
        activitiIndicator = [[SRActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    }
    
    
    activitiIndicator.delegate = (id)self;
    
    [activitiIndicator setNumberOfCircles:4];
    
    [activitiIndicator setMaxRadius:(IS_IPAD)?6.5:5.0];
    
    [activitiIndicator setInternalSpacing:3];
    
    [activitiIndicator setAnimationDuration:0.7];
    
    [activitiIndicator setInternalSpacing: 0.5];
    
    activitiIndicator.center = self.center;
    
    [self addSubview:activitiIndicator];
    
    [activitiIndicator startAnimating];
    
     
    
}

#pragma mark - MAActivityIndicatorViewDelegate

- (UIColor *)activityIndicatorView:(SRActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index{
    switch ((int)index) {
        case 0:
            return [UIColor colorWithHex:@"#fd6045" alpha:1];
            break;
        case 1:
            return [UIColor colorWithHex:@"#77c966" alpha:1];
            break;
        case 2:
            return [UIColor colorWithHex:@"#fbc84e" alpha:1];
            break;
        case 3:
            return [UIColor colorWithHex:@"#189496" alpha:1];
            break;
        default:
            return [UIColor whiteColor];
            break;
    }
}



@end
