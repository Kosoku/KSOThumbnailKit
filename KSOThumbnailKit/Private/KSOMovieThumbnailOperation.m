//
//  KSOVideoThumbnailOperation.m
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

#import "KSOMovieThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

#import <AVFoundation/AVFoundation.h>

@implementation KSOMovieThumbnailOperation

- (void)main {
    [super main];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    
    [asset loadValuesAsynchronouslyForKeys:@[@kstKeypath(asset,duration)] completionHandler:^{
        NSError *outError;
        AVKeyValueStatus status = [asset statusOfValueForKey:@kstKeypath(asset,duration) error:&outError];
        
        if (status == AVKeyValueStatusLoaded) {
            AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
            
            [generator setAppliesPreferredTrackTransform:YES];
            [generator setRequestedTimeToleranceBefore:kCMTimeZero];
            [generator setRequestedTimeToleranceAfter:kCMTimeZero];
            
            NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
            CMTime time = self.timeRatio > 0.0 ? CMTimeMakeWithSeconds(duration * self.timeRatio, NSEC_PER_SEC) : CMTimeMakeWithSeconds(self.time, NSEC_PER_SEC);
            CMTime actualTime;
            NSError *outError;
            CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&outError];
            
            if (imageRef == NULL) {
                NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeVideoDecode userInfo:@{NSUnderlyingErrorKey: outError}];
                
                self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
            }
            else {
                KSOImage *image = KSOImageFromCGImage(imageRef);
                
                image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
                
                self.asynchronousCompletion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeVideoDecode userInfo:@{NSUnderlyingErrorKey: outError}];
            
            self.asynchronousCompletion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        }
    }];
}

@end
