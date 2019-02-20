//
//  ViewController.m
//  Demo-macOS
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
    
    [KSOThumbnailManager.sharedManager thumbnailOperationForURL:self.URLs[[indexPath indexAtPosition:1]] completion:^(KSOThumbnailManager * _Nonnull thumbnailManager, NSImage * _Nullable image, NSError * _Nullable error, KSOThumbnailManagerCacheType cacheType, NSURL * _Nonnull URL, CGSize size, NSUInteger page, NSTimeInterval time, CGFloat timeRatio) {
        NSLog(@"%@ %@",URL,@(cacheType));
        CollectionViewItem *cell = (CollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        
        [cell.thumbnailImageView setImage:image];
    }];
    
    return item;
}

@end
