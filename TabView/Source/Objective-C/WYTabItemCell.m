//
//  WYTabItemCell.m
//  TabView
//
//  Created by Josscii on 2018/10/23.
//  Copyright © 2018 Josscii. All rights reserved.
//

#import "WYTabItemCell.h"

@interface WYTabItemCell ()

@property (nonatomic, assign) CGFloat margin;

@end

@implementation WYTabItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self setupViews];
    }
    return self;
}

- (void)commonInit {
    _normalTextColor = [UIColor blackColor];
    _selectedTextColor = [UIColor redColor];
    _normalTextFontSize = 17;
    _selectedTextFontSize = 17;
}

- (void)setupViews {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_titleLabel];
    [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin].active = YES;
    [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin].active = YES;
    [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;
}

- (CGFloat)margin {
    return 8;
}

- (void)fontTransfromWithProgress:(CGFloat)progress {
    CGFloat selectedTextFontSize = self.selectedTextFontSize;
    CGFloat normalTextFontSize = self.normalTextFontSize;
    if (selectedTextFontSize != normalTextFontSize) {
        CGFloat scale = 0;
        if (selectedTextFontSize > normalTextFontSize) {
            scale = (normalTextFontSize+(selectedTextFontSize-normalTextFontSize) * progress)/selectedTextFontSize;
        } else {
            scale = (normalTextFontSize-(normalTextFontSize-selectedTextFontSize) * progress)/normalTextFontSize;
        }
        self.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    if (progress > 0.5) {
        [self updateTitleFontWithSelected:YES];
    } else {
        [self updateTitleFontWithSelected:NO];
    }
}

- (void)colorTransfromWithProgress:(CGFloat)progress {
    CGFloat f = MIN(1, MAX(0, progress));
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self.normalTextColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [self.selectedTextColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat r = r1 + (r2 - r1) * f;
    CGFloat g = g1 + (g2 - g1) * f;
    CGFloat b = b1 + (b2 - b1) * f;
    CGFloat a = a1 + (a2 - a1) * f;
    
    self.titleLabel.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)updateTitleFontWithSelected:(BOOL)selected {
    if (self.selectedTextFontSize >= self.normalTextFontSize) {
        if (selected && self.selectedTextFontSize) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:self.selectedTextFontSize];
        } else {
            self.titleLabel.font = [UIFont systemFontOfSize:self.selectedTextFontSize];
        }
    } else if (self.selectedTextFontSize < self.normalTextFontSize) {
        if (selected && self.selectedTextFontSize) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:self.normalTextFontSize];
        } else {
            self.titleLabel.font = [UIFont systemFontOfSize:self.normalTextFontSize];
        }
    }
}

- (void)updateTitleTransfromWithSelected:(BOOL)selected {
    CGFloat scale = 0;
    if (self.selectedTextFontSize > self.normalTextFontSize) {
        scale = self.normalTextFontSize / self.selectedTextFontSize;
        
        if (selected) {
            self.titleLabel.transform = CGAffineTransformIdentity;
        } else {
            self.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
        }
    } else if (self.selectedTextFontSize < self.normalTextFontSize) {
        scale = self.selectedTextFontSize / self.normalTextFontSize;
        
        if (selected) {
            self.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
            self.titleLabel.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)updateTitleColorWithSelected:(BOOL)selected {
    if (selected) {
        self.titleLabel.textColor = self.selectedTextColor;
    } else {
        self.titleLabel.textColor = self.normalTextColor;
    }
}

#pragma mark - WYTabItem

+ (NSString *)reuseIdentifer {
    return @"WYTabItemCell";
}

- (void)updateWithProgress:(CGFloat)progress {
    [self fontTransfromWithProgress:progress];
    [self colorTransfromWithProgress:progress];
}

- (void)updateWithSelected:(BOOL)selected {
    [self updateTitleFontWithSelected:selected];
    [self updateTitleTransfromWithSelected:selected];
    [self updateTitleColorWithSelected:selected];
}

@end
