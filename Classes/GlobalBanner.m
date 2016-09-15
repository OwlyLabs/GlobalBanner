//
//  GlobalBanner.m
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import "GlobalBanner.h"
#import "iCarousel.h"
#import "PQFCirclesInTriangle.h"
#import "Settings.h"
#import <StoreKit/StoreKit.h>
#import "GlobalBannerController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "PopupLoading.h"


@interface GlobalBanner ()
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) NSMutableArray *arrayBanners;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) PQFCirclesInTriangle *circlesInTriangle;
@property (nonatomic, strong) PopupLoading *popupLoading;
@property (nonatomic, retain) UIColor *circleLoadingColor;
@property typeLoading type_loading;
@property int random;
@end

@implementation GlobalBanner
@synthesize arrayBanners;
@synthesize random;
static GlobalBanner *instance = nil;
static float animationDuration = 0.3;



UIViewController *bgViev;

+(GlobalBanner*)sharedInstance {
    if (!instance) {
        instance = [GlobalBanner new];
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

-(void)setCircleLoaderColor:(UIColor*)circleColor{
    _circleLoadingColor = circleColor;
}

- (BOOL)isNetworkAvailable {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

-(void)getBannersFromDB {
    
    arrayBanners = [NSMutableArray arrayWithArray:[[GlobalBannerController sharedInstance]loadPlistFlomFile:[[GlobalBannerController sharedInstance]getBannerDataFileName]]];
    
    //random = [[SQLiteManager selectOneValueSQL:@"SELECT random_sorting FROM checkGlobalBanner WHERE id = 0"] intValue];
    
    
    
    if ([arrayBanners count] > 0) {
        if ([[GlobalBannerController sharedInstance] isUseDeviceLocalization]) {
            NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lang=%@",lang];
            NSArray *tmp = [arrayBanners filteredArrayUsingPredicate:predicate];
            [arrayBanners removeAllObjects];
            [arrayBanners addObjectsFromArray:tmp];
        }
        
    }
    
    
    random = 0;
    NSArray *dataCheckFile = [[GlobalBannerController sharedInstance] loadPlistFlomFile:[[GlobalBannerController sharedInstance] getBannerCheckFileName]];
    
    if ([dataCheckFile count] > 0) {
        NSDictionary *dicCheckData = dataCheckFile[0];
        if (dicCheckData) {
            if ([dicCheckData objectForKey:@"random_sorting"]) {
                random = [dicCheckData[@"random_sorting"] intValue];
            }
        }
    }
    
    if (random == 1) {
        for (int x = 0; x < [arrayBanners count]; x++) {
            int randInt = (arc4random() % ([arrayBanners count] - x)) + x;
            [arrayBanners exchangeObjectAtIndex:x withObjectAtIndex:randInt];
        }
    }
}

- (void)configView {
    _carousel.type = ([[GlobalBannerController sharedInstance] is_iPad])?iCarouselTypeRotary:iCarouselTypeCoverFlow;
    [self setBackground];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:([[GlobalBannerController sharedInstance] is_iPad])?27:21]];
    
    [self.titleLabel setText:[self localizedStringForKey:@"gBannerRecommendationTitle" withDefault:@"Recommended"]];
    
    [self.closeButton setImage:[UIImage imageNamed:([[GlobalBannerController sharedInstance] is_iPad])?@"closeBanner.png":@"CloseButtonIphone.png"] forState:UIControlStateNormal];
}

- (void)setBackground {
    [self.backgroundView setBackgroundColor:[UIColor clearColor]];
    self.view.backgroundColor = [UIColor clearColor];
    
    if ([[GlobalBannerController sharedInstance] is_ios8_and_later]) {
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.alpha = 1;
            [self.backgroundView addSubview:blurEffectView];
        } else {
            self.backgroundView.backgroundColor = [UIColor colorWithRed:5 green:5 blue:5 alpha:0.55];
        }
    } else {
        self.backgroundView.backgroundColor = [UIColor colorWithRed:5 green:5 blue:5 alpha:0.55];
    }
}

- (void)showBannerWithType:(typeLoading)loadingType{
    self.type_loading = loadingType;
    [self getBannersFromDB];
    if ([arrayBanners count] == 0) {
        return;
    }
    UIWindow *frontWindow = [[[UIApplication sharedApplication] delegate] window];
    [frontWindow setBackgroundColor:[UIColor clearColor]];
    [self.view setFrame:frontWindow.bounds];
    [self.view setAlpha:0];
    [frontWindow addSubview:self.view];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view setAlpha:1];
    }];
    
    [self hideStatusbar:YES];
}

- (IBAction)close:(id)sender {
    [self hideStatusbar:NO];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view setAlpha:0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)hideStatusbar :(BOOL)status {
    if ([[GlobalBannerController sharedInstance] is_iPone4]) {
        [UIView animateWithDuration:0.1 animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:status];
        }];
    }
}

#pragma mark iCarousel methods

UIImageView *Img;
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    view = [[UIImageView alloc] initWithFrame:([[GlobalBannerController sharedInstance] is_iPad])?CGRectMake(0, 0, 400, 680):CGRectMake(0, 0, 250.0f, 425.0f)];
    
    UIImageView *shadow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:([[GlobalBannerController sharedInstance] is_iPad])?@"shadow_ipad":@"shadow_iphone"]];
    [shadow setFrame:([[GlobalBannerController sharedInstance] is_iPad])?CGRectMake(-62.5, -62.5, 525, 755):CGRectMake(-34, -33.5, 318, 493)];
    [view addSubview:shadow];
    
    if (arrayBanners.count>0) {
        UIImage * imageFromWeb = [self loadImage:[NSString stringWithFormat:@"%@",[[arrayBanners objectAtIndex:index] objectForKey:@"id"]] ofType:@"png" inDirectory:[NSString stringWithFormat:@"%@/Private Documents/images/globBanner",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]]];
        
        [((UIImageView *)view) setImage:imageFromWeb];
        
        view.contentMode = UIViewContentModeScaleAspectFit;
    }
    return view;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [arrayBanners count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: {
            return YES;
        }
        case iCarouselOptionSpacing: {
            if ([[GlobalBannerController sharedInstance] is_iPad]) {
                return value * 0.72f;
            } else {
                return value * 3.12f;
            }
        }
        case iCarouselOptionTilt: {
            return value * 0.4f;
        }
        default: {
            return value;
        }
    }
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    return result;
}

int currentIndex;
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    currentIndex = (int)carousel.currentItemIndex;
}


- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (currentIndex==index) {
        if ([[[arrayBanners objectAtIndex:index] objectForKey:@"transition_app"] length] > 0) {
            if ([self isNetworkAvailable]){
                [self openAppStore:[[arrayBanners objectAtIndex:index] objectForKey:@"transition_app"]];
            }
        } else {
            if ([[[arrayBanners objectAtIndex:index] objectForKey:@"url_link"] length] > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[arrayBanners objectAtIndex:index] objectForKey:@"url_link"]]];
            }
        }
    } else {
    }
}

SKStoreProductViewController *storeProductViewController;
- (void)openAppStore: (NSString *)idApp {
    
    __block bool statusOpen;
    statusOpen = true;
    
    if ([[GlobalBannerController sharedInstance] is_iPad]) {
        bgViev = [[UIViewController alloc]init];
        [bgViev.view setBackgroundColor:[UIColor colorWithRed:5 green:5 blue:5 alpha:0.35]];
        [self.view addSubview:bgViev.view];
        
        if (self.type_loading == triangleCircles) {
            self.circlesInTriangle = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
            [bgViev.view addSubview:self.circlesInTriangle];
            if (_circleLoadingColor) {
                self.circlesInTriangle.loaderColor = _circleLoadingColor;
            }
            self.circlesInTriangle.backgroundColor = [UIColor clearColor];
            self.circlesInTriangle.center = bgViev.view.center;
            [self.circlesInTriangle show];
        }else{
            self.popupLoading = [[PopupLoading alloc] initWithFrame:self.view.bounds];
            self.popupLoading.center = bgViev.view.center;
            [bgViev.view addSubview:self.popupLoading];
        }
        
        
        statusOpen = true;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            statusOpen = false;
            bgViev.view.alpha = 1;
            [UIView animateWithDuration:0.2 animations:^{
                bgViev.view.alpha = 0;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [bgViev removeFromParentViewController];
                [bgViev.view removeFromSuperview];
                
            });
        });
    } else {
        bgViev = [[UIViewController alloc]init];
        [bgViev.view setBackgroundColor:[UIColor colorWithRed:5 green:5 blue:5 alpha:0.35]];
        [self.view addSubview:bgViev.view];
        
        if (self.type_loading == triangleCircles) {
            self.circlesInTriangle = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
            [bgViev.view addSubview:self.circlesInTriangle];
            if (_circleLoadingColor) {
                self.circlesInTriangle.loaderColor = _circleLoadingColor;
            }
            self.circlesInTriangle.backgroundColor = [UIColor clearColor];
            self.circlesInTriangle.center = bgViev.view.center;
            [self.circlesInTriangle show];
        }else{
            self.popupLoading = [[PopupLoading alloc] initWithFrame:self.view.bounds];
            self.popupLoading.center = bgViev.view.center;
            [bgViev.view addSubview:self.popupLoading];
        }
        
        
        statusOpen = true;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            statusOpen = false;
            bgViev.view.alpha = 1;
            [UIView animateWithDuration:0.2 animations:^{
                bgViev.view.alpha = 0;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [bgViev removeFromParentViewController];
                [bgViev.view removeFromSuperview];
                
            });
        });
        
    }
    
    // Initialize Product View Controller
    storeProductViewController = [[SKStoreProductViewController alloc] init];
    
    // Configure View Controller
    [storeProductViewController setDelegate:(id)self];
    
    
    
    
    
    NSDictionary *params;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        params = @{SKStoreProductParameterITunesItemIdentifier:idApp,
                   SKStoreProductParameterAffiliateToken:[[GlobalBannerController sharedInstance] affiliateToken],
                   SKStoreProductParameterCampaignToken:[[GlobalBannerController sharedInstance] campaignToken]};
    }else{
        params = @{SKStoreProductParameterITunesItemIdentifier:idApp};
    }
    
    
    
    
    [storeProductViewController loadProductWithParameters:params completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
            bgViev.view.alpha = 1;
            [UIView animateWithDuration:0.2 animations:^{
                bgViev.view.alpha = 0;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [bgViev removeFromParentViewController];
                [bgViev.view removeFromSuperview];
                
            });
        } else {
            // Present Store Product View Controller
            if (statusOpen) {
                storeProductViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:storeProductViewController animated:NO completion:nil];
                
                bgViev.view.alpha = 1;
                [UIView animateWithDuration:0.2 animations:^{
                    bgViev.view.alpha = 0;
                }];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [bgViev removeFromParentViewController];
                    [bgViev.view removeFromSuperview];
                    
                });
            } else {
                NSLog(@"Close timeout");
            }
        }
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated: NO completion:nil];
}


#pragma mark - localize


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"globBanner" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

#pragma mark -
@end
