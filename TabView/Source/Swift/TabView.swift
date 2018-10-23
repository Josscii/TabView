//
//  TabView.swift
//  TabView
//
//  Created by josscii on 2018/7/17.
//  Copyright © 2018年 josscii. All rights reserved.
//

import UIKit

/// TabView's delegate protocol
public protocol TabViewDelegate: class {
    /// number of items in tabView, required
    ///
    /// - Parameter tabView: tabView
    /// - Returns: number of items
    func numberOfItems(in tabView: TabView) -> Int
    
    /// cell item at index, required
    ///
    /// - Parameters:
    ///   - tabView: tabView
    ///   - index: index of item
    /// - Returns: cell for item, must be a `UICollectionViewCell` subclass which comforms to `TabItem`
    func tabView(_ tabView: TabView, cellForItemAt index: Int) -> TabItem
    
    /// did select item at index, optional
    ///
    /// - Parameters:
    ///   - tabView: tabView
    ///   - index: index of the selected item
    func tabView(_ tabView: TabView, didSelectItemAt index: Int)
    
    /// configure the indicator view, optional
    ///
    /// - Parameters:
    ///   - tabView: tabView
    ///   - superView: indicator's superView
    /// - Returns: indicator which must add to superView
    func tabView(_ tabView: TabView, indicatorViewWith superView: UIView) -> UIView?
    
    /// update the indicator view with transition progress, progress is 0->1->0
    ///
    /// - Parameters:
    ///   - tabView: tabView
    ///   - indicatorView: indicator
    ///   - progress: the transition progress
    func tabView(_ tabView: TabView, update indicatorView: UIView?, with progress: CGFloat)
}

extension TabViewDelegate {
    func tabView(_ tabView: TabView, didSelectItemAt index: Int) {}
    func tabView(_ tabView: TabView, indicatorViewWith superView: UIView) -> UIView? { return nil }
    func tabView(_ tabView: TabView, update indicatorView: UIView?, with progress: CGFloat) {}
}

/// TabView's item protocol
public protocol TabItem {
    /// reuse identifier of a tab item
    static var reuseIdentifier: String { get }
    
    /// update item view with progress
    ///
    /// - Parameter progress: the progress is always 0->1
    func update(with progress: CGFloat)
    
    /// update item view with selected state
    ///
    /// - Parameter selected: if the item is selected
    func update(with selected: Bool)
}

extension TabItem {
    func update(with progress: CGFloat) {}
    func update(with selected: Bool) {}
}

/// tab item width type
///
/// - fixed: fixed width
/// - evenly: divide the tab view' width evenly
/// - selfSizing: use the tab item's internal size
public enum TabViewWidthType {
    case fixed(width: CGFloat)
    case evenly
    case selfSizing
}

public class TabView: UIView {
    // MARK: - public properties
    /// TabView's delegate
    public weak var delegate: TabViewDelegate?
    /// animation duration of tab item and indicator animation, set to 0 to disable animation
    public var animationDuration: Double = 0.25
    /// item width type
    public var widthType: TabViewWidthType = .evenly
    /// if the indicator tranistion with gesture movement
    public var isIndicatorGestureDriven = false
    /// if the item's properties with gesture movement
    public var isItemGestureDriven = false
    /// current selected index
    public private(set) var selectedIndex = 0
    
    // MARK: - private properties
    /// internal collectionView
    private var collectionView: UICollectionView!
    /// layout of collectinView
    private var collectionViewLayout: UICollectionViewFlowLayout!
    /// the superview of indicator, you must always add your indicator to it
    private var indicatorSuperView: UIView!
    /// indicator
    private var indicatorView: UIView?
    /// the scrollView assioated with tabView
    private let coordinatedScrollView: UIScrollView
    /// if is first init, a flag for some configuration
    private var isFirstInit = true
    
    // MARK: - init
    public init(frame: CGRect, coordinatedScrollView: UIScrollView) {
        self.coordinatedScrollView = coordinatedScrollView
        super.init(frame: frame)
        setupViews()
    }
    
    convenience public init(coordinatedScrollView: UIScrollView) {
        self.init(frame: .zero, coordinatedScrollView: coordinatedScrollView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// subviews setup
    private func setupViews() {
        coordinatedScrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPrefetchingEnabled = false
        collectionView.bounces = false
        addSubview(collectionView)
        
        indicatorSuperView = UIView()
        indicatorSuperView.layer.zPosition = -1
        collectionView.addSubview(indicatorSuperView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let delegate = delegate else {
            return
        }
        
        switch widthType {
        case .evenly:
            collectionViewLayout.itemSize = CGSize(width: bounds.width/CGFloat(delegate.numberOfItems(in: self)), height: bounds.height)
        case .fixed(let width):
            collectionViewLayout.itemSize = CGSize(width: width, height: bounds.height)
        case .selfSizing:
            collectionViewLayout.estimatedItemSize = CGSize(width: 50, height: bounds.height)
        }
    }
    
    deinit {
        coordinatedScrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension TabView {
    /// kvo trigger
    override public func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentOffset" {
            updateTabView()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - convience mothods
public extension TabView {
    /// reload collectionView's data, calculate selected index base on current contentOffset
    public func reloadData() {
        collectionView.reloadData()
        updateTabView()
    }
    
    /// convience method for register cell
    public func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// convience method for dequeue cell
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0))
    }
    
    /// return a cell at index
    public func cell(at index: Int) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    /// select item at index
    public func select(itemAt index: Int) {
        // animate update the previous selected cell
        UIView.animate(withDuration: animationDuration) {
            let cell = self.cell(at: self.selectedIndex) as? TabItem
            cell?.update(with: false)
        }
        
        // update selected index
        selectedIndex = index
        
        // scroll the collectionView to index
        scrollToItem(at: index)
        
        // animate update the selected cell
        UIView.animate(withDuration: animationDuration) {
            let cell = self.cell(at: self.selectedIndex) as? TabItem
            cell?.update(with: true)
        }
        
        // animate indicator
        UIView.animate(withDuration: animationDuration) {
            if let frame = self.frameForCell(at: index) {
                self.indicatorSuperView.frame = frame
                self.indicatorSuperView.layoutIfNeeded()
                self.delegate?.tabView(self, update: self.indicatorView, with: 0)
            }
        }
        
        // call the delegate
        delegate?.tabView(self, didSelectItemAt: index)
    }
    
    /// return the frame of a cell at index
    private func frameForCell(at index: Int) -> CGRect? {
        return collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))?.frame
    }
}
    
// MARK: - private mothods
extension TabView {
    /// update tab view when contentoffset is changed
    private func updateTabView() {
        // if contentOffset isn't init by gesture, just return
        if !coordinatedScrollView.isTracking &&
            !coordinatedScrollView.isDragging &&
            !coordinatedScrollView.isDecelerating {
            return
        }
        
        let contentOffsetX = coordinatedScrollView.contentOffset.x
        let scrollViewWidth = coordinatedScrollView.bounds.width
        let contentWidth = coordinatedScrollView.contentSize.width
        
        let quotient = contentOffsetX / scrollViewWidth
        let decimal = fmod(quotient, 1)
        
        let max = (contentWidth / scrollViewWidth) - 1
        if quotient < 0 || quotient > max {
            return
        }
        
        let index0 = Int(floor(quotient))
        let index1 = Int(ceil(quotient))
        
        // udpate the selectedIndex
        if index0 == index1 {
            selectedIndex = index0
        } else {
            if isIndicatorGestureDriven {
                // update the indicatorSuperView's frame
                if let frame0 = frameForCell(at: index0), let frame1 = frameForCell(at: index1) {
                    let ix = frame0.origin.x + (frame1.origin.x - frame0.origin.x) * decimal
                    let iy = frame0.origin.y
                    let iwidth = frame0.size.width + (frame1.size.width - frame0.size.width) * decimal
                    let iheight = frame0.size.height
                    indicatorSuperView.frame = CGRect(x: ix, y: iy, width: iwidth, height: iheight)
                }
                
                // update the indicator, progress 0...1...0
                let progress = (0.5 - abs(0.5 - decimal)) * 2
                updateIndicatorView(with: progress)
            } else {
                if decimal >= 0.5 {
                    UIView.animate(withDuration: animationDuration) {
                        if let frame1 = self.frameForCell(at: index1) {
                            self.indicatorSuperView.frame = frame1
                            self.indicatorSuperView.layoutIfNeeded()
                        }
                    }
                } else {
                    UIView.animate(withDuration: animationDuration) {
                        if let frame0 = self.frameForCell(at: index0) {
                            self.indicatorSuperView.frame = frame0
                            self.indicatorSuperView.layoutIfNeeded()
                        }
                    }
                }
            }
            
            
            if isItemGestureDriven {
                // update the tabItems, decimal 0...1
                updateTabItem(from: index0, to: index1, with: decimal)
            } else {
                if decimal >= 0.5 {
                    UIView.animate(withDuration: animationDuration) {
                        self.updateTabItem(from: index0, to: index1, with: 1)
                    }
                } else {
                    UIView.animate(withDuration: animationDuration) {
                        self.updateTabItem(from: index0, to: index1, with: 0)
                    }
                }
            }
            
            // scroll the collectionView to index
            let index = decimal > 0.5 ? index1 : index0
            scrollToItem(at: index)
        }
    }
    
    /// the progress is alaways 0->1->0
    private func updateIndicatorView(with progress: CGFloat) {
        delegate?.tabView(self, update: indicatorView, with: progress)
    }
    
    /// 0 means item in normal state, 1 means item in selected state.
    /// when the scroll direction is `<-`, the left item's progress is 1 to 0, the right item's progress is 0 to 1.
    /// when the scroll direction is `->`, the left item's progress is 0 to 1, the right item's progress is 1 to 0.
    private func updateTabItem(from index0: Int, to index1: Int, with progress: CGFloat) {
        updateTabItem(with: index0, and: 1-progress)
        updateTabItem(with: index1, and: progress)
    }
    
    /// update tab item with progress
    private func updateTabItem(with index: Int, and progress: CGFloat) {
        let tabItem = cell(at: index) as? TabItem
        tabItem?.update(with: progress)
    }
    
    /// scroll to selected tab item
    private func scrollToItem(at index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TabView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(itemAt: indexPath.item)
    }
}

// MARK: - UICollectionViewDataSource
extension TabView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if isFirstInit && indexPath.item == 0 {
            defer {
                isFirstInit = false
            }
            
            // init indicatorViews
            indicatorSuperView.frame = cell.frame
            indicatorView = delegate?.tabView(self, indicatorViewWith: indicatorSuperView)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else {
            fatalError("delegate must not be nil")
        }
        
        return delegate.numberOfItems(in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate else {
            fatalError("delegate must not be nil")
        }
        
        let item = delegate.tabView(self, cellForItemAt: indexPath.item)
        item.update(with: indexPath.item == selectedIndex)
        
        if let cell = item as? UICollectionViewCell {
            return cell
        } else {
            fatalError("item must not be UICollectionViewCell subclass")
        }
    }
}
