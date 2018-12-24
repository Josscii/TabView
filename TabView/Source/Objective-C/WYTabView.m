//
//  WYTabView.m
//  TabView
//
//  Created by Josscii on 2018/10/23.
//  Copyright © 2018 Josscii. All rights reserved.
//

#import "WYTabView.h"

@interface WYTabView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UIView *indicatorSuperView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIScrollView *coordinatedScrollView;

@end

@implementation WYTabView

- (instancetype)initWithFrame:(CGRect)frame
        coordinatedScrollView:(UIScrollView *)scrollView {
    if (self = [super initWithFrame:frame]) {
        _animationDuration = 0.25;
        _coordinatedScrollView = scrollView;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [_coordinatedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionViewLayout.minimumLineSpacing = 0;
    _collectionViewLayout.minimumInteritemSpacing = 0;
    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_collectionViewLayout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.prefetchingEnabled = false;
    _collectionView.bounces = false;
    [self addSubview:_collectionView];
    
    _indicatorSuperView = [[UIView alloc] init];
    _indicatorSuperView.layer.zPosition = -1;
    [_collectionView addSubview:_indicatorSuperView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorSuperView.frame = [self frameForCellAtIndex:0];
        self.indicatorView = [self.delegate tabView:self indicatorWithSuperView:self.indicatorSuperView];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.delegate == nil) {
        return;
    }
    
    switch (self.widthType) {
        case WYTabViewWidthTypeEvenly:
            self.collectionViewLayout.itemSize = CGSizeMake(self.bounds.size.width/[self.delegate numberOfItems:self], self.bounds.size.height);
            break;
        case WYTabViewWidthTypeFixed:
            self.collectionViewLayout.itemSize = CGSizeMake(self.FixedWidth, self.bounds.size.height);
            break;
        case WYTabViewWidthTypeSelfSizing:
            self.collectionViewLayout.estimatedItemSize = CGSizeMake(50, self.bounds.size.height);
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self updateTabView];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self.coordinatedScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - convience mothods

- (void)reloadData {
    [self.collectionView reloadData];
    [self updateTabView];
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (UICollectionViewCell *)cellAtIndex:(NSInteger)index {
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (CGRect)frameForCellAtIndex:(NSInteger)index {
    return [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]].frame;
}

- (void)selectItemAtIndex:(NSInteger)index {
    [UIView animateWithDuration:self.animationDuration animations:^{
        id<WYTabItem> cell = (id)[self cellAtIndex:self.selectedIndex];
        [cell updateWithSelected:false];
    }];
    
    self.selectedIndex = index;
    
    [self scrollToItemAtIndex:index];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        id<WYTabItem> cell = (id)[self cellAtIndex:index];
        [cell updateWithSelected:true];
    }];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGRect frame = [self frameForCellAtIndex:index];
        self.indicatorSuperView.frame = frame;
        [self.indicatorSuperView layoutIfNeeded];
        [self.delegate tabView:self updateIndicator:self.indicatorView withProgress:0];
    }];
    
    [self.delegate tabView:self didSelectItemAtIndex:index];
}

#pragma mark - private mothods

- (void)updateTabView {
    if (!self.coordinatedScrollView.isTracking &&
        !self.coordinatedScrollView.isDragging &&
        !self.coordinatedScrollView.isDecelerating) {
        return;
    }
    
    CGFloat contentOffsetX = self.coordinatedScrollView.contentOffset.x;
    CGFloat scrollViewWidth = self.coordinatedScrollView.bounds.size.width;
    CGFloat contentWidth = self.coordinatedScrollView.contentSize.width;
    
    CGFloat quotient = contentOffsetX / scrollViewWidth;
    CGFloat decimal = fmod(quotient, 1);
    
    CGFloat max = (contentWidth / scrollViewWidth) - 1;
    
    if (quotient < 0 || quotient > max) {
        return;
    }
    
    NSInteger index0 = floor(quotient);
    NSInteger index1 = ceil(quotient);
    
    if (index0 == index1) {
        self.selectedIndex = index0;
    } else {
        if (self.isIndicatorGestureDriven) {
            CGRect frame0 = [self frameForCellAtIndex:index0];
            CGRect frame1 = [self frameForCellAtIndex:index1];
            CGFloat ix = frame0.origin.x + (frame1.origin.x - frame0.origin.x) * decimal;
            CGFloat iy = frame0.origin.y;
            CGFloat iwidth = frame0.size.width + (frame1.size.width - frame0.size.width) * decimal;
            CGFloat iheight = frame0.size.height;
            self.indicatorSuperView.frame = CGRectMake(ix, iy, iwidth, iheight);
            
            [self updateIndicatorViewWithProgress:decimal];
        } else {
            if (decimal >= 0.5) {
                [UIView animateWithDuration:self.animationDuration animations:^{
                    CGRect frame1 = [self frameForCellAtIndex:index1];
                    self.indicatorSuperView.frame = frame1;
                    [self.indicatorSuperView layoutIfNeeded];
                }];
            } else {
                [UIView animateWithDuration:self.animationDuration animations:^{
                    CGRect frame0 = [self frameForCellAtIndex:index0];
                    self.indicatorSuperView.frame = frame0;
                    [self.indicatorSuperView layoutIfNeeded];
                }];
            }
        }
        
        if (self.isItemGestureDriven) {
            [self updateTabItemFromIndex:index0 toIndex:index1 withProgress:decimal];
        } else {
            if (decimal >= 0.5) {
                [UIView animateWithDuration:self.animationDuration animations:^{
                    [self updateTabItemFromIndex:index0 toIndex:index1 withProgress:1];
                }];
            } else {
                [UIView animateWithDuration:self.animationDuration animations:^{
                    [self updateTabItemFromIndex:index0 toIndex:index1 withProgress:0];
                }];
            }
        }
    }
    
    CGFloat index = decimal > 0.5 ? index1 : index0;
    [self scrollToItemAtIndex:index];
}

- (void)updateIndicatorViewWithProgress:(CGFloat)progress {
    [self.delegate tabView:self updateIndicator:self.indicatorView withProgress:progress];
}

- (void)updateTabItemFromIndex:(NSInteger)index0 toIndex:(NSInteger)index1 withProgress:(CGFloat)progress {
    [self updateTabItemWithIndex:index0 progress:1-progress];
    [self updateTabItemWithIndex:index1 progress:progress];
}

- (void)updateTabItemWithIndex:(NSInteger)index progress:(CGFloat)progress {
    id<WYTabItem> tabItem = (id)[self cellAtIndex:index];
    [tabItem updateWithProgress:progress];
}

- (void)scrollToItemAtIndex:(NSInteger)index {
    [UIView animateWithDuration:0.25 animations:^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectItemAtIndex:indexPath.item];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.delegate != nil, @"delegate must not be nil");
    
    return [self.delegate numberOfItems:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.delegate != nil, @"delegate must not be nil");
    
    id<WYTabItem> item = [self.delegate tabView:self cellForItemAtIndex:indexPath.item];
    [item updateWithSelected:indexPath.item == self.selectedIndex];
    
    NSAssert([item isKindOfClass:[UICollectionViewCell class]], @"item must not be UICollectionViewCell subclass");
    
    return (UICollectionViewCell *)item;
}

@end
