//
//  KSORTFThumbnailOperation.m
//  KSOThumbnailKit
//
//  Created by William Towe on 4/15/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
