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



@interface GlobalBannerController ()
@property typeLoading type_loading;
@property BOOL needHardShow;
@end



@implementation GlobalBannerController
static GlobalBannerController *instance = nil;
static BOOL debug = NO;
static NSString *plistDataFileName = @"GlobalBannerData";
static NSString *plistCheckFileName = @"CheckGlobalBanner";

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

+(GlobalBannerController*)sharedInstance{
    if (!instance) {
        instance = [GlobalBannerController new];
        [instance setParams];
    }
    return instance;
}

-(void)setParams{
    enabled_show = YES;
    self.type_loading = horizontalItems;
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

- (void)load {
    short device = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?1:0;
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/short2/rbanners?date=%@&device=%i&app_id=%i",url_owly,@"0",device,app_id]]];
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
        [self showBannerWithPeriod:[arrayBannersCheck[0][@"period"]intValue]];
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
    
    if ([self checkKeyNew:@"added" inArray:parentKeys]) {
        arrayFromServer = nil;
        arrayFromServer = [json objectForKey:@"added"];
        [self showBannerWithPeriod:[[json objectForKey:@"period"]intValue]];
    } else {
        if ([arrayBannersCheck count] > 0) {
            [self showBannerWithPeriod:[arrayBannersCheck[0][@"period"]intValue]];
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

- (void)showBannerWithPeriod :(int)period {
    if (debug || self.needHardShow) {
        period = 0;
    }
    if (period == 0) { // period equal 0 - always show
        [self loadBanners:period];
    } else {
        if ([arrayBannersCheck count] == 0) { // first load, period not equal 0 - didn't show
            [self updateDataInDb:period];
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
    
    [self updateDataInDb:period];
    if ([arrayFromServer count] > 0) {
        [self addedGlobalBanners:arrayFromServer];
        if (!globalBannerTakeImg) {
            globalBannerTakeImg = [GlobalBannerTakeImg new];
        }
        globalBannerTakeImg.delegate = (id)self;
        [globalBannerTakeImg loadImagesForBanner];
    } else {
        [[GlobalBanner sharedInstance] showBannerWithType:self.type_loading];
        [self shareActionDidShowGlobalBaner];
    }
}

- (void)addedGlobalBanners:(NSArray*)added_news {
    [self savePlistData:added_news fileName:plistDataFileName];
    [self getBannerData];
}

- (void)finishLoadingGlobalBanner {
    [[GlobalBanner sharedInstance] showBannerWithType:self.type_loading];
    [self shareActionDidShowGlobalBaner];
}


-(void)shareActionDidShowGlobalBaner{
    if ([self.delegate respondsToSelector:@selector(didActionShowGlobalBanner)]) {
        [self.delegate didActionShowGlobalBanner];
    }
}

- (void)updateDataInDb :(int)period{
    
    long time =  [[NSDate date] timeIntervalSince1970];
    NSMutableArray *tmp = [NSMutableArray new];
    NSMutableDictionary *tmp_1 = [NSMutableDictionary new];
    [tmp_1 setValue:@(period) forKey:@"period"];
    [tmp_1 setValue:@(time) forKey:@"date"];
    
    [tmp addObject:tmp_1];
    [self savePlistData:tmp fileName:plistCheckFileName];
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

@end
