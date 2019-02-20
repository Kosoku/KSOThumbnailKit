//
//  KSOBaseThumbnailOperation.m
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
@property (readwrite,copy,nonatomic) KSOThumbnailManagerCompletionBlock completion;
@end

@implementation KSOBaseThumbnailOperation

- (void)dealloc {
    KSTLogObject(NSStringFromClass(self.class));
}

- (instancetype)initWithManager:(KSOThumbnailManager *)manager URL:(NSURL *)URL size:(CGSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion {
    if (!(self = [super init]))
        return nil;
    
    _manager = manager;
    _URL = [URL copy];
    _size = size;
    _page = page;
    _time = time;
    _timeRatio = timeRatio;
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

- (NSOperationQueue *)privateQueue {
    return nil;
}

@end
