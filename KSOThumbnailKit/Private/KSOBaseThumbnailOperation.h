//
//  KSOBaseThumbnailOperation.h
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

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)checkCancelledAndInvokeCompletion NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
