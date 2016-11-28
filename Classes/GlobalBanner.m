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
#import "CCarousel.h"
#import "DGActivityIndicatorView.h"




@interface GlobalBanner (){
    SKStoreProductViewController *storeProductViewController;
}
@property (nonatomic, strong) IBOutlet CCarousel *carousel;
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
static float animationDuration = 0.1;



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
            if ([tmp count] > 0) {
                [arrayBanners addObjectsFromArray:tmp];
            }
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
    //[self setBackground];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"SFUIDisplay-Regular" size:([[GlobalBannerController sharedInstance] is_iPad])?20.0:17.0]];
    
    
    [self.titleLabel setText:[self localizedStringForKey:@"gBannerRecommendationTitle" withDefault:@"Recommended"]];
    
    [self.closeButton setImage:[UIImage imageNamed:@"closeBanner"] forState:UIControlStateNormal];
}

- (void)setBackground {
    [self.backgroundView setBackgroundColor:[UIColor clearColor]];
    self.view.backgroundColor = [UIColor clearColor];
    
    for (UIView *view in [self.backgroundView subviews]) {
        [view removeFromSuperview];
    }
    
    if ([[GlobalBannerController sharedInstance] is_ios8_and_later]) {
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.alpha = 1;
            [self.backgroundView addSubview:blurEffectView];
        } else {
            self.backgroundView.backgroundColor = [UIColor colorWithRed:5/255 green:5/255 blue:5/255 alpha:0.8];
        }
    } else {
        self.backgroundView.backgroundColor = [UIColor colorWithRed:5/255 green:5/255 blue:5/255 alpha:0.8];
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
    
    [self setBackground];
    
    [frontWindow addSubview:self.view];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view setAlpha:1];
        
    }];
    [self.carousel reloadData];
    [self hideStatusbar:YES];
}

- (IBAction)close:(id)sender {
    [self hideStatusbar:NO];
    if ([[GlobalBannerController sharedInstance].delegate respondsToSelector:@selector(didActionCloseGlobalBanner)]) {
        [[GlobalBannerController sharedInstance].delegate didActionCloseGlobalBanner];
    }
    
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


- (UIImage*)imageWithShadow:(UIImage*)initialImage{
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, initialImage.size.width + 100, initialImage.size.height + 100, CGImageGetBitsPerComponent(initialImage.CGImage), 0, colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(0,0), 55, [UIColor blackColor].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(50, 50, initialImage.size.width, initialImage.size.height), initialImage.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

#pragma mark iCarousel methods

UIImageView *Img;
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 40, CGRectGetHeight([UIScreen mainScreen].bounds) - 80);
    //CGRectMake(0, 0, 250.0f, 425.0f)
    //view = [[UIImageView alloc] initWithFrame:([[GlobalBannerController sharedInstance] is_iPad])?CGRectMake(0, 0, 400, 680):rect];
    
    view = [[UIImageView alloc] init];
    
    
    if (arrayBanners.count>0) {
        UIImage * imageFromWeb = [self loadImage:[NSString stringWithFormat:@"%@",[[arrayBanners objectAtIndex:index] objectForKey:@"id"]] ofType:@"png" inDirectory:[NSString stringWithFormat:@"%@/Private Documents/images/globBanner",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]]];
        
        
        UIImage *imgShadow = [self imageWithShadow:imageFromWeb];
        
        [((UIImageView *)view) setImage:imgShadow];
        
        CGSize sizeImg = imgShadow.size;
        sizeImg.width = sizeImg.width / [UIScreen mainScreen].scale;
        sizeImg.height = sizeImg.height / [UIScreen mainScreen].scale;
        
        view.contentMode = UIViewContentModeScaleAspectFit;
        rect.size = sizeImg;
        if (rect.size.width > CGRectGetWidth([UIScreen mainScreen].bounds) - 35) {
            rect.size.width = CGRectGetWidth([UIScreen mainScreen].bounds) - 35;
        }
        if (rect.size.height > CGRectGetHeight([UIScreen mainScreen].bounds) - 80) {
            rect.size.height = CGRectGetHeight([UIScreen mainScreen].bounds) - 80;
        }
        view.frame = rect;
        
        
        
        
        //view.contentMode = UIViewContentModeScaleAspectFill;
    }
    //view.backgroundColor = [UIColor redColor];
    return view;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [arrayBanners count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: {
            if ([arrayBanners count] < 3) {
                return NO;
            }else{
                return YES;
            }
        }
        case iCarouselOptionSpacing: {
            if ([arrayBanners count] == 1) {
                return value * 0.1;
            }else{
                if ([[GlobalBannerController sharedInstance] is_iPad]) {
                    return value * 0.72f;
                } else {
                    return value * 2.45f;
                    return value * 3.12f;
                }
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


- (void)openAppStore: (NSString *)idApp {
    [self showiTunesLoading:YES];
    storeProductViewController = [[SKStoreProductViewController alloc] init];
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
            [self showiTunesLoading:NO];
        } else {
            
            // Present Store Product View Controller
            storeProductViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:storeProductViewController animated:NO completion:^{
                if ([[GlobalBannerController sharedInstance].delegate respondsToSelector:@selector(didShowiTunesPopup:)]) {
                    [[GlobalBannerController sharedInstance].delegate didShowiTunesPopup:YES];
                }
            }];
            [self showiTunesLoading:NO];
        }
    }];
}


- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated: NO completion:nil];
    if ([[GlobalBannerController sharedInstance].delegate respondsToSelector:@selector(didShowiTunesPopup:)]) {
        [[GlobalBannerController sharedInstance].delegate didShowiTunesPopup:NO];
    }
}



-(void)showiTunesLoading:(BOOL)show{
    if (show) {
        if (!bgViev) {
            bgViev = [[UIViewController alloc]init];
            [bgViev.view setBackgroundColor:[UIColor clearColor]];
            if (!UIAccessibilityIsReduceTransparencyEnabled()) {
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                blurEffectView.frame = self.view.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.alpha = 1;
                [bgViev.view addSubview:blurEffectView];
            } else {
                bgViev.view.backgroundColor = [UIColor colorWithRed:5/255 green:5/255 blue:5/255 alpha:0.8];
            }
            
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
                if (self.type_loading == horizontalItems) {
                    self.popupLoading = [[PopupLoading alloc] initWithFrame:self.view.bounds];
                    self.popupLoading.center = bgViev.view.center;
                    [bgViev.view addSubview:self.popupLoading];
                }else{
                    if (self.type_loading == dGActivityIndicatorView) {
                        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallRotate tintColor:[UIColor whiteColor] size:33.0f];
                        activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
                        [bgViev.view addSubview:activityIndicatorView];
                        activityIndicatorView.center = bgViev.view.center;
                        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
                        [activityIndicatorView startAnimating];
                    }
                }
            }
        }
        bgViev.view.alpha = 0;
        [bgViev.view removeFromSuperview];
        [self.view addSubview:bgViev.view];
        [UIView animateWithDuration:0.2 animations:^{
            bgViev.view.alpha = 1;
        }];
        
    }else{
        if (bgViev) {
            [UIView animateWithDuration:0.2 animations:^{
                bgViev.view.alpha = 0;
            } completion:^(BOOL finished) {
                [bgViev removeFromParentViewController];
                [bgViev.view removeFromSuperview];
                bgViev = nil;
            }];
        }
    }
}











#pragma mark - localize


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    return [[GlobalBannerController sharedInstance] getLoclizedStringWithKey:key alter:defaultString];
    /*
     static NSBundle *bundle = nil;
     if (bundle == nil)
     {
     NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"globBanner" ofType:@"bundle"];
     bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
     }
     defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
     return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
     */
}

#pragma mark -
@end
