//
//  KSOYouTubeThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/15/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"v=([A-Za-z0-9_-]+)" options:0 error:NULL];
    NSTextCheckingResult *result = [regex firstMatchInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    
    if (result == nil) {
        self.asynchronousCompletion(self.manager, nil, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
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
                            
                            self.asynchronousCompletion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                        }
                        else {
                            self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                        }
                    }];
                    
                    [self setTask:thumbnailTask];
                    [self.task resume];
                }
                else {
                    self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                }
            }
            else {
                self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
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
