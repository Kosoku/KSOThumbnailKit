//
//  KSOBaseThumbnailOperation.m
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

#import "KSOBaseThumbnailOperation.h"
#import "KSOThumbnailManager.h"

#import <Stanley/Stanley.h>

@interface KSOBaseThumbnailOperation ()
@property (readwrite,weak,nonatomic) KSOThumbnailManager *manager;
@property (readwrite,copy,nonatomic) NSURL *URL;
@property (readwrite,assign,nonatomic) KSOSize size;
@property (readwrite,assign,nonatomic) NSUInteger page;
@property (readwrite,assign,nonatomic) NSTimeInterval time;
@property (readwrite,assign,nonatomic) CGFloat timeRatio;
@property (readwrite,copy,nonatomic,nullable) KSOThumbnailManagerDownloadProgressBlock downloadProgress;
@property (readwrite,copy,nonatomic) KSOThumbnailManagerCompletionBlock completion;
@end

@implementation KSOBaseThumbnailOperation

- (void)dealloc {
    KSTLogObject(NSStringFromClass(self.class));
}

- (instancetype)initWithManager:(KSOThumbnailManager *)manager URL:(NSURL *)URL size:(CGSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio downloadProgress:(KSOThumbnailManagerDownloadProgressBlock)downloadProgress completion:(KSOThumbnailManagerCompletionBlock)completion {
    if (!(self = [super init]))
        return nil;
    
    _manager = manager;
    _URL = [URL copy];
    _size = size;
    _page = page;
    _time = time;
    _timeRatio = timeRatio;
    _downloadProgress = [downloadProgress copy];
    _completion = [completion copy];
    
    return self;
}

- (BOOL)checkCancelledAndInvokeCompletion {
    if (self.isCancelled) {
        NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeCancelled userInfo:nil];
        
        self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        
        return YES;
    }
    return NO;
}

@end
