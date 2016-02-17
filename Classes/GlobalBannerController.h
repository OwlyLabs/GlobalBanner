//
//  NewGlobalBannerController.h
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GlobalBannerControllerDelegate <NSObject>
-(void)didActionShowGlobalBanner;
@end

@interface GlobalBannerController : NSObject
+ (GlobalBannerController*)sharedInstance;
- (NSArray*)loadPlistFlomFile :(NSString*)fileName;
- (NSString *)getBannerDataFileName;
- (NSString *)getBannerCheckFileName;
- (void)showBannerWithoutCheck;
- (void)setEnabledToShow:(BOOL)enabled;
- (void)checkBannerShowWithIdApp:(int)application_id;
@property(assign) __unsafe_unretained id <GlobalBannerControllerDelegate> delegate;
@end
