//
//  NewGlobalBannerController.h
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Settings.h"

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
-(void)setUseDeviceLocalization:(BOOL)use;
-(BOOL)isUseDeviceLocalization;
- (void)checkBannerShowWithIdApp:(int)application_id typeLoading:(typeLoading)tLoading isHardOpen:(BOOL)hard;
@property(assign) __unsafe_unretained id <GlobalBannerControllerDelegate> delegate;
-(void)setCircleLoaderColor:(UIColor*)circleColor;
@property (nonatomic, retain) NSString *root_url;

@property (nonatomic, retain) NSString *affiliateToken;
@property (nonatomic, retain) NSString *campaignToken;

-(void)setRootUrl:(NSString*)url;
-(void)setSKStoreProductParameterAffiliateToken:(NSString*)affiliateToken SKStoreProductParameterCampaignToken:(NSString*)campaignToken;


-(BOOL)is_iPad;
-(BOOL)is_iPone;
-(BOOL)is_iPone6Plus;
-(BOOL)is_iPone6;
-(BOOL)is_iPone5;
-(BOOL)is_iPone4;
-(BOOL)is_ios8_and_later;

-(void)resetShowedDate;
-(NSString *)getLoclizedStringWithKey:(NSString *)key alter:(NSString *)alternate;
-(void)setLanguage:(NSString *)l;
@end
