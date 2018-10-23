//
//  WYTabItemCell.h
//  TabView
//
//  Created by Josscii on 2018/10/23.
//  Copyright © 2018 Josscii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYTabView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WYTabItemCell : UICollectionViewCell <WYTabItem>

@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, assign) CGFloat normalTextFontSize;
@property (nonatomic, assign) CGFloat selectedTextFontSize;
@property (nonatomic, assign) BOOL selectedTextFontBold;
@property (nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
