# RedPackRain
红包雨组件, 可自行配置图片, 持续时间, 结束总时间。

![红包雨效果.gif](https://github.com/Orange-W/RedPackRain/blob/master/gif/RedPack.gif?raw=true)

## pod引入

使用`pod 'RedPackRainView'`即可, 必要时添加官方源 `source 'https://github.com/CocoaPods/Specs.git'`

#### 简单设置

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
                print("累计\(redPackView.redPackClickedCount)个红包")
                clickview.removeFromSuperview()
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



### Api介绍

#### 红包设置

```Swift
    /// 红包设置
    ///
    /// - Parameters:
    ///   - images: 红包图片集 ,会循环轮播
    ///   - size: 红包的图片大小,不设和图片等大
    ///   - animationDuration: 轮播间隔,默认 1秒
    ///   - intervalTime: 红包间隔, 默认 0.5秒 一封
    ///   - totalTime: 总动画时间
    ///   - clickedHandle: 点击红包回调
    public func setRedPack(
        images: [UIImage]?,
        size: CGSize? = nil,
        animationDuration: Double? = 1,
        intervalTime: Double = 0.1,
        dropDownTime: Double = 2,
        totalTime: Double = 30,
        clickedHandle: ClickHandle? = nil
        )
```

### 红包雨结束时候的回调

```swift
    /// 红包雨结束回调
    ///
    /// - Parameter completeHandle: 回调handle
    public func setCompleteHandle(completeHandle: @escaping RedPackRainView.RedPackRainView.CompleteHandle)
```

### 开始和结束动画

```swift
/// 开始动画
public func beginToRain() 
/// 结束动画
public func endRain()
```