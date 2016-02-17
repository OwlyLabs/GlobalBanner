//
//  GlobalBannerTakeImg.m
//  detectives
//
//  Created by Evgen on 04/12/14.
//  Copyright (c) 2014 OwlyLabs. All rights reserved.
//

#import "GlobalBannerTakeImg.h"
#import "GlobalBannerController.h"
#import "Settings.h"
#include <sys/xattr.h>

@interface GlobalBannerTakeImg ()
@property (nonatomic ,retain) NSArray *arrayBanners;
@end

@implementation GlobalBannerTakeImg

@synthesize delegate;
@synthesize arrayBanners;
@synthesize imageData;
int index_img;


- (void)loadImagesForBanner {
    NSString*pathFolder = [NSString stringWithFormat:@"%@/Private Documents/images/globBanner/",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]];
    arrayBanners = [NSMutableArray arrayWithArray:[[GlobalBannerController sharedInstance]loadPlistFlomFile:[[GlobalBannerController sharedInstance]getBannerDataFileName]]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = pathFolder;
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
    index_img = 0;
    [self startdownload];
}

- (void) startdownload {
    if ([arrayBanners count]>index_img) {
        [self getImageFromURL:[NSString stringWithFormat:@"%@%@",url_owly,[[arrayBanners objectAtIndex:index_img]objectForKey:(IS_IPAD)?@"url_large_img":@"url_img"]]];
    }
}

- (void)getImageFromURL:(NSString *)fileURL {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:fileURL];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        self.imageData = [NSMutableData data];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *img = [UIImage imageWithData:imageData];
    NSString*pathFolder = [NSString stringWithFormat:@"%@/Private Documents/images/globBanner/",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]];
    [self saveImage:img withFileName:[NSString stringWithFormat:@"%@",[[arrayBanners objectAtIndex:index_img]objectForKey:@"id"]] ofType:@"png" inDirectory:pathFolder];
    
    [[NSFileManager defaultManager] removeItemAtPath: [NSString stringWithFormat:@"%@/.DS_Store",pathFolder] error: nil];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathFolder error:nil];
    
    if ([directoryContents count] == [arrayBanners count]){
        
    } else {
        index_img++;
        [self startdownload];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)createGlobBannerImagesFolder{
    NSString*path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Private Documents/images/globBanner"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL {
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: directoryPath]) {
        [self createGlobBannerImagesFolder];
    }
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath: [NSString stringWithFormat:@"%@/.DS_Store",directoryPath] error: nil];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    
    if ([directoryContents count] == [arrayBanners count]){
        if ([self.delegate respondsToSelector:@selector(finishLoadingGlobalBanner)]) {
            [self.delegate finishLoadingGlobalBanner];
        }
        //[ApplicationDelegate finishLoadingGlobalBanner];
    }
}


@end
