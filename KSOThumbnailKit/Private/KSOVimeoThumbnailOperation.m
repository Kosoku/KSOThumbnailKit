//
//  KSOVimeoThumbnailOperation.m
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

#import "KSOVimeoThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>

@interface KSOVimeoThumbnailOperation ()
@property (strong,nonatomic) NSURLSessionDataTask *task;
@end

@implementation KSOVimeoThumbnailOperation

- (void)main {
    [super main];
    
    NSArray *pathComps = self.URL.pathComponents;
    
    if ((pathComps.count > 1 &&
         [pathComps.firstObject isEqualToString:@"/"]) ||
        pathComps.count > 0) {
        
        if ([pathComps.firstObject isEqualToString:@"/"]) {
            pathComps = [pathComps subarrayWithRange:NSMakeRange(1, pathComps.count - 1)];
        }
        
        NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://vimeo.com/api/v2/video/%@.json",pathComps.firstObject]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data != nil &&
                [(NSHTTPURLResponse *)response statusCode] == 200) {
                
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                
                if (json.count > 0) {
                    NSDictionary *thumbnailDict = json.firstObject;
                    NSString *thumbnailLink = ({
                        NSString *retval = thumbnailDict[@"thumbnail_small"];
                        
                        if (thumbnailDict[@"thumbnail_large"]) {
                            retval = thumbnailDict[@"thumbnail_large"];
                        }
                        else if (thumbnailDict[@"thumbnail_medium"]) {
                            retval = thumbnailDict[@"thumbnail_medium"];
                        }
                        
                        retval;
                    });
                    NSURL *thumbnailRequestURL = [NSURL URLWithString:thumbnailLink];
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
                    self.asynchronousCompletion(self.manager, nil, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                }
            }
            else {
                self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
            }
        }];
        
        [self setTask:task];
        [self.task resume];
    }
    else {
        self.asynchronousCompletion(self.manager, nil, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
}

- (void)cancel {
    [super cancel];
    
    [self.task cancel];
}

@end
