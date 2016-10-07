//
//  CCarousel.m
//  Pods
//
//  Created by Serg Rudenko on 06/10/16.
//
//

#import "CCarousel.h"

@implementation CCarousel

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [self setParams];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])){
        [self setParams];
    }
    return self;
}

- (void)setParams{
    self.decelerationRate = 0;//(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?0:0;  //0.1;//0.95f;
    self.scrollEnabled = YES;
    self.bounces = NO;
    self.perspective = -1.0f/500.0f;
    self.contentOffset = CGSizeZero;
    self.viewpointOffset = CGSizeZero;
    self.scrollSpeed = 2.0f;
    self.bounceDistance = 1;//(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?10:10.0f;
    self.stopAtItemBoundary = YES;
    self.scrollToItemBoundary = YES;
    self.ignorePerpendicularSwipes = YES;
    self.centerItemWhenSelected = NO;
    self.pagingEnabled = YES;
}







/*
 _decelerationRate = 0.95;
 _scrollEnabled = YES;
 _bounces = YES;
 _offsetMultiplier = 1.0;
 _perspective = -1.0/500.0;
 _contentOffset = CGSizeZero;
 _viewpointOffset = CGSizeZero;
 _scrollSpeed = 1.0;
 _bounceDistance = 1.0;
 _stopAtItemBoundary = YES;
 _scrollToItemBoundary = YES;
 _ignorePerpendicularSwipes = YES;
 _centerItemWhenSelected = YES;
 
 */


/*
 self.decelerationRate = 0.1;//(IS_IPAD)?0:0;  //0.1;//0.95f;
 self.scrollEnabled = YES;
 self.bounces = YES;
 self.perspective = 0;//-1.0f/500.0f;
 self.contentOffset = CGSizeZero;
 self.viewpointOffset = CGSizeZero;
 self.scrollSpeed = 2.5f;
 self.bounceDistance = (IS_IPAD)?10:10.0f;
 self.stopAtItemBoundary = YES;
 self.scrollToItemBoundary = YES;
 self.ignorePerpendicularSwipes = YES;
 self.centerItemWhenSelected = NO;
 self.pagingEnabled = NO;
 
 
 */






/*
 - (void)layOutItemViews
 {
 self.type = iCarouselTypeInvertedWheel;
 }
 */



#pragma mark -
#pragma mark Scrolling

- (NSInteger)clampedIndex:(NSInteger)index
{
    if (self.wrapEnabled)
    {
        return self.numberOfItems? (index - floorf((CGFloat)index / (CGFloat)self.numberOfItems) * self.numberOfItems): 0;
    }
    else
    {
        return MIN(MAX(0, index), MAX(0, self.numberOfItems - 1));
    }
}

- (CGFloat)clampedOffset:(CGFloat)offset
{
    if (self.wrapEnabled)
    {
        return self.numberOfItems? (offset - floorf(offset / (CGFloat)self.numberOfItems) * self.numberOfItems): 0.0f;
    }
    else
    {
        return fminf(fmaxf(0.0f, offset), fmaxf(0.0f, (CGFloat)self.numberOfItems - 1.0f));
    }
}



@end
