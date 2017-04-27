//
//  GlobalBannerController.m
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import "GlobalBannerController.h"
#import "GlobalBannerTakeImg.h"
#import "GlobalBanner.h"
#import "Settings.h"
#import "PopupLoading.h"



@interface GlobalBannerController (){
    NSString *appLanguage;
}
@property typeLoading type_loading;
@property BOOL needHardShow;
@property BOOL useDeviceLocalization;
@property (nonatomic, retain) UIColor *circleLoadingColor;
@end



@implementation GlobalBannerController
static GlobalBannerController *instance = nil;
static BOOL debug = NO;
static NSString *plistDataFileName = @"GlobalBannerData";
static NSString *plistCheckFileName = @"CheckGlobalBanner";
static NSBundle *gBanBundle = nil;

int app_id;
bool enabled_show;


GlobalBannerTakeImg *globalBannerTakeImg;
NSArray *arrayBanners;
NSArray *arrayBannersCheck;
NSArray *arrayFromServer;



NSURLConnection *data_connection;
NSMutableData *data_responce;

- (NSString*)getBannerDataFileName {
    return plistDataFileName;
}

- (NSString*)getBannerCheckFileName {
    return plistCheckFileName;
}

-(void)setRootUrl:(NSString*)url{
    self.root_url = url;
}

-(void)setSKStoreProductParameterAffiliateToken:(NSString*)affiliateToken SKStoreProductParameterCampaignToken:(NSString*)campaignToken{
    self.affiliateToken = affiliateToken;
    self.campaignToken = campaignToken;
}


+(GlobalBannerController*)sharedInstance{
    if (!instance) {
        instance = [GlobalBannerController new];
        [instance setParams];
    }
    return instance;
}

-(void)setParams{
    enabled_show = YES;
    _useDeviceLocalization = YES;
    self.type_loading = horizontalItems;
    self.affiliateToken = @"";
    self.campaignToken = @"";
}

-(void)setUseDeviceLocalization:(BOOL)use{
    _useDeviceLocalization = use;
}
-(BOOL)isUseDeviceLocalization{
    return _useDeviceLocalization;
}

-(void)setCircleLoaderColor:(UIColor*)circleColor{
    _circleLoadingColor = circleColor;
}

-(void)setEnabledToShow:(BOOL)enabled{
    enabled_show = enabled;
}

- (void)checkBannerShowWithIdApp:(int)application_id typeLoading:(typeLoading)tLoading isHardOpen:(BOOL)hard{
    self.needHardShow = hard;
    self.type_loading = tLoading;
    app_id = application_id;
    [self getBannerData];
    [self load];
}

- (void)getBannerData {
    arrayBannersCheck = [self loadPlistFlomFile:plistCheckFileName];
    arrayBanners = [self loadPlistFlomFile:plistDataFileName];
}

-(void)resetShowedDate{
    arrayBannersCheck = [self loadPlistFlomFile:plistCheckFileName];
    if (arrayBannersCheck) {
        if ([arrayBannersCheck count] > 0) {
            [self updateDataInDb:arrayBannersCheck[0]];
        }
    }
}

- (void)load {
    if (!self.root_url) {
        return;
    }
    NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    short device = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?1:0;
    if (CGRectGetWidth([UIScreen mainScreen].bounds) > 370) {
        device = 1;
    }
    
    NSString *params = [NSString stringWithFormat:@"&lang=%@",lang];;
    
    if (appLanguage) {
        if (![appLanguage isEqual:[NSNull null]]) {
            if ([appLanguage length] > 0) {
                params = [NSString stringWithFormat:@"&lang=%@",appLanguage];
            }
        }
    }
    //params = @"";
    //if (_useDeviceLocalization) {
    //}
    
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/short2/rbanners?date=%@&device=%i&app_id=%i%@",self.root_url,@"0",device,app_id,params]]];
    data_connection = [[NSURLConnection alloc] initWithRequest:requst delegate:self];
    data_responce = nil;
    if (!data_responce) {
        data_responce = [NSMutableData new];
    }
    [data_connection start];
}

#pragma marl - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    if ([arrayBannersCheck count]>0) {
        [self showBannerWithPeriod:arrayBannersCheck[0]];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    if (connection == data_connection) {
        [data_responce appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    if (connection == data_connection) {
        [self parseJSON:data_responce];
    }
}

- (void)parseJSON:(NSData*)data {
    NSError* error;
    
    id json = [NSJSONSerialization
               JSONObjectWithData:data
               options:kNilOptions
               error:&error];
    
    NSArray *parentKeys = [json allKeys];
    
    
    if ([self checkKeyNew:@"random_sorting" inArray:parentKeys]) {
        [self updateParamsInCheckFile:@{@"random_sorting":[json objectForKey:@"random_sorting"]}];
    }
    
    if ([self checkKeyNew:@"added" inArray:parentKeys]) {
        arrayFromServer = nil;
        //arrayFromServer = [json objectForKey:@"added"];
        
        NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        
        NSArray *tmp_array = [json objectForKey:@"added"];
        if ([tmp_array count] > 0) {
            NSMutableArray *tmp = [NSMutableArray new];
            for (int i = 0; i < [tmp_array count]; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic addEntriesFromDictionary:tmp_array[i]];
                [dic setObject:lang forKey:@"lang"];
                [tmp addObject:dic];
            }
            arrayFromServer = [tmp mutableCopy];
        }
        [self showBannerWithPeriod:json];
    } else {
        if ([arrayBannersCheck count] > 0) {
            [self showBannerWithPeriod:arrayBannersCheck[0]];
        }
    }
}

- (BOOL)checkKeyNew:(NSString*)key inArray:(NSArray*)array{
    BOOL isset = NO;
    for (int i = 0; i < [array count]; i++) {
        if ([[array objectAtIndex:i] isEqualToString:key]) {
            return YES;
        }
    }
    return isset;
}

- (void)showBannerWithoutCheck {
    [self showBannerWithPeriod:0];
}

- (void)showBannerWithPeriod:(NSDictionary*)data {
    int period = [data[@"period"] intValue];
    
    if (debug || self.needHardShow) {
        period = 0;
    }
    if (period == 0) { // period equal 0 - always show
        [self loadBanners:period];
    } else {
        if ([arrayBannersCheck count] == 0) { // first load, period not equal 0 - didn't show
            [self updateDataInDb:data];
        } else {
            if ([self countDaysFromLastShow]>=period) { // time to show banner
                [self loadBanners:period];
            } else { // to early for show
                if (debug) { // just for debug
                    [self loadBanners:period];
                }
            }
        }
    }
}

- (float)countDaysFromLastShow {
    return (([[NSDate date] timeIntervalSince1970]-[[[arrayBannersCheck objectAtIndex:0] objectForKey:@"date"]floatValue])/(60*60*24));
}

- (void)loadBanners :(int)period {
    if (!enabled_show) {
        return;
    }
    
    [self updateParamsInCheckFile:@{@"period":@(period)}];
    
    if ([arrayFromServer count] > 0) {
        [self addedGlobalBanners:arrayFromServer];
        if (!globalBannerTakeImg) {
            globalBannerTakeImg = [GlobalBannerTakeImg new];
        }
        globalBannerTakeImg.delegate = (id)self;
        [globalBannerTakeImg loadImagesForBanner];
    } else {
        if (_circleLoadingColor) {
            [[GlobalBanner sharedInstance] setCircleLoaderColor:_circleLoadingColor];
        }
        [[GlobalBanner sharedInstance] showBannerWithType:self.type_loading];
        //[self shareActionDidShowGlobalBaner];
    }
}

- (void)addedGlobalBanners:(NSArray*)added_news {
    [self savePlistData:added_news fileName:plistDataFileName];
    [self getBannerData];
}

- (void)finishLoadingGlobalBanner {
    if (_circleLoadingColor) {
        [[GlobalBanner sharedInstance] setCircleLoaderColor:_circleLoadingColor];
    }
    [[GlobalBanner sharedInstance] showBannerWithType:self.type_loading];
    [self shareActionDidShowGlobalBaner];
}


-(void)shareActionDidShowGlobalBaner{
    if ([self.delegate respondsToSelector:@selector(didActionShowGlobalBanner)]) {
        [self.delegate didActionShowGlobalBanner];
    }
}


- (void)updateDataInDb:(NSDictionary*)data{
    long time =  [[NSDate date] timeIntervalSince1970];
    NSMutableArray *tmp = [NSMutableArray new];
    NSMutableDictionary *tmp_1 = [NSMutableDictionary new];
    
    int period = 0;
    if (data[@"period"]) {
        period = [data[@"period"] intValue];
    }
    int random_sorting = 0;
    if (data[@"random_sorting"]) {
        random_sorting = data[@"random_sorting"];
    }
    [tmp_1 setValue:@(period) forKey:@"period"];
    [tmp_1 setValue:@(time) forKey:@"date"];
    [tmp_1 setValue:@(random_sorting) forKey:@"random_sorting"];
    
    [tmp addObject:tmp_1];
    [self savePlistData:tmp fileName:plistCheckFileName];
}


/*- (void)updatePeriodInDb:(int)period{
 NSArray *curData = [self loadPlistFlomFile:plistCheckFileName];
 if (curData) {
 if ([curData count] > 0) {
 NSDictionary *curDic = curData[0];
 NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:curDic];
 [dic setObject:@(period) forKey:@"period"];
 [self savePlistData:@[dic] fileName:plistCheckFileName];
 return;
 }
 }
 long time =  [[NSDate date] timeIntervalSince1970];
 NSDictionary *data = @{@"period":@(period),@"date":@(time),@"random_sorting":@"0"};
 [self savePlistData:@[data] fileName:plistCheckFileName];
 }*/


- (void)updateParamsInCheckFile:(NSDictionary*)params{
    NSArray *curData = [self loadPlistFlomFile:plistCheckFileName];
    if (curData) {
        if ([curData count] > 0) {
            NSDictionary *curDic = curData[0];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:curDic];
            for (NSString* key in [params allKeys]) {
                [dic setObject:params[key] forKey:key];
            }
            [self savePlistData:@[dic] fileName:plistCheckFileName];
            return;
        }
    }
    
    long time =  [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@"0" forKey:@"period"];
    [dic setObject:@(time) forKey:@"date"];
    [dic setObject:@"0" forKey:@"random_sorting"];
    for (NSString* key in [params allKeys]) {
        [dic setObject:params[key] forKey:key];
    }
    [self savePlistData:@[dic] fileName:plistCheckFileName];
}













- (NSString*)pathToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (IBAction)savePlistData:(NSArray*)data fileName:(NSString*)fileName{
    NSString *plistPath = [[self pathToFile] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    [data writeToFile:plistPath atomically: YES];
}

- (NSArray*)loadPlistFlomFile :(NSString*)fileName {
    
    NSString *plistPath = [[self pathToFile] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath: plistPath]) {
        NSLog(@"ERROR");
    }
    
    NSArray *plistData = [NSArray arrayWithContentsOfFile:plistPath];
    
    if (!plistData) {
        NSLog(@"error reading from file: %@", fileName);
        return nil;
    } else {
        return plistData;
    }
}




#pragma mark - Helper


-(BOOL)is_iPad{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

-(BOOL)is_iPone{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

-(BOOL)is_iPone6Plus{
    return ([self is_iPone] && ([[UIScreen mainScreen] bounds].size.height == 736.0f || [[UIScreen mainScreen] bounds].size.height == 414.0f));
}

-(BOOL)is_iPone6{
    return ([self is_iPone] && ([[UIScreen mainScreen] bounds].size.height == 667.0f || [[UIScreen mainScreen] bounds].size.height == 375.0f));
}

-(BOOL)is_iPone5{
    return ([self is_iPone] && ([[UIScreen mainScreen] bounds].size.height == 568.0f || [[UIScreen mainScreen] bounds].size.width == 568.0f));
}

-(BOOL)is_iPone4{
    return ([self is_iPone] && [[UIScreen mainScreen] bounds].size.height == 480.0f);
}

-(BOOL)is_ios8_and_later{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
}



#pragma mark - localization

-(void)setLanguage:(NSString *)l
{
    appLanguage = l;
    NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" inDirectory:@"globBanner.bundle"];
    gBanBundle = (!path)?[NSBundle mainBundle]:[NSBundle bundleWithPath:path];
}

-(NSString *)getLoclizedStringWithKey:(NSString *)key alter:(NSString *)alternate{
    if (!gBanBundle) {
        static NSBundle *bundle = nil;
        if (bundle == nil)
        {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"globBanner" ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
        }
        alternate = [bundle localizedStringForKey:key value:alternate table:nil];
        return [[NSBundle mainBundle] localizedStringForKey:key value:alternate table:nil];
    }
    /*static NSBundle *bundle = nil;
     if (bundle == nil)
     {
     NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"iRateCat" ofType:@"bundle"];
     bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
     }
     defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
     return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];*/
    return [gBanBundle localizedStringForKey:key value:alternate table:nil];
}


#pragma mark -

@end
