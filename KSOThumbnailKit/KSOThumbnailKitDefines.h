//
//  KSOThumbnailKitDefines.h
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

#ifndef __KSO_THUMBNAIL_KIT_DEFINES__
#define __KSO_THUMBNAIL_KIT_DEFINES__

#import <TargetConditionals.h>
#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#if (TARGET_OS_IPHONE)
#ifndef KSOSize
#define KSOSize CGSize
#endif
#ifndef KSOImage
#define KSOImage UIImage
#endif
#ifndef KSOColor
#define KSOColor UIColor
#endif

#else

#ifndef KSOSize
#define KSOSize NSSize
#endif
#ifndef KSOImage
#define KSOImage NSImage
#endif
#ifndef KSOColor
#define KSOColor NSColor
#endif

#endif

/**
 Error domain for error returned by KSOThumbnailKit classes.
 */
FOUNDATION_EXPORT NSString *const KSOThumbnailKitErrorDomain;

/**
 There was an error reading a thumbnail from the file cache.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeFileCacheRead;
/**
 There was an error decoding a thumbnail from the file cache.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeFileCacheDecode;
/**
 There was an error reading an image from disk.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeImageRead;
/**
 There was an error decoding an image from disk.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeImageDecode;
/**
 The thumbnail operation was cancelled by the client.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeCancelled;
/**
 There was an error decoding a video.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeVideoDecode;
/**
 There was an error loading an HTML page.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeHTMLLoad;
/**
 There was an error decoding RTF content.
 */
FOUNDATION_EXPORT NSInteger const KSOThumbnailKitErrorCodeRTFDecode;

#endif
