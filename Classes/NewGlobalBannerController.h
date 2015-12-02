//
//  NewGlobalBannerController.h
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewGlobalBannerController : NSObject
    + (NewGlobalBannerController*)sharedInstance;
    - (void)checkBannerShow;
    - (void)stopShow;
    - (NSString *)temp;

    - (NSArray*)loadPlistFlomFile :(NSString*)fileName;

    - (NSString *)getBannerDataFileName;
    - (NSString *)getBannerCheckFileName;
    - (void)showBannerWithoutCheck;
@end
