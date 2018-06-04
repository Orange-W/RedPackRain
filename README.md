# RedPackRain
红包雨组件, 可自行配置图片, 持续时间, 结束总时间。

![红包雨效果.gif](https://github.com/Orange-W/RedPackRain/blob/master/gif/RedPack.gif?raw=true)



## 项目接入

#### pod接入

使用`pod 'RedPackRainView'`即可, 必要时添加官方源 `source 'https://github.com/CocoaPods/Specs.git'`

#### 快速使用Demo

```swift
import UIKit

class ViewController: UIViewController {
    let redPackRain = RedPackRainView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(redPackRain)
        redPackRain.frame = self.view.bounds
        // 设置 轮播的红包图片, 和点击效果
        redPackRain.setRedPack(images:
            [UIImage.init(named: "redpack1.jpeg")!,
             UIImage.init(named: "redpack2.jpeg")!,
             UIImage.init(named: "redpack3.jpeg")!]) { (redPackView, clickview) in
                print("这是第\(redPackView.redPackClickedCount)个红包")
                clickview.removeFromSuperview()
				// 获取当前动画状态
				guard let layer = clickView.layer.presentation() else {
                	return
            	}
        }
        
        // 设置红包结束回调
        redPackRain.setCompleteHandle { (redPackView) in
            print("一共点中了\(redPackView.redPackClickedCount)个红包")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        redPackRain.beginToRain()
    }
}
```



## 基础Api介绍

### 红包设置

```Swift
    /// 红包设置
    ///
    /// - Parameters:
    ///   - images: 红包图片集 ,会循环轮播
    ///   - size: 红包的图片大小,不设和图片等大
    ///   - animationDuration: 轮播间隔,默认 1秒
    ///   - intervalTime: 红包间隔, 默认 0.5秒 一封
    ///   - dropDownTime: 红包落下时间, 默认 5秒落到底部
    ///   - totalTime: 总动画时间, 默认持续 30秒
    ///   - clickedHandle: 点击红包回调
    public func setRedPack(
        images: [UIImage]?, 
        size: CGSize? = default, 
        animationDuration: Double? = default, 
        intervalTime: Double = default, 
        dropDownTime: Double = default, 
        totalTime: Double = default, 
        clickedHandle: RedPackRainView.RedPackRainView.ClickHandle? = default)
```



### 红包雨结束时候的回调

```swift
    /// 红包雨结束回调
    ///
    /// - Parameter completeHandle: 回调handle
    public func setCompleteHandle(completeHandle: @escaping RedPackRainView.RedPackRainView.CompleteHandle)
```



### 红包雨出现的回调

```Swift
    /// 红包出现的回调
    ///
    /// - Parameter completeHandle: 回调handle
    public func setRedPackAppearHandle(handle: @escaping RedPackAppearHandle) {
        self.redPackAppearHandle = handle
    }
```



### 开始和结束动画

```swift
/// 开始动画
public func beginToRain() 
/// 结束动画
public func endRain()
```


## 点击穿透功能

### 把界面添加至点击不可穿透列表

属性 `clickPenetrateEnable`: 是否开启点击穿透, 如果开启点击效果可以穿透上层的遮挡物 。开启后默认所有界面都会被穿透，除非将其添加入不可穿透列表。

```swift
    /// 添加不可点击, 不可穿透的 view, 点击后会阻挡点击效果。
    /// 使用前先打开 clickPenetrateEnable 开关，否则不会执行任何操作。
    /// 注意：会改变 view 的 tag 值
    /// - Parameter views: 不想点击被穿透的 view 数组
    public func addNotPenetrateViews(views:[UIView]) {
        if clickPenetrateEnable {
            for view in views {
                view.tag = notPenetrateTag
            }
        }
    }
```

### 从不可穿透列表中删除

```swift
    /// 删除 View 的不可点击特性
    /// 使用前先打开 clickPenetrateEnable 开关，否则不会执行任何操作。
    /// 注意：会改变 view 的 tag 值
    /// - Parameter views: 去除不可点击穿透的 view 数组
    public func removeNotPenetrateViews(views:[UIView]) {
        if clickPenetrateEnable {
            for view in views {
                if view.tag == notPenetrateTag {
                    view.tag = 0
                }
            }
        }
    }
```



## 游戏开始结束与暂停

### 启动红包雨

```swift
    // MARK: 启动红包雨
    public func startGame(configBlock: ((RedpackRainView) -> Void)? = nil) {
        //防止timer重复添加
        resetValue()
        configBlock?(self)
        self.timer =  Timer.scheduledTimer(timeInterval: minRedPackIntervalTime, target: self, selector: #selector(showRain), userInfo: "", repeats: true)
    }
```



### 结束游戏

```swift
    /// 结束游戏
    public func endGame() {
        self.timer.invalidate()
        // 清除界面红包和炸弹
        clearAllBomb()
        clearAllRedPack()
        completeHandle?(self)
    }
```



### 暂停红包雨

```swift
	/// 暂停红包雨
    public func stopRain() {
        self.timer.invalidate()
        stopRedPack()
        stopBomb()
        stopTimeBack()
    }
```



###  恢复游戏

```
/// 继续下落红包雨
    public func continueRain() {
        self.timer.invalidate()
        stopTimeBack()
        self.timer =  Timer.scheduledTimer(timeInterval: minRedPackIntervalTime, target: self, selector: #selector(showRain), userInfo: "", repeats: true)
        resumeRedPack()
        resumeBomb()
    }
```



### 红包动画倒流

```swift
    public func timeBackRain() {
        // 暂停红包雨
        stopRain()
        // 重置回溯参数
        stopTimeBack()
        // 标记当前状态 (为了下面判断 0.3 秒的延时)
        isInTimeBack = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if self.isInTimeBack {
                self.backTimetimer = Timer.scheduledTimer(timeInterval: self.minRedPackIntervalTime, target: self, selector: #selector(self.backTime), userInfo: "", repeats: true)
            }
        }
    }
```



![红包雨效果.gif](https://github.com/Orange-W/RedPackRain/blob/master/gif/RedPack2.gif?raw=true)





## 代理说明

```swift
@objc protocol RedpackRainDelegate {
    /// 红包出现
    @objc optional func redpackDidAppear(rainView: RedpackRainView, redpack: UIView, index: Int) -> Void
    /// 红包被点中
    @objc optional func redpackDidClicked(rainView: RedpackRainView, redpack: UIView) -> Void

    /// 炸弹出现
    @objc optional func bombDidAppear(rainView: RedpackRainView, bomb: UIView, index: Int) -> Void
    ///  炸弹被点中
    @objc optional func bombDidClicked(rainView: RedpackRainView, bomb: UIView) -> Void
}
```



## Public 属性说明

### 红包配置

```swift
	// MARK: 红包配置
	/// 红包view列表
    public var redPackList: [UIImageView] = []
    public var redPackImages: [UIImage] = []
    /// 红包总数
    public private(set) var redPackAllCount = 0
    /// 点中的红包数
    public private(set) var redPackClickedCount = 0
```



### 炸弹配置

```Swift
    // MARK: 炸弹配置
    /// 炸弹密度,每10个红包一个炸弹
    public var bombList: [UIImageView] = []
    public var bombImages: [UIImage] = []
    /// 炸弹频率,每x个红包出现一个炸弹,默认 0 则没有炸弹
    public var bombDensity = 0
    /// 炸弹总数计数器
    public private(set) var bombAllCount = 0
    /// 点中的炸弹数
    public private(set) var bombClickedCount = 0
```



### 全局配置

```swift
// MARK: 运行控制
    /// 定时器
    public var timer: Timer = Timer.init()

    /// 是否开启点击穿透, 如果开启点击效果可以穿透上层的遮挡物 。
    /// 开启后默认所有界面都会被穿透，除非将其添加入不可穿透列表。
    public var clickPenetrateEnable = false

    /// 红包雨持续总时间
    public var totalTime = 0.0
    /// 已执行时间
    public private(set) var runTimeTotal: Double = 0
    /// 剩余时间
    public var restTime: Double { return totalTime - runTimeTotal }
    /// 最小红包间隔周期,0.01 秒
    public let minRedPackIntervalTime = 0.01
    /// 红包下落速度,到底部时间
    public var redPackDropDownTime = 0.0
    /// 发红包间隔时间
    public var redPackIntervalTime = 0.0 {
        didSet {
            if redPackIntervalTime < 0.01 {
                redPackIntervalTime = 0.01
            }
        }
    }
```

