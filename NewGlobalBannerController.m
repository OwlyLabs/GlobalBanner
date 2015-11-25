//
//  NewGlobalBannerController.m
//  detectives
//
//  Created by Evgen on 17/11/15.
//  Copyright © 2015 OwlyLabs. All rights reserved.
//

#import "NewGlobalBannerController.h"
#import "GlobalBannerTakeImg.h"
#import "NewGlobalBanner.h"
#import "Settings.mm"


@implementation NewGlobalBannerController
static NewGlobalBannerController *instance = nil;
static BOOL debug = YES;
static NSString *plistDataFileName = @"GlobalBannerData";
static NSString *plistCheckFileName = @"CheckGlobalBanner";


GlobalBannerTakeImg *globalBannerTakeImg;
BOOL stopShow;
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

+(NewGlobalBannerController*)sharedInstance{
    if (!instance) {
        instance = [NewGlobalBannerController new];
    }
    return instance;
}

- (void)checkBannerShow {
    [self getBannerData];
    [self load];
}

- (void)getBannerData {
    arrayBannersCheck = [self loadPlistFlomFile:plistCheckFileName];
    arrayBanners = [self loadPlistFlomFile:plistDataFileName];
}

- (void)load {
    short device = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?1:0;
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/short2/rbanners?date=%@&device=%i&app_id=%i",url_owly,@"0",device,id_current_app_recommended]]];
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

- (void)showBannerWithPeriod :(int)period {
    if (debug == YES) {
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
    if (stopShow == YES) {
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
        [[NewGlobalBanner sharedInstance]showBanner];
    }
}

- (void)addedGlobalBanners:(NSArray*)added_news {
    [self savePlistData:added_news fileName:plistDataFileName];
    [self getBannerData];
}

- (void)finishLoadingGlobalBanner {
    [[NewGlobalBanner sharedInstance]showBanner];
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

- (void)stopShow {
    stopShow = YES;
}


- (NSString*)temp {
    return arrayBanners[0];
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
