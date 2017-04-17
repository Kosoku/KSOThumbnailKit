//
//  KSOWebKitThumbnailOperation.m
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

#import "KSOWebKitThumbnailOperation.h"
#import "KSOThumbnailKitPrivateDefines.h"

#import <Stanley/Stanley.h>
#import <Loki/Loki.h>
#import <Ditko/Ditko.h>

#import <WebKit/WebKit.h>

@interface KSOWebKitThumbnailOperation () <WKNavigationDelegate>
@property (strong,nonatomic) WKWebView *webView;
@property (strong,nonatomic) WKNavigation *navigation;
#if (TARGET_OS_OSX)
@property (strong,nonatomic) NSWindow *window;
#endif
@end

@implementation KSOWebKitThumbnailOperation

- (void)main {
    [super main];
    
    KSTDispatchMainAsync(^{
        if ([self checkCancelledAndInvokeCompletion]) {
            return;
        }
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        [config setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeAll];
#if (TARGET_OS_IPHONE)
        [config setDataDetectorTypes:WKDataDetectorTypeNone];
        [config setIgnoresViewportScaleLimits:YES];
#endif
        
#if (TARGET_OS_IOS)
        [self setWebView:[[WKWebView alloc] initWithFrame:UIApplication.sharedApplication.keyWindow.bounds configuration:config]];
        [self.webView setUserInteractionEnabled:NO];
        
        [UIApplication.sharedApplication.keyWindow insertSubview:self.webView atIndex:0];
#else
        NSSize windowSize = NSMakeSize(1024, 768);
        
        [self setWindow:[[NSWindow alloc] initWithContentRect:NSMakeRect(-windowSize.width, -windowSize.height, windowSize.width, windowSize.height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreNonretained defer:NO]];
        [self.window setExcludedFromWindowsMenu:YES];
        
        [self setWebView:[[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, windowSize.width, windowSize.height)]];
        
        [self.window setContentView:self.webView];
#endif
        [self.webView setNavigationDelegate:self];
        
        if (self.URL.isFileURL) {
            [self setNavigation:[self.webView loadFileURL:self.URL allowingReadAccessToURL:self.URL]];
        }
        else {
            [self setNavigation:[self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]]];;
        }
    });
}

- (void)cancel {
    [super cancel];
    
    [self.webView stopLoading];
}

- (NSOperationQueue *)privateQueue {
    static NSOperationQueue *kRetval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRetval = [[NSOperationQueue alloc] init];
        
        [kRetval setName:[NSString stringWithFormat:@"%@.queue",NSStringFromClass(self.class)]];
        [kRetval setMaxConcurrentOperationCount:NSProcessInfo.processInfo.activeProcessorCount];
        [kRetval setQualityOfService:NSQualityOfServiceUtility];
    });
    return kRetval;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (![self.navigation isEqual:navigation]) {
        return;
    }
    
#if (TARGET_OS_IPHONE)
    [self.webView removeFromSuperview];
#endif
    
    NSError *wrapError = [NSError errorWithDomain:KSOThumbnailKitErrorDomain code:KSOThumbnailKitErrorCodeHTMLLoad userInfo:@{NSUnderlyingErrorKey: error}];
    
    self.asynchronousCompletion(self.manager, nil, wrapError, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (![self.navigation isEqual:navigation]) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __block KSOImage *image;
        
#if (TARGET_OS_IPHONE)
        UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, YES, 0);
        
        [self.webView drawViewHierarchyInRect:self.webView.bounds afterScreenUpdates:YES];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [self.webView removeFromSuperview];
#else
        NSDisableScreenUpdates();
        
        [self.window orderFront:nil];
        
        CGImageRef imageRef = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, (CGWindowID)self.window.windowNumber, kCGWindowImageBoundsIgnoreFraming);
        
        [self.window orderOut:nil];
        
        NSEnableScreenUpdates();
        
        image = KSOImageFromCGImage(imageRef);
        
        CGImageRelease(imageRef);
#endif
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            image = [image KLO_imageByResizingToSize:KDICGSizeAdjustedForMainScreenScale(self.size)];
            
            self.asynchronousCompletion(self.manager, image, nil, KSOThumbnailManagerCacheTypeNone, self.URL, self.size, self.page, self.time, self.timeRatio);
        });
    });
}

@end
