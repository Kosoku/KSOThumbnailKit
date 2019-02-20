//
//  KSOQuickLookThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/15/17.
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

#import "KSOQuickLookThumbnailOperation.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

#import <QuickLook/QuickLook.h>

@implementation KSOQuickLookThumbnailOperation

- (void)main {
    if ([self checkCancelledAndInvokeCompletion]) {
        return;
    }
    
    CGImageRef imageRef = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)self.URL, self.size, NULL);
    
    if (imageRef == NULL) {
        NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:self.URL.path];
        
        image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
        
        self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
    else {
        NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
        
        CGImageRelease(imageRef);
        
        self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
}

@end
