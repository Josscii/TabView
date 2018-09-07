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
    /// title label's normal text font
    public var normalTextFont: UIFont = .systemFont(ofSize: 17)
    /// title label's selected text font
    public var selectedTextFont: UIFont = .systemFont(ofSize: 17)
    
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
        let selectedTextFontSize = selectedTextFont.pointSize
        let normalTextFontSize = normalTextFont.pointSize
        
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
        titleLabel.textColor = UIColor.interpolate(from: normalTextColor, to: selectedTextColor, with: progress)
    }
    
    private func updateTitleFont(selected: Bool) {
        if selectedTextFont.pointSize > normalTextFont.pointSize {
            titleLabel.font = selectedTextFont
        } else if (selectedTextFont.pointSize < normalTextFont.pointSize) {
            titleLabel.font = normalTextFont
        } else {
            if selected {
                titleLabel.font = selectedTextFont
            } else {
                titleLabel.font = normalTextFont
            }
        }
    }
    
    private func updateTitleTransform(selected: Bool) {
        let selectedTextFontSize = selectedTextFont.pointSize
        let normalTextFontSize = normalTextFont.pointSize
        let scale: CGFloat
        if selectedTextFontSize > normalTextFontSize {
            scale = normalTextFontSize / selectedTextFontSize
            
            if selected {
                titleLabel.transform = .identity
            } else {
                titleLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        } else {
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

private extension UIColor {
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components!
        
        switch components.count == 2 {
        case true : return (r: components[0], g: components[0], b: components[0], a: components[1])
        case false: return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }
    
    static func interpolate(from fromColor: UIColor, to toColor: UIColor, with progress: CGFloat) -> UIColor {
        let fromComponents = fromColor.components
        let toComponents = toColor.components
        
        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

