//
//  KSORTFThumbnailOperation.m
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

#import "KSOTextThumbnailOperation.h"
#import "KSOThumbnailKitDefines.h"

#import <Loki/Loki.h>
#import <Ditko/Ditko.h>

@implementation KSOTextThumbnailOperation

- (void)main {
    if ([self checkCancelledAndInvokeCompletion]) {
        return;
    }
    
    NSError *outError;
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    if ([self.URL.pathExtension isEqualToString:@"rtf"]) {
        [options setObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
    }
    else if ([self.URL.pathExtension isEqualToString:@"rtfd"]) {
        [options setObject:NSRTFDTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
    }
    else {
        [options setObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
        [options setObject:@{NSForegroundColorAttributeName: [KSOColor blackColor], NSBackgroundColorAttributeName: [KSOColor whiteColor]} forKey:NSDefaultAttributesDocumentAttribute];
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithURL:self.URL options:options documentAttributes:nil error:&outError];
    
    if (attributedString == nil) {
        NSError *error = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeRTFDecode userInfo:@{NSUnderlyingErrorKey: outError}];
        
        self.completion(self.manager, nil, error, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
    else {
        KSOImage *image;
        
#if (TARGET_OS_IPHONE)
        CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        
        UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
        
        UIColor *backgroundColor = [attributedString attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL] ?: [UIColor whiteColor];
        
        [backgroundColor setFill];
        UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
        
        [attributedString drawWithRect:CGRectMake(0, 0, kSize.width, kSize.height) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
#else
        image = [[NSImage alloc] initWithSize:self.size];
        
        [image lockFocus];
        
        [attributedString drawAtPoint:NSZeroPoint];
        
        [image unlockFocus];
#endif
        
        self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
    }
}

@end
