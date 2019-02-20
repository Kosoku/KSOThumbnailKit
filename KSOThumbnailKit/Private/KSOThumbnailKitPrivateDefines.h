//
//  KSOThumbnailKitPrivateDefines.h
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

#ifndef __KSO_THUMBNAIL_KIT_PRIVATE_DEFINES__
#define __KSO_THUMBNAIL_KIT_PRIVATE_DEFINES__

#import <TargetConditionals.h>
#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#if (TARGET_OS_IPHONE)
#define KSOImageFromCGImage(theImageRef) ([[UIImage alloc] initWithCGImage:theImageRef])
#define KSOImageFromData(theData) ([[UIImage alloc] initWithData:theData])
#else
#define KSOImageFromCGImage(theImageRef) ([[NSImage alloc] initWithCGImage:theImageRef size:NSZeroSize])
#define KSOImageFromData(theData) ([[NSImage alloc] initWithData:theData])
#endif

#endif
