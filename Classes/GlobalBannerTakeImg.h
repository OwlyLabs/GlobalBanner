//
//  GlobalBannerTakeImg.h
//  detectives
//
//  Created by Evgen on 04/12/14.
//  Copyright (c) 2014 OwlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GlobalBannerDelegate <NSObject>
-(void)finishLoadingGlobalBanner;
@end

@interface GlobalBannerTakeImg : NSObject
- (void)loadImagesForBanner;
@property (assign) __unsafe_unretained id <GlobalBannerDelegate, UIGestureRecognizerDelegate> delegate;
@property (nonatomic, retain) NSMutableData *imageData;

@end
