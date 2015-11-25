//
//  NewGlobalBanner.h
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGlobalBanner : UIViewController
    - (void)showBanner;
    +(NewGlobalBanner*)sharedInstance;
@end
