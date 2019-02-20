//
//  KSOConcurrentThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/14/17.
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

#import "KSOAsynchronousThumbnailOperation.h"

#import <Stanley/Stanley.h>

@interface KSOAsynchronousThumbnailOperation ()
@property (readwrite,copy,nonatomic) KSOThumbnailManagerCompletionBlock asynchronousCompletion;
@end

@implementation KSOAsynchronousThumbnailOperation

- (void)start {
    if ([self checkCancelledAndInvokeCompletion]) {
        return;
    }
    
    [self main];
}
- (void)main {
    [self setExecuting:YES];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (instancetype)initWithManager:(KSOThumbnailManager *)manager URL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion {
    if (!(self = [super initWithManager:manager URL:URL size:size page:page time:time timeRatio:timeRatio completion:completion]))
        return nil;
    
    kstWeakify(self);
    [self setAsynchronousCompletion:^(KSOThumbnailManager *manager, KSOImage *image, NSError *error, KSOThumbnailManagerCacheType cacheType, NSURL *URL, KSOSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
        kstStrongify(self);
        self.completion(manager, image, error, cacheType, URL, size, page, time, timeRatio);
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }];
    
    return self;
}

- (BOOL)checkCancelledAndInvokeCompletion {
    BOOL retval = [super checkCancelledAndInvokeCompletion];
    
    if (retval) {
        [self setExecuting:NO];
        [self setFinished:YES];
    }
    
    return retval;
}

@synthesize executing=_executing;
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@kstKeypath(self,isExecuting)];
    
    _executing = executing;
    
    [self didChangeValueForKey:@kstKeypath(self,isExecuting)];
}

@synthesize finished=_finished;
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@kstKeypath(self,isFinished)];
    
    _finished = finished;
    
    [self didChangeValueForKey:@kstKeypath(self,isFinished)];
}

@end
