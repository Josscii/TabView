//
//  WYTabView.h
//  TabView
//
//  Created by Josscii on 2018/10/23.
//  Copyright © 2018 Josscii. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYTabView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WYTabViewWidthType) {
    WYTabViewWidthTypeFixed,
    WYTabViewWidthTypeEvenly,
    WYTabViewWidthTypeSelfSizing,
};

@protocol WYTabItem <NSObject>

+ (NSString *)reuseIdentifer;

@optional
- (void)updateWithProgress:(CGFloat)progress;
- (void)updateWithSelected:(BOOL)selected;

@end

@protocol WYTabViewDelegate <NSObject>

- (NSInteger)numberOfItems:(WYTabView *)tabView;
- (id<WYTabItem>)tabView:(WYTabView *)tabView cellForItemAtIndex:(NSInteger)index;
@optional
- (void)tabView:(WYTabView *)tabView didSelectItemAtIndex:(NSInteger)index;
- (UIView *)tabView:(WYTabView *)tabView indicatorWithSuperView:(UIView *)superView;
- (void)tabView:(WYTabView *)tabView updateIndicator:(UIView *)indicator withProgress:(CGFloat)progress;

@end

@interface WYTabView : UIView

@property (nonatomic, weak) id<WYTabViewDelegate> delegate;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) WYTabViewWidthType widthType;
@property (nonatomic, assign) CGFloat FixedWidth;
@property (nonatomic, assign) BOOL isIndicatorGestureDriven;
@property (nonatomic, assign) BOOL isItemGestureDriven;
@property (nonatomic, assign) NSInteger selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame coordinatedScrollView:(UIScrollView *)scrollView;
- (void)reloadData;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;
- (void)selectItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
