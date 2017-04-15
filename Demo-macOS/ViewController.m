//
//  ViewController.m
//  Demo-macOS
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

#import "ViewController.h"

#import <KSOThumbnailKit/KSOThumbnailKit.h>

@interface CollectionViewItem : NSCollectionViewItem
@property (strong,nonatomic) NSImageView *thumbnailImageView;
@end

@implementation CollectionViewItem

- (void)loadView {
    [self setView:[[NSView alloc] initWithFrame:NSZeroRect]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setThumbnailImageView:[[NSImageView alloc] initWithFrame:NSZeroRect]];
    [self.thumbnailImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.thumbnailImageView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.thumbnailImageView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.thumbnailImageView}]];
}

@end

@interface ViewController () <NSCollectionViewDataSource>
@property (weak,nonatomic) IBOutlet NSCollectionView *collectionView;

@property (copy,nonatomic) NSArray *URLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KSOThumbnailManager.sharedManager setCacheOptions:KSOThumbnailManagerCacheOptionsNone];
    [KSOThumbnailManager.sharedManager setYouTubeAPIKey:[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"APIKeys" withExtension:@"plist"]][@"youTube"]];
    
    NSMutableArray *URLs = [[NSMutableArray alloc] init];
    
    for (NSURL *URL in [NSFileManager.defaultManager enumeratorAtURL:[[NSBundle mainBundle] URLForResource:@"media" withExtension:nil] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil]) {
        [URLs addObject:URL];
    }
    
    for (NSString *URLString in [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"URLs" withExtension:@"plist"]][@"URLs"]) {
        [URLs addObject:[NSURL URLWithString:URLString]];
    }
    
    [self setURLs:URLs];
    
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    
    [layout setSectionInset:NSEdgeInsetsMake(8, 8, 0, 8)];
    [layout setMinimumLineSpacing:8.0];
    [layout setMinimumInteritemSpacing:8.0];
    [layout setItemSize:NSMakeSize(135, 135)];
    
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView registerClass:[CollectionViewItem class] forItemWithIdentifier:NSStringFromClass([CollectionViewItem class])];
    [self.collectionView setDataSource:self];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.URLs.count;
}
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewItem *item = [collectionView makeItemWithIdentifier:NSStringFromClass([CollectionViewItem class]) forIndexPath:indexPath];
    
    [KSOThumbnailManager.sharedManager thumbnailOperationForURL:self.URLs[[indexPath indexAtPosition:1]] size:KSOThumbnailManager.sharedManager.defaultSize page:KSOThumbnailManager.sharedManager.defaultPage time:KSOThumbnailManager.sharedManager.defaultTime timeRatio:KSOThumbnailManager.sharedManager.defaultTimeRatio downloadProgress:nil completion:^(KSOThumbnailManager * _Nonnull thumbnailManager, NSImage * _Nullable image, NSError * _Nullable error, KSOThumbnailManagerCacheType cacheType, NSURL * _Nonnull URL, CGSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
        CollectionViewItem *cell = (CollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        
        [cell.thumbnailImageView setImage:image];
    }];
    
    return item;
}

@end
