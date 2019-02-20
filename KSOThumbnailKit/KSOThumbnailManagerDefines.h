//
//  KSOThumbnailManagerDefines.h
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

#ifndef __KSO_THUMBNAIL_MANAGER_DEFINES__
#define __KSO_THUMBNAIL_MANAGER_DEFINES__

#import <KSOThumbnailKit/KSOThumbnailKitDefines.h>
#import <KSOThumbnailKit/KSOThumbnailOperation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum describing the possible values for the cache type. A value is returned as part of the KSOThumbnailManagerCompletionBlock.
 */
typedef NS_ENUM(NSInteger, KSOThumbnailManagerCacheType) {
    /**
     The thumbnail was not previously cached and was freshly generated.
     */
    KSOThumbnailManagerCacheTypeNone = 0,
    /**
     The thumbnail was fetched from disk.
     */
    KSOThumbnailManagerCacheTypeFile,
    /**
     The thumbnail was fetched from memory.
     */
    KSOThumbnailManagerCacheTypeMemory
};

/**
 Options mask describing the possible values for cache options. This controls where the thumbnail manager will cache thumbnails after they are created.
 */
typedef NS_OPTIONS(NSUInteger, KSOThumbnailManagerCacheOptions) {
    /**
     Thumbnails will not be cached.
     */
    KSOThumbnailManagerCacheOptionsNone = 0,
    /**
     Thumbnails will only be cached on disk.
     */
    KSOThumbnailManagerCacheOptionsFile = 1 << 0,
    /**
     Thumbnails will only be cached in memory.
     */
    KSOThumbnailManagerCacheOptionsMemory = 1 << 1,
    /**
     Thumbnails will be cached on disk and in memory.
     */
    KSOThumbnailManagerCacheOptionsAll = KSOThumbnailManagerCacheOptionsFile | KSOThumbnailManagerCacheOptionsMemory
};

@class KSOThumbnailManager;

/**
 Block that is invoked when a thumbnail operation completes.
 
 @param thumbnailManager The thumbnail manager that created the thumbnail operation
 @param image The thumbnail image
 @param error If *image* is nil, an error describing the reason for failure
 @param cacheType Where the thumbnail was fetched from
 @param URL The thumbnail URL
 @param size The thumbnail size
 @param page The thumbnail page, applicable for PDF thumbnail images
 @param time The thumbnail time, applicable for movie thumbnail images (e.g. 1.0 means create a thumbnail from 1.0 second into the movie)
 @param timeRatio The thumbnail time ratior, applicable for movie thumbnail images (e.g. 0.25 means create a thumbnail from 0.25 * movie.duration seconds into the movie)
 */
typedef void(^KSOThumbnailManagerCompletionBlock)(KSOThumbnailManager *thumbnailManager, KSOImage * _Nullable image, NSError * _Nullable error, KSOThumbnailManagerCacheType cacheType, NSURL *URL, KSOSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio);

NS_ASSUME_NONNULL_END

#endif
