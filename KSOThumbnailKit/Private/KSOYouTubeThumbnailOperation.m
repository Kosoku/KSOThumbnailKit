//
//  KSOYouTubeThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/15/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOYouTubeThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"
#import "KSOThumbnailManager.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

@interface KSOYouTubeThumbnailOperation ()
@property (strong,nonatomic) NSURLSessionDataTask *task;
@end

@implementation KSOYouTubeThumbnailOperation

- (void)main {
    [super main];
    
    NSString *URLString = self.URL.absoluteString;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"v=([A-Za-z0-9]+)" options:0 error:NULL];
    NSTextCheckingResult *result = [regex firstMatchInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    
    if (result == nil) {
        self.completion(self.manager, nil, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }
    else {
        NSString *videoID = [URLString substringWithRange:[result rangeAtIndex:1]];
        NSURL *requestURL = [NSURL KST_URLWithBaseString:@"https://www.googleapis.com/youtube/v3/videos" parameters:@{@"part": @"snippet", @"id": videoID, @"key": self.manager.youTubeAPIKey}];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data != nil &&
                [(NSHTTPURLResponse *)response statusCode] == 200) {
                
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                
                if ([JSON[@"items"] count] > 0 &&
                    [JSON[@"items"][0][@"snippet"][@"thumbnails"] count] > 0) {
                    
                    NSDictionary *thumbnailsDict = JSON[@"items"][0][@"snippet"][@"thumbnails"];
                    __block NSDictionary *thumbnailDict = nil;
                    
                    [thumbnailsDict enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *dict, BOOL *stop) {
                        if ([dict[@"width"] floatValue] > [thumbnailDict[@"width"] floatValue] ||
                            [dict[@"height"] floatValue] > [thumbnailDict[@"height"] floatValue]) {
                            
                            thumbnailDict = dict;
                        }
                    }];
                    
                    NSURL *thumbnailRequestURL = [NSURL URLWithString:thumbnailDict[@"url"]];
                    NSURLSessionDataTask *thumbnailTask = [[NSURLSession sharedSession] dataTaskWithURL:thumbnailRequestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (data != nil) {
                            KSOImage *image = KSOImageFromData(data);
                            
                            image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
                            
                            self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                            
                            [self setExecuting:NO];
                            [self setFinished:YES];
                        }
                        else {
                            self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                            
                            [self setExecuting:NO];
                            [self setFinished:YES];
                        }
                    }];
                    
                    [self setTask:thumbnailTask];
                    [self.task resume];
                }
                else {
                    self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                    
                    [self setExecuting:NO];
                    [self setFinished:YES];
                }
            }
            else {
                self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                
                [self setExecuting:NO];
                [self setFinished:YES];
            }
        }];
        
        [self setTask:task];
        [self.task resume];
    }
}

- (void)cancel {
    [super cancel];
    
    [self.task cancel];
}

@end
