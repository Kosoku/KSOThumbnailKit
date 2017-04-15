//
//  KSOBaseThumbnailOperation.h
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

@interface KSOBaseThumbnailOperation : NSOperation

@property (readonly,weak,nonatomic) KSOThumbnailManager *manager;
@property (readonly,copy,nonatomic) NSURL *URL;
@property (readonly,assign,nonatomic) KSOSize size;
@property (readonly,assign,nonatomic) NSUInteger page;
@property (readonly,assign,nonatomic) NSTimeInterval time;
@property (readonly,assign,nonatomic) CGFloat timeRatio;
@property (readonly,copy,nonatomic) KSOThumbnailManagerCompletionBlock completion;

@property (readonly,nonatomic,nullable) NSOperationQueue *privateQueue;

- (instancetype)initWithManager:(KSOThumbnailManager *)manager URL:(NSURL *)URL size:(KSOSize)size page:(NSUInteger)page time:(NSTimeInterval)time timeRatio:(CGFloat)timeRatio completion:(KSOThumbnailManagerCompletionBlock)completion NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)checkCancelledAndInvokeCompletion NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
