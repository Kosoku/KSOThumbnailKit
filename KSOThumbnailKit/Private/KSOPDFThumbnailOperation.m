//
//  KSOPDFThumbnailOperation.m
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
    
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.URL);
    
    if ([self checkCancelledAndInvokeCompletion]) {
        CGPDFDocumentRelease(documentRef);
        return;
    }
    
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(documentRef);
    size_t pageNumber = KSTBoundedValue(self.page, 1, numberOfPages);
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, pageNumber);
    CGSize pageSize = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox).size;
    KSOImage *image;
    
#if (TARGET_OS_IPHONE)
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    CGContextTranslateCTM(contextRef, 0, pageSize.height);
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextDrawPDFPage(contextRef, pageRef);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
#else
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, pageSize.width, pageSize.height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    CGContextDrawPDFPage(contextRef, pageRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    
    image = KSOImageFromCGImage(imageRef);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
#endif
    
    if ([self checkCancelledAndInvokeCompletion]) {
        CGPDFDocumentRelease(documentRef);
        return;
    }
    
    CGPDFDocumentRelease(documentRef);
    
    image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
    
    self.completion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
}

@end
