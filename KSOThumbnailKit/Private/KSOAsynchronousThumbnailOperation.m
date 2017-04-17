//
//  KSOConcurrentThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/14/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
