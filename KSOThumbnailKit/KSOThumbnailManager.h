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

/**
 KSOThumbnailManager vends thumbnail operations for URLs, both local and remote.
 
 The following UTIs are supported:
 
 - kUTTypeImage (iOS/tvOS/macOS)
 - kUTTypeMovie (iOS/tvOS/macOS)
 - kUTTypePDF (iOS/tvOS/macOS)
 - kUTTypeHTML (iOS/macOS)
 - kUTTypeRTF (iOS/tvOS/macOS)
 - kUTTypeRTFD (iOS/tvOS/macOS)
 - kUTTypePlainText (iOS/tvOS/macOS)
 
 The following file extensions are supported:
 
 - ppt, pptx (iOS/macOS)
 - doc, docx (iOS/macOS)
 - xls, xlsx (iOS/macOS)
 - key (iOS/macOS)
 - pages (iOS/macOS)
 - numbers (iOS/macOS)
 - csv (iOS/macOS)
 
 There is special support for the following URL hosts:
 
 - vimeo.com (iOS/tvOS/macOS)
 - www.youtube.com (iOS/tvOS/macOS)
 
 On macOS, if a something is not natively supported by the framework, it will fall back to the QuickLook framework, which can produce thumbnails for almost any format on the host system.
 
 A shared manager is provided via the sharedManager class property. You can also create your own instances using the initWithIdentifier: designated initializer.
 */
@interface KSOThumbnailManager : NSObject

/**
 Get the shared thumbnail manager.
 */
@property (class,readonly,nonatomic) KSOThumbnailManager *sharedManager;

/**
 Get the identifier that was passed to initWithIdentifier:.
 */
@property (readonly,copy,nonatomic) NSString *identifier;

/**
 Set and get the cache options of the receiver which control where thumbnails are cached after they are created.
 
 The default is KSOThumbnailManagerCacheOptionsAll.
 
 @see KSOThumbnailManagerCacheOptions
 */
@property (assign,nonatomic) KSOThumbnailManagerCacheOptions cacheOptions;
/**
 Get whether file caching is enabled.
 */
@property (readonly,nonatomic,getter=isFileCachingEnabled) BOOL fileCachingEnabled;
/**
 Get whether memory caching is enabled.
 */
@property (readonly,nonatomic,getter=isMemoryCachingEnabled) BOOL memoryCachingEnabled;

/**
 Set and get the default thumbnail size. The size is adjusted based on the screen scale. For example, on a retina display the default of {150,150} would become {300,300}.
 
 The default is {150,150}.
 */
@property (assign,nonatomic) KSOSize defaultSize;
/**
 Set and get the default thumbnail page which is applicable for PDF thumbnails.
 
 The default is 0, which means generate a thumbnail of the first page of the PDF.
 */
@property (assign,nonatomic) NSUInteger defaultPage;
/**
 Set and get the default thumbnail time which is applicable for movie thumbnails.
 
 The default is 1.0, which means generate a thumbnail for 1.0 second into the movie.
 */
@property (assign,nonatomic) NSTimeInterval defaultTime;
/**
 Set and get the default thumbnail time ratio which is applicable for movie thumbnails.
 
 The default is 0.25, which means a generate a thumbnail for 0.25 * movie.duration seconds into the movie. This value is ignored if it is equal to 0.0.
 */
@property (assign,nonatomic) CGFloat defaultTimeRatio;

/**
 Set and get the completion queue where all completion blocks will be invoked.
 
 The default is NSOperationQueue.mainQueue.
 */
@property (strong,nonatomic,null_resettable) NSOperationQueue *completionQueue;

/**
 Set and get the youTube API key. If the key is non-nil it will be used to make youTube thumbnail requests.
 */
@property (copy,nonatomic,nullable) NSString *youTubeAPIKey;

/**
 Create and return an instance of the receiver with the provided *identifier*. The *identifier* controls where thumbnails are cached on disk.
 
 @param identifier The identifier of the thumbnail manager
 @return The initialized instance
 @exception NSException Thrown if identifier is nil
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 Clear the file cache.
 */
- (void)clearFileCache;
/**
 Clear the memory cache.
 */
- (void)clearMemoryCache;

/**
 Cancel all thumbnail operations that are in progress.
 */
- (void)cancelAllThumbnailOperations;

/**
 Calls thumbnailOperationForURL:size:page:time:timeRatio:completion: passing the appropriate values.
 
 @param URL The URL to create a thumbnail from
 @param completion The completion block to invoke when the operation completes
 @return An object that can be used to cancel the thumbnail operation
 @exception NSException Throw if *URL* or *completion* is nil
 */
- (nullable id<KSOThumbnailOperation>)thumbnailOperationForURL:(NSURL *)URL completion:(KSOThumbnailManagerCompletionBlock)completion;
/**
 Calls thumbnailOperationForURL:size:page:time:timeRatio:completion: passing the appropriate values.
 
 @param URL The URL to create a thumbnail from
 @param size The size of the thumbnail
 @param completion The completion block to invoke when the operation completes
 @return An object that can be used to cancel the thumbnail operation
 @exception NSException Throw if *URL* is nil, *size*.width or *size*.height == 0.0, or *completion* is nil
 */
- (nullable id<KSOThumbnailOperation>)thumbnailOperationForURL:(NSURL *)URL size:(KSOSize)size completion:(KSOThumbnailManagerCompletionBlock)completion;
/**
 Create and return a thumbnail operation for the provided *URL*, *size*, *page*, *time*, *timeRatio* and invoke the *completion* block when the operation completes. The *completion* block will always be invoked on queue that has been set as the completionQueue of the receiver. If the thumbnail is fetched from a cache, a thumbnail operation is not returned.
 
 @param URL The URL to create a thumbnail from
 @param size The size of the thumbnail
 @param page The page of the thumbnail, applicable for PDF thumbnails
 @param time The time of the thumbnail, applicable for movie thumbnails
 @param timeRatio The time ratio of the thumbnail, applicable for movie thumbnails
 @param completion The completion block to invoke when the operation completes
 @return An object that can be used to cancel the thumbnail operation
 @exception NSException Throw if *URL* is nil, *size*.width or *size*.height == 0.0, *page* < 0, *time* < 0.0, *timeRatio* < 0.0, or *completion* is nil
 */
- (nullable id<KSOThumbnailOperation>)thumbnailOperationForURL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
