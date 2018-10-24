//
//  ViewController.swift
//  TabView
//
//  Created by Josscii on 2018/9/6.
//  Copyright © 2018 Josscii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let items = ["哈密瓜", "苹果", "葡萄", "香蕉", "西瓜", "芒果", "梨", "橙子", "椰子", "石榴"]
    
    var scrollView: UIScrollView!
    
    var tabView1: TabView!
    var tabView2: TabView!
    var tabView3: WYTabView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupView()
    }
    
    func setupView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        addSubViewsToScrollView(with: items.count)
        view.addSubview(scrollView)
        
        tabView1 = TabView(frame: CGRect(x: 0, y: 44, width: view.bounds.width, height: 60), coordinatedScrollView: scrollView)
        tabView1.delegate = self
        tabView1.backgroundColor = .brown
        tabView1.isItemGestureDriven = true
        tabView1.isIndicatorGestureDriven = true
        tabView1.widthType = .selfSizing
        tabView1.register(TabItemCell.self, forCellWithReuseIdentifier: TabItemCell.reuseIdentifier)
        view.addSubview(tabView1)
        
        tabView2 = TabView(frame: CGRect(x: 0, y: 110, width: view.bounds.width, height: 60), coordinatedScrollView: scrollView)
        tabView2.delegate = self
        tabView2.backgroundColor = .brown
        tabView2.widthType = .fixed(width: 80)
        tabView2.isItemGestureDriven = true
        tabView2.isIndicatorGestureDriven = true
        tabView2.register(TabItemCell.self, forCellWithReuseIdentifier: TabItemCell.reuseIdentifier)
        view.addSubview(tabView2)
        
        tabView3 = WYTabView(frame: CGRect(x: 0, y: 180, width: view.bounds.width, height: 60), coordinatedScrollView: scrollView)
        tabView3.delegate = self
        tabView3.backgroundColor = .brown
        tabView3.widthType = .selfSizing
        tabView3.register(WYTabItemCell.self, forCellWithReuseIdentifier: WYTabItemCell.reuseIdentifer())
        view.addSubview(tabView3)
    }

    func addSubViewsToScrollView(with count: Int) {
        for i in 0..<count {
            let subView = UIView()
            subView.frame = CGRect(x: CGFloat(i) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
            subView.backgroundColor = UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
            scrollView.addSubview(subView)
        }
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(count), height: view.bounds.height)
    }
}

extension ViewController: UIScrollViewDelegate {
    
}

extension ViewController: WYTabViewDelegate {
    func number(ofItems tabView: WYTabView) -> Int {
        return items.count
    }
    
    func tabView(_ tabView: WYTabView, cellForItemAt index: Int) -> WYTabItem {
        let item = tabView.dequeueReusableCell(withReuseIdentifier:WYTabItemCell.reuseIdentifer(), for: index) as! WYTabItemCell
        item.normalTextColor = .white
        item.selectedTextColor = .green
        item.selectedTextFontBold = true
        item.selectedTextFontSize = 20
        item.titleLabel.text = items[index]
        return item
    }
    
    func tabView(_ tabView: WYTabView, didSelectItemAt index: Int) {
        scrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: false)
        
        if tabView2.selectedIndex != index {
            tabView2.select(itemAt: index)
        }
        
        if tabView1.selectedIndex != index {
            tabView1.select(itemAt: index)
        }
    }
    
    func tabView(_ tabView: WYTabView, indicatorWithSuperView superView: UIView) -> UIView {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(view)
        view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 10).isActive = true
        view.leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -10).isActive = true
        view.rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
        return view
    }
    
    func tabView(_ tabView: WYTabView, updateIndicator indicator: UIView, withProgress progress: CGFloat) {
        
    }
}

extension ViewController: TabViewDelegate {
    func numberOfItems(in tabView: TabView) -> Int {
        return items.count
    }
    
    func tabView(_ tabView: TabView, cellForItemAt index: Int) -> TabItem {
        let item = tabView.dequeueReusableCell(withReuseIdentifier: TabItemCell.reuseIdentifier, for: index) as! TabItemCell
        item.normalTextColor = .white
        item.selectedTextColor = .green
        item.selectedTextFontBold = true
        item.selectedTextFontSize = 20
        item.titleLabel.text = items[index]
        return item
    }
    
    func tabView(_ tabView: TabView, didSelectItemAt index: Int) {
        scrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: false)
        
        if tabView == tabView1 {
            if tabView2.selectedIndex != index {
                tabView2.select(itemAt: index)
            }
        } else {
            if tabView1.selectedIndex != index {
                tabView1.select(itemAt: index)
            }
        }
    }
    
    func tabView(_ tabView: TabView, indicatorViewWith superView: UIView) -> UIView? {
        if tabView == tabView1 {
            let view = UIView()
            view.backgroundColor = .yellow
            view.frame = CGRect(x: (superView.bounds.width - 10)/2, y: 0, width: 10, height: 2)
            superView.addSubview(view)
            return view
        } else if tabView == tabView2 {
            let view = UIView()
            view.backgroundColor = .gray
            view.layer.cornerRadius = 10
            view.translatesAutoresizingMaskIntoConstraints = false
            superView.addSubview(view)
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 10).isActive = true
            view.leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -10).isActive = true
            view.rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
            return view
        }
        
        return nil
    }
    
    func tabView(_ tabView: TabView, update indicatorView: UIView?, with progress: CGFloat) {
        if tabView == tabView1 {
            guard let indicatorView = indicatorView,
                let indicatorSuperView = indicatorView.superview else {
                    return
            }
            
            let w = 10 + (30 - 10) * progress
            let centerX = indicatorSuperView.frame.width / 2
            
            indicatorView.frame.size.width = w
            indicatorView.center.x = centerX
        }
    }
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}
