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
#import "KSOThumbnailKitPrivateDefines.h"
#import "KSOThumbnailOperationWrapper.h"
#import "KSOImageThumbnailOperation.h"
#import "KSOMovieThumbnailOperation.h"
#import "KSOPDFThumbnailOperation.h"
#import "KSOTextThumbnailOperation.h"
#import "KSOVimeoThumbnailOperation.h"
#import "KSOYouTubeThumbnailOperation.h"
#if (TARGET_OS_IOS || TARGET_OS_OSX)
#import "KSOWebKitThumbnailOperation.h"
#endif
#if (TARGET_OS_OSX)
#import "KSOQuickLookThumbnailOperation.h"
#endif

#import <Stanley/Stanley.h>
#import <Loki/Loki.h>

#if (TARGET_OS_IPHONE)
#import <MobileCoreServices/MobileCoreServices.h>
#endif

NSString *const KSOThumbnailKitErrorDomain = @"com.kosoku.ksothumbnailkit.error";

NSInteger const KSOThumbnailKitErrorCodeFileCacheRead = 1;
NSInteger const KSOThumbnailKitErrorCodeFileCacheDecode = 2;
NSInteger const KSOThumbnailKitErrorCodeImageRead = 3;
NSInteger const KSOThumbnailKitErrorCodeImageDecode = 4;
NSInteger const KSOThumbnailKitErrorCodeCancelled = 5;
NSInteger const KSOThumbnailKitErrorCodeVideoDecode = 6;
NSInteger const KSOThumbnailKitErrorCodeHTMLLoad = 7;
NSInteger const KSOThumbnailKitErrorCodeRTFDecode = 8;

@interface KSOThumbnailManager () <NSCacheDelegate>
@property (readwrite,copy,nonatomic) NSString *identifier;
@property (copy,nonatomic) NSURL *fileCacheDirectoryURL;
@property (strong,nonatomic) NSOperationQueue *fileCacheQueue;
@property (strong,nonatomic) NSOperationQueue *thumbnailQueue;
@property (strong,nonatomic) NSCache *memoryCache;

- (void)_createFileCacheDirectoryIfNecessary;
- (NSString *)_memoryCacheKeyForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio;
- (NSURL *)_fileCacheURLForMemoryCacheKey:(NSString *)key;
- (NSURL *)_fileCacheURLForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio;
- (Class)_thumbnailOperationClassForURL:(NSURL *)URL;
- (Class)_thumbnailOperationClassForUTI:(NSString *)UTI;

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
    _defaultSize = [self.class _defaultSize];
    _defaultPage = [self.class _defaultPage];
    _defaultTime = [self.class _defaultTime];
    _defaultTimeRatio = [self.class _defaultTimeRatio];
    _completionQueue = [self.class _defaultCompletionQueue];
    
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
    
    [self _createFileCacheDirectoryIfNecessary];
    
    return self;
}

- (void)clearFileCache; {
    if ([NSFileManager.defaultManager removeItemAtURL:self.fileCacheDirectoryURL error:NULL]) {
        [self _createFileCacheDirectoryIfNecessary];
    }
}
- (void)clearMemoryCache; {
    [self.memoryCache removeAllObjects];
}

- (void)cancelAllThumbnailOperations; {
    [self.thumbnailQueue cancelAllOperations];
}

- (id<KSOThumbnailOperation>)thumbnailOperationForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion; {
    NSParameterAssert(URL != nil);
    NSParameterAssert(size.width > 0.0 && size.height > 0);
    NSParameterAssert(page >= 0);
    NSParameterAssert(time >= 0.0);
    NSParameterAssert(timeRatio >= 0.0);
    NSParameterAssert(completion != nil);
    
    if (self.isMemoryCachingEnabled) {
        NSString *key = [self _memoryCacheKeyForURL:URL size:size page:page time:time timeRatio:timeRatio];
        KSOImage *image = [self.memoryCache objectForKey:key];
        
        if (image != nil) {
            [self.completionQueue addOperationWithBlock:^{
                completion(self,image,nil,KSOThumbnailManagerCacheTypeMemory,URL,size,page,time,timeRatio);
            }];
            return nil;
        }
    }
    
    if (self.isFileCachingEnabled) {
        NSURL *fileURL = [self _fileCacheURLForURL:URL size:size page:page time:time timeRatio:timeRatio];
        
        if ([fileURL checkResourceIsReachableAndReturnError:NULL]) {
            [self.fileCacheQueue addOperationWithBlock:^{
                NSError *outError;
                NSData *data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&outError];
                
                if (data == nil) {
                    NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeFileCacheRead userInfo:@{NSUnderlyingErrorKey: outError}];
                    
                    [self.completionQueue addOperationWithBlock:^{
                        completion(self,nil,error,KSOThumbnailManagerCacheTypeNone,URL,size,page,time,timeRatio);
                    }];
                }
                else {
                    KSOImage *image = KSOImageFromData(data);
                    
                    if (image == nil) {
                        NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeFileCacheDecode userInfo:nil];
                        
                        [self.completionQueue addOperationWithBlock:^{
                            completion(self,nil,error,KSOThumbnailManagerCacheTypeNone,URL,size,page,time,timeRatio);
                        }];
                    }
                    else {
                        if (self.isMemoryCachingEnabled) {
                            NSUInteger cost = image.size.width * image.size.height;
                            
#if (TARGET_OS_IPHONE)
                            cost *= image.scale;
#endif
                            
                            [self.memoryCache setObject:image forKey:[self _memoryCacheKeyForURL:URL size:size page:page time:time timeRatio:timeRatio] cost:cost];
                        }
                        
                        [self.completionQueue addOperationWithBlock:^{
                            completion(self,image,nil,KSOThumbnailManagerCacheTypeFile,URL,size,page,time,timeRatio);
                        }];
                    }
                }
            }];
            return nil;
        }
    }
    
    Class thumbnailOperationClass = [self _thumbnailOperationClassForURL:URL];
    
    if (thumbnailOperationClass == Nil) {
        return nil;
    }
    else {
        KSOThumbnailOperationWrapper *retval = [[KSOThumbnailOperationWrapper alloc] init];
        
        void(^completionWithCacheBlock)(KSOThumbnailManager *, KSOImage *, NSError *, KSOThumbnailManagerCacheType, NSURL *, KSOSize, NSUInteger, NSTimeInterval, CGFloat) = ^(KSOThumbnailManager *manager, KSOImage *image, NSError *error, KSOThumbnailManagerCacheType cacheType, NSURL *URL, KSOSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
            if (self.isMemoryCachingEnabled &&
                image != nil) {
                NSUInteger cost = image.size.width * image.size.height;
                
#if (TARGET_OS_IPHONE)
                cost *= image.scale;
#endif
                
                [self.memoryCache setObject:image forKey:[self _memoryCacheKeyForURL:URL size:size page:page time:time timeRatio:timeRatio] cost:cost];
            }
            
            if (self.isFileCachingEnabled &&
                image != nil) {
                
                [self.fileCacheQueue addOperationWithBlock:^{
                    NSData *data;
                    
#if (TARGET_OS_IPHONE)
                    data = [image KLO_hasAlpha] ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1.0);
#else
                    data = [image TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:0.0];
#endif
                    
                    NSError *outError;
                    if (![data writeToURL:[self _fileCacheURLForURL:URL size:size page:page time:time timeRatio:timeRatio] options:NSDataWritingAtomic error:&outError]) {
                        KSTLogObject(outError);
                    }
                }];
            }
            
            [self.completionQueue addOperationWithBlock:^{
                completion(self,image,nil,cacheType,URL,size,page,time,timeRatio);
            }];
        };
        
        KSOBaseThumbnailOperation *thumbnailOperation = [[thumbnailOperationClass alloc] initWithManager:self URL:URL size:size page:page time:time timeRatio:timeRatio completion:completionWithCacheBlock];
        
        [retval setThumbnailOperation:thumbnailOperation];
        
        [thumbnailOperation.privateQueue ?: self.thumbnailQueue addOperation:thumbnailOperation];
        
        return retval;
    }
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
- (void)_createFileCacheDirectoryIfNecessary; {
    _fileCacheDirectoryURL = [[NSFileManager.defaultManager.KST_cachesDirectoryURL URLByAppendingPathComponent:self.identifier isDirectory:YES] URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    KSTLogObject(_fileCacheDirectoryURL.path);
    if (![_fileCacheDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:_fileCacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError]) {
            KSTLogObject(outError);
        }
    }
}
- (NSString *)_memoryCacheKeyForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio; {
    NSString *sizeString;
    
#if (TARGET_OS_IPHONE)
    sizeString = NSStringFromCGSize(size);
#else
    sizeString = NSStringFromSize(size);
#endif
    
    return [NSString stringWithFormat:@"%@.size%@.page%@.time%@.timeRatio%@",[URL.absoluteString KST_MD5String],sizeString,@(page),@(time),@(timeRatio)];
}
- (NSURL *)_fileCacheURLForMemoryCacheKey:(NSString *)key; {
    return [self.fileCacheDirectoryURL URLByAppendingPathComponent:key isDirectory:NO];
}
- (NSURL *)_fileCacheURLForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio; {
    return [self _fileCacheURLForMemoryCacheKey:[self _memoryCacheKeyForURL:URL size:size page:page time:time timeRatio:timeRatio]];
}
- (Class)_thumbnailOperationClassForURL:(NSURL *)URL; {
    if (URL.isFileURL) {
        if (URL.pathExtension.length > 0) {
#if (TARGET_OS_IOS)
            if ([@[@"ppt",@"pptx",@"doc",@"docx",@"xls",@"xlsx",@"csv",@"key",@"pages",@"numbers"] containsObject:URL.pathExtension.lowercaseString]) {
                return [KSOWebKitThumbnailOperation class];
            }
#endif
            
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)URL.pathExtension, NULL);
            
            return [self _thumbnailOperationClassForUTI:UTI];
        }
        else {
            return Nil;
        }
    }
    else if ([URL.host isEqualToString:@"vimeo.com"]) {
        return [KSOVimeoThumbnailOperation class];
    }
    else if ([URL.host isEqualToString:@"www.youtube.com"]) {
        return [KSOYouTubeThumbnailOperation class];
    }
    else {
#if (TARGET_OS_IOS || TARGET_OS_OSX)
        return [KSOWebKitThumbnailOperation class];
#else
        return Nil;
#endif
    }
}
- (Class)_thumbnailOperationClassForUTI:(NSString *)UTI; {
    if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeImage)) {
        return [KSOImageThumbnailOperation class];
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeMovie)) {
        return [KSOMovieThumbnailOperation class];
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypePDF)) {
        return [KSOPDFThumbnailOperation class];
    }
#if (TARGET_OS_IOS || TARGET_OS_OSX)
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeHTML)) {
        return [KSOWebKitThumbnailOperation class];
    }
#endif
    else if (UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeRTF) ||
             UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypeRTFD) ||
             UTTypeConformsTo((__bridge CFStringRef)UTI, kUTTypePlainText)) {
        return [KSOTextThumbnailOperation class];
    }
    else {
#if (TARGET_OS_OSX)
        return [KSOQuickLookThumbnailOperation class];
#else
        return Nil;
#endif
    }
}

+ (KSOSize)_defaultSize; {
    return CGSizeMake(150, 150);
}
+ (NSUInteger)_defaultPage; {
    return 0;
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
