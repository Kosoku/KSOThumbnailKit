//
//  ViewController.m
//  Demo-iOS
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

#import "ViewController.h"

#import <Stanley/Stanley.h>
#import <KSOThumbnailKit/KSOThumbnailKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong,nonatomic) UIImageView *imageView;

@property (copy,nonatomic) NSURL *URL;
@property (strong,nonatomic) id<KSOThumbnailOperation> thumbnailOperation;
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

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.thumbnailOperation cancel];
    [self setThumbnailOperation:nil];
    [self.imageView setImage:nil];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    kstWeakify(self);
    self.thumbnailOperation = [KSOThumbnailManager.sharedManager thumbnailOperationForURL:_URL completion:^(KSOThumbnailManager * _Nonnull thumbnailManager, UIImage * _Nullable image, NSError * _Nullable error, KSOThumbnailManagerCacheType cacheType, NSURL * _Nonnull URL, CGSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
        kstStrongify(self);
        
        NSLog(@"%@ %@",URL,@(cacheType));
        
        [self.imageView setImage:image];
    }];
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
    
    [cell setURL:self.URLs[indexPath.item]];
    
    return cell;
}

@end
