## 接口解释

**TabView** 其实内部封装了一个 collectionView，所以使用方法和 UICollectionView 类似。

`animationDuration`，tab item 选中状态变化和 indicator 的动画时间，默认为 0.25，如果想去掉动画，赋值为 0。

`widthType`，tab item 的宽度类型，是一个枚举：
- fixed(width: CGFloat)，固定宽度。
- evenly，根据 tab view 的宽度和 tab item 的个数平均分配宽度。
- selfSizing，根据 tab item 的 intrinsicContentSize 来决定宽度。（即子视图的约束）

`isIndicatorGestureDriven`，indicator 是否会随着 coordinatedScrollView 的滚动而移动，默认为 false，当滚动进度大于百分之50时改变状态。

`isItemGestureDriven`，tab item 是否会随着 coordinatedScrollView 的滚动而移动，默认为 false，当滚动进度大于百分之50时改变状态。

`noneGestureGrivenUpdateMode`, 当前面两个值为 false 时，tab item 或者 indicator 的改变时机：
- begin 一开始就变化。
- middle 超过一半时变化。
- 结束时变化。

---

**TabItem** 是一个 protocol，它提供了一些方法供自定义 tab item。

`reuseIdentifier`，用于复用的 identifier。

`udpate(with progress: CGFloat)`，当 coordinatedScrollView 滚动时，会调用相应 item 的这个方法，并传入当前的进度，progress 的变化区间为 0 -> 1，0 当小于 0.5 时，代表未选中，反之代表选中。

`update(with selected: Bool)`，当 tab item 被点击时，会调用相应 item 的这个方法，并传入当前的选中状态。

---

**TabViewDelegate**，tab view 的 delegate。

`numberOfItems(in:)`，tab item 的数量。

`tabView(_:cellForItemAt:)`，为指定的 index 创建 item。

`tabView(_:didSelectItemAt:)`，选中某个 cell 的回调。

`tabView(_:indicatorViewWith:)`，创建 indicator，注意 indicator 必须加到 indicatorSuperView 上。

`tabView(_:update:with:)`，随 coordinatedScrollView 滚动更新 indicator 的回调，progress 的变化区间为 0->1->0。

---

**TabItemCell**，一个 TabItem 的具体实现类，具有字体变化，颜色变化功能。

## 需要注意的点

1. indicatorSuperView 是 indicator 的父视图，在 coordinatedScrollView 滚动过程中，它的 frame 一直在变，size 最终是选中的那个 item 的大小。
2. 因为 TabView 的状态是根据 coordinatedScrollView 的 contentOffset 来改变的，所以该类只适用于有 coordinatedScrollView 且未对 contentOffset 做一些其他操作的情况。

## 结语

总体来说，这种组件还是属于强业务逻辑的类型，比如有时候需要在 item 上显示更多的信息等等，在封装的时候发现如果想要做到大而全是根本不可能的。当然对于某个固定的 app 里面，多个类似的出现的时候可以封装一下。