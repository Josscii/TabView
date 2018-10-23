//
//  TabItemCell.swift
//  TabViewDemo
//
//  Created by Josscii on 2018/7/24.
//  Copyright © 2018 josscii. All rights reserved.
//

import UIKit

/// a concrete tab item cell which support title color transfrom, title font size transform
public class TabItemCell: UICollectionViewCell {
    /// the title label of cell
    public var titleLabel = UILabel()
    /// title label's left and right margin
    public var margin: CGFloat = 8
    /// title label's normal text color
    public var normalTextColor: UIColor = .black
    /// title label's selected text color
    public var selectedTextColor: UIColor = .red
    /// title label's normal text font size
    public var normalTextFontSize: CGFloat = 17
    /// title label's selected text font size
    public var selectedTextFontSize: CGFloat = 17
    /// if the selected item's font is bold
    public var selectedTextFontBold = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    /// setup subViews, subclass must call super
    public func setupViews() {
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: margin).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -margin).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension TabItemCell {
    private func fontTransform(with progress: CGFloat) {
        if selectedTextFontSize != normalTextFontSize {
            let scale: CGFloat
            
            if selectedTextFontSize > normalTextFontSize {
                scale = (normalTextFontSize+(selectedTextFontSize-normalTextFontSize) * progress)/selectedTextFontSize
            } else {
                scale = (normalTextFontSize-(normalTextFontSize-selectedTextFontSize) * progress)/normalTextFontSize
            }
            
            titleLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        }
        
        if progress > 0.5 {
            self.updateTitleFont(selected: true)
        } else {
            self.updateTitleFont(selected: false)
        }
    }
    
    private func colorTransform(with progress: CGFloat) {
        let f = min(1, max(0, progress))
        
        var r1: CGFloat = 0; var g1: CGFloat = 0; var b1: CGFloat = 0; var a1: CGFloat = 0
        var r2: CGFloat = 0; var g2: CGFloat = 0; var b2: CGFloat = 0; var a2: CGFloat = 0
        
        normalTextColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1);
        selectedTextColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2);
        
        let r = r1 + (r2 - r1) * f;
        let g = g1 + (g2 - g1) * f;
        let b = b1 + (b2 - b1) * f;
        let a = a1 + (a2 - a1) * f;
        
        titleLabel.textColor = UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    private func updateTitleFont(selected: Bool) {
        if selectedTextFontSize >= normalTextFontSize {
            if selected && selectedTextFontBold {
                titleLabel.font = UIFont.boldSystemFont(ofSize: selectedTextFontSize)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: selectedTextFontSize)
            }
        } else if selectedTextFontSize < normalTextFontSize {
            if selected && selectedTextFontBold {
                titleLabel.font = UIFont.boldSystemFont(ofSize: normalTextFontSize)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: normalTextFontSize)
            }
        }
    }
    
    private func updateTitleTransform(selected: Bool) {
        let scale: CGFloat
        if selectedTextFontSize > normalTextFontSize {
            scale = normalTextFontSize / selectedTextFontSize
            
            if selected {
                titleLabel.transform = .identity
            } else {
                titleLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        } else if selectedTextFontSize < normalTextFontSize {
            scale = selectedTextFontSize / normalTextFontSize
            
            if selected {
                titleLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            } else {
                titleLabel.transform = .identity
            }
        }
    }
    
    private func updateTitleColor(selected: Bool) {
        if selected {
            titleLabel.textColor = selectedTextColor
        } else {
            titleLabel.textColor = normalTextColor
        }
    }
}

extension TabItemCell: TabItem {
    public static let reuseIdentifier = "TabItemCell"
    
    public func update(with progress: CGFloat) {
        fontTransform(with: progress)
        colorTransform(with: progress)
    }
    
    public func update(with selected: Bool) {
        updateTitleFont(selected: selected)
        updateTitleTransform(selected: selected)
        updateTitleColor(selected: selected)
    }
}
