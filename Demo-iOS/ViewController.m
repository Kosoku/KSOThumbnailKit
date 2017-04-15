//
//  ViewController.m
//  Demo-iOS
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

#import "ViewController.h"

#import <KSOThumbnailKit/KSOThumbnailKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong,nonatomic) UIImageView *imageView;
@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_imageView setClipsToBounds:YES];
    [_imageView setBackgroundColor:[UIColor lightGrayColor]];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:_imageView];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _imageView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _imageView}]];
    
    return self;
}

@end

@interface ViewController () <UICollectionViewDataSource>
@property (strong,nonatomic) UICollectionView *collectionView;

@property (copy,nonatomic) NSArray *URLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KSOThumbnailManager.sharedManager setYouTubeAPIKey:[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"APIKeys" withExtension:@"plist"]][@"youTube"]];
    
    NSMutableArray *URLs = [[NSMutableArray alloc] init];
    
    for (NSURL *URL in [NSFileManager.defaultManager enumeratorAtURL:[[NSBundle mainBundle] URLForResource:@"media" withExtension:nil] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil]) {
        [URLs addObject:URL];
    }
    
    for (NSString *URLString in [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"URLs" withExtension:@"plist"]][@"URLs"]) {
        [URLs addObject:[NSURL URLWithString:URLString]];
    }
    
    [self setURLs:URLs];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [layout setItemSize:CGSizeMake(135, 135)];
    [layout setMinimumLineSpacing:1.0];
    [layout setMinimumInteritemSpacing:1.0];
    
    [self setCollectionView:[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout]];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlwaysBounceVertical:YES];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class])];
    [self.collectionView setDataSource:self];
    [self.view addSubview:self.collectionView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.collectionView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.collectionView, @"top": self.topLayoutGuide}]];
}
- (void)viewWillLayoutSubviews {
    [self.collectionView setContentInset:UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.URLs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class]) forIndexPath:indexPath];
    
    [KSOThumbnailManager.sharedManager thumbnailOperationForURL:self.URLs[indexPath.row] size:KSOThumbnailManager.sharedManager.defaultSize page:KSOThumbnailManager.sharedManager.defaultPage time:KSOThumbnailManager.sharedManager.defaultTime timeRatio:KSOThumbnailManager.sharedManager.defaultTimeRatio completion:^(KSOThumbnailManager * _Nonnull thumbnailManager, UIImage * _Nullable image, NSError * _Nullable error, KSOThumbnailManagerCacheType cacheType, NSURL * _Nonnull URL, CGSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
        CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        [cell.imageView setImage:image];
    }];
    
    return cell;
}

@end
