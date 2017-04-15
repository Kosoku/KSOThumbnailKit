//
//  KSOThumbnailManager.h
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

#import <Foundation/Foundation.h>

#import <KSOThumbnailKit/KSOThumbnailManagerDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSOThumbnailManager : NSObject

@property (class,readonly,nonatomic) KSOThumbnailManager *sharedManager;

@property (readonly,copy,nonatomic) NSString *identifier;

@property (assign,nonatomic) KSOThumbnailManagerCacheOptions cacheOptions;
@property (readonly,nonatomic,getter=isFileCachingEnabled) BOOL fileCachingEnabled;
@property (readonly,nonatomic,getter=isMemoryCachingEnabled) BOOL memoryCachingEnabled;

@property (assign,nonatomic) KSOSize defaultSize;
@property (assign,nonatomic) NSUInteger defaultPage;
@property (assign,nonatomic) NSTimeInterval defaultTime;
@property (assign,nonatomic) CGFloat defaultTimeRatio;

@property (strong,nonatomic,null_resettable) NSOperationQueue *completionQueue;

@property (copy,nonatomic,nullable) NSString *youTubeAPIKey;

- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)clearFileCache;
- (void)clearMemoryCache;

- (void)cancelAllThumbnailOperations;

- (nullable id<KSOThumbnailOperation>)thumbnailOperationForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
