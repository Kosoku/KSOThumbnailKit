//
//  KSOImageThumbnailOperation.m
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

#import "KSOImageThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>

@implementation KSOImageThumbnailOperation

- (void)main {
    if ([self checkCancelledAndInvokeCompletion]) {
        return;
    }
    
    NSError *outError;
    NSData *data = [NSData dataWithContentsOfURL:self.URL options:NSDataReadingMappedIfSafe error:&outError];
    
    if (data == nil) {
        NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeImageRead userInfo:@{NSUnderlyingErrorKey: outError}];
        
        self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
    else {
        KSOImage *image = KSOImageFromData(data);
        
        if (image == nil) {
            NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeImageDecode userInfo:nil];
            
            self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        }
        else {
            image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
            
            self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        }
    }
}

@end
