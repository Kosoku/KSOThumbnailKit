//
//  KSOVideoThumbnailOperation.m
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

#import "KSOMovieThumbnailOperation.h"

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
                
                self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
                
                [self setExecuting:NO];
                [self setFinished:YES];
            }
            else {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                
                image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
                
                self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, CMTimeGetSeconds(actualTime), self.timeRatio);
                
                [self setExecuting:NO];
                [self setFinished:YES];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeVideoDecode userInfo:@{NSUnderlyingErrorKey: outError}];
            
            self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
            
            [self setExecuting:NO];
            [self setFinished:YES];
        }
    }];
}

@end
