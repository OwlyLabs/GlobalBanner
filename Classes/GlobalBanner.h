//
//  NewGlobalBanner.h
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface GlobalBanner : UIViewController
- (void)showBannerWithType:(typeLoading)loadingType;
+(GlobalBanner*)sharedInstance;
@end
