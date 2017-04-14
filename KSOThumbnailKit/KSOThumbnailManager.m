//
//  KSOThumbnailManager.m
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

#import "KSOThumbnailManager.h"

@interface KSOThumbnailManager ()
+ (KSOSize)_defaultSize;
+ (NSUInteger)_defaultPage;
+ (NSTimeInterval)_defaultTime;
+ (CGFloat)_defaultTimeRatio;
@end

@implementation KSOThumbnailManager
#pragma mark *** Subclass Overrides ***
- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _cacheOptions = KSOThumbnailManagerCacheOptionsAll;
    
    return self;
}
#pragma mark *** Public Methods ***
#pragma mark Properties
+ (KSOThumbnailManager *)sharedManager {
    static KSOThumbnailManager *kRetval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRetval = [[KSOThumbnailManager alloc] init];
    });
    return kRetval;
}

- (BOOL)isFileCachingEnabled {
    return self.cacheOptions & KSOThumbnailManagerCacheOptionsFile;
}
- (BOOL)isMemoryCachingEnabled {
    return self.cacheOptions & KSOThumbnailManagerCacheOptionsMemory;
}

- (void)setDefaultSize:(KSOSize)defaultSize {
    _defaultSize = CGSizeEqualToSize(defaultSize, CGSizeZero) ? [self.class _defaultSize] : defaultSize;
}
- (void)setDefaultPage:(NSUInteger)defaultPage {
    _defaultPage = defaultPage == 0 ? [self.class _defaultPage] : defaultPage;
}
- (void)setDefaultTime:(NSTimeInterval)defaultTime {
    _defaultTime = defaultTime < 0.0 ? [self.class _defaultTime] : defaultTime;
}
- (void)setDefaultTimeRatio:(CGFloat)defaultTimeRatio {
    _defaultTimeRatio = defaultTimeRatio <= 0.0 ? [self.class _defaultTimeRatio] : defaultTimeRatio;
}
#pragma mark *** Private Methods ***
+ (KSOSize)_defaultSize; {
    return CGSizeMake(175, 175);
}
+ (NSUInteger)_defaultPage; {
    return 1;
}
+ (NSTimeInterval)_defaultTime; {
    return 1.0;
}
+ (CGFloat)_defaultTimeRatio {
    return 0.25;
}

@end
