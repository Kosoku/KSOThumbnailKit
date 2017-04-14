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

#import <Stanley/Stanley.h>

@interface KSOThumbnailManager () <NSCacheDelegate>
@property (readwrite,copy,nonatomic) NSString *identifier;
@property (copy,nonatomic) NSURL *fileCacheDirectoryURL;
@property (strong,nonatomic) NSOperationQueue *fileCacheQueue;
@property (strong,nonatomic) NSOperationQueue *thumbnailQueue;
@property (strong,nonatomic) NSCache *memoryCache;

+ (KSOSize)_defaultSize;
+ (NSUInteger)_defaultPage;
+ (NSTimeInterval)_defaultTime;
+ (CGFloat)_defaultTimeRatio;
+ (NSOperationQueue *)_defaultCompletionQueue;
@end

@implementation KSOThumbnailManager
#pragma mark *** Subclass Overrides ***
#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    KSTLog(@"%@ %@",cache,obj);
}
#pragma mark *** Public Methods ***
- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (!(self = [super init]))
        return nil;
    
    _identifier = [identifier copy];
    _cacheOptions = KSOThumbnailManagerCacheOptionsAll;
    _completionQueue = [self.class _defaultCompletionQueue];
    
    _fileCacheDirectoryURL = [[NSFileManager.defaultManager.KST_cachesDirectoryURL URLByAppendingPathComponent:self.identifier isDirectory:YES] URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    
    if (![_fileCacheDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:_fileCacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError]) {
            KSTLogObject(outError);
        }
    }
    
    _fileCacheQueue = [[NSOperationQueue alloc] init];
    [_fileCacheQueue setName:[NSString stringWithFormat:@"queue.file.%@.%p",NSStringFromClass(self.class),self]];
    [_fileCacheQueue setMaxConcurrentOperationCount:1];
    [_fileCacheQueue setQualityOfService:NSQualityOfServiceBackground];
    
    _thumbnailQueue = [[NSOperationQueue alloc] init];
    [_thumbnailQueue setName:[NSString stringWithFormat:@"queue.thumbnail.%@.%p",NSStringFromClass(self.class),self]];
    [_thumbnailQueue setQualityOfService:NSQualityOfServiceUtility];
    
    _memoryCache = [[NSCache alloc] init];
    [_memoryCache setName:[NSString stringWithFormat:@"cache.memory.%@.%p",NSStringFromClass(self.class),self]];
    [_memoryCache setDelegate:self];
    
    return self;
}
#pragma mark Properties
+ (KSOThumbnailManager *)sharedManager {
    static KSOThumbnailManager *kRetval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRetval = [[KSOThumbnailManager alloc] initWithIdentifier:[NSString stringWithFormat:@"%@.%@",[NSBundle mainBundle].KST_bundleIdentifier,NSStringFromClass(self)]];
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

- (void)setCompletionQueue:(NSOperationQueue *)completionQueue {
    _completionQueue = completionQueue ?: [self.class _defaultCompletionQueue];
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
+ (NSOperationQueue *)_defaultCompletionQueue; {
    return NSOperationQueue.mainQueue;
}

@end
