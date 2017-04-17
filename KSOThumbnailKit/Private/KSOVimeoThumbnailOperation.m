//
//  KSOVimeoThumbnailOperation.m
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
