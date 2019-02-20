//
//  KSOPDFThumbnailOperation.m
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

#import "KSOPDFThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"

#import <Stanley/Stanley.h>
#import <Loki/Loki.h>
#import <Ditko/Ditko.h>

@implementation KSOPDFThumbnailOperation

- (void)main {
    if ([self checkCancelledAndInvokeCompletion]) {
        return;
    }
    
    KSOImage *image = [KSOImage KLO_imageWithPDFAtURL:self.URL size:self.size page:self.page options:KLOPDFOptionsPreserveAspectRatio];
    
    self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
}

@end
