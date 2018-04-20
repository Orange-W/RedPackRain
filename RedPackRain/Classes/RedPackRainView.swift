//
//  RedPackRainView.swift
//  RedPackRain
//
//  Created by Orange on 2018/4/11.
//  Copyright © 2018年 Orange. All rights reserved.
//

import UIKit

public class RedPackRainView: UIView {
    public typealias ClickHandle = (RedPackRainView, UIView) -> Void
    public typealias CompleteHandle = (RedPackRainView) -> Void
    public typealias RedPackAppearHandle = (UIImageView, Int) -> Void


    /// 定时器
    public var timer:Timer = Timer.init()
    /// 红包总数
    public private(set) var redPackAllCount = 0
    /// 点中的红包数
    public private(set) var redPackClickedCount = 0
    /// 发红包间隔时间
    public var redPackIntervalTime = 0.0
    /// 红包下落速度,到底部时间
    public var redPackDropDownTime = 0.0
    /// 红包雨持续时间
    public var totalTime = 0.0

    /// 是否开启点击穿透, 点击效果可以穿透上层的遮挡物
    public var clickPenetrateEnable = false
    public let notPenetrateTag = -1001
    public let redPackCompomentTag = -999


    
    private var redPackSize: CGSize?
    private var redPackImages: [UIImage]?
    private var redPackAnimationDuration: Double?
    private var clickHandle: ClickHandle?
    private var completeHandle: CompleteHandle?
    private var redPackAppearHandle: RedPackAppearHandle?
    private var timeCounter = 0
    // MARK: 初始化设置
    public override init(frame: CGRect) {
        super.init(frame: frame)
                let tap = UITapGestureRecognizer()
                tap.addTarget(self, action: #selector(self.clicked))
                self.addGestureRecognizer(tap)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 红包设置
    ///
    /// - Parameters:
    ///   - images: 红包图片集 ,会循环轮播
    ///   - size: 红包的图片大小,不设和图片等大
    ///   - animationDuration: 轮播间隔,默认 1秒
    ///   - intervalTime: 红包间隔, 默认 0.5秒 一封
    ///   - dropDownTime: 红包落下时间, 默认 5秒落到底部
    ///   - totalTime: 总动画时间
    ///   - clickedHandle: 点击红包回调
    /// 如果想改变轮播图片, 需要先停止播放,再改变播放
    /// imgView.stopAnimating()
    /// imgView.animationImages =  [...]
    /// imgView.startAnimating()
    public func setRedPack(
        images: [UIImage]?,
        size: CGSize? = nil,
        animationDuration: Double? = 1,
        intervalTime: Double = 0.5,
        dropDownTime: Double = 5,
        totalTime: Double = 30,
        clickedHandle: ClickHandle? = nil
        ) {
        self.redPackSize = size
        self.redPackImages = images
        self.redPackAnimationDuration = animationDuration
        self.redPackIntervalTime = intervalTime
        self.redPackDropDownTime = dropDownTime
        self.totalTime = totalTime
        self.clickHandle = clickedHandle
    }
    
    
    /// 红包雨结束回调
    ///
    /// - Parameter completeHandle: 回调handle
    public func setCompleteHandle(handle: @escaping CompleteHandle) {
        self.completeHandle = handle
    }

    /// 红包出现的回调
    ///
    /// - Parameter completeHandle: 回调handle
    public func setRedPackAppearHandle(handle: @escaping RedPackAppearHandle) {
        self.redPackAppearHandle = handle
    }


    /// 设置点击不会穿透的view
    /// 配合clickPenetrateEnable 属性使用，属性为false则不会执行任何操作。
    /// 注意：会改变 view 的 tag 值
    /// - Parameter views: 不想点击被穿透的 view 数组
    public func addNotPenetrateViews(views:[UIView]) {
        if clickPenetrateEnable {
            for view in views {
                view.tag = notPenetrateTag
            }
        }

    }
    
    // MARK: 动画
    public func beginToRain() {
        //防止timer重复添加
        self.timer.invalidate()
        self.timer =  Timer.scheduledTimer(timeInterval: redPackIntervalTime, target: self, selector: #selector(showRain), userInfo: "", repeats: true)
    }
    
    public func endRain() {
        self.timer.invalidate()
        //停止所有layer的动画
        for subview in subviews {
            subview.layer.removeAllAnimations()
            subview.removeFromSuperview()
        }
        completeHandle?(self)
    }
    
    // MARK: 私有方法
    @objc private func showRain() {
        let rest = totalTime - Double(timeCounter) * redPackIntervalTime
        guard  rest > 0 else {
            endRain()
            return
        }

        timeCounter += 1
        show()
    }
    
    private func show() {
        let size = redPackSize ?? CGSize.init(width: 50, height: 50)
        //创建画布
        let imageView = UIImageView.init()
        imageView.tag = redPackCompomentTag
        imageView.image = redPackImages?.first
        imageView.isUserInteractionEnabled = true
        if let duration = redPackAnimationDuration {
            imageView.animationDuration = duration
        }
        imageView.animationImages = redPackImages
        imageView.startAnimating()
        imageView.frame = CGRect.init(origin: CGPoint.zero, size: size)
        if redPackSize == nil {
            imageView.sizeToFit()
        }

        imageView.frame.origin = CGPoint(x: -max(size.height, size.width), y: -max(size.height, size.width))
        self.insertSubview(imageView, at: 0)
        redPackAllCount += 1
        //画布动画
        addAnimation(imageView: imageView)
        redPackDidAppear(redPack: imageView)
    }

    private func redPackDidAppear(redPack: UIImageView) {
        redPackAppearHandle?(redPack, redPackAllCount)
    }

    func addAnimation(imageView: UIImageView) {
        let moveLayer = imageView.layer
        // 此处keyPath为CALayer的属性
        let  moveAnimation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath:"position")
        // 动画路线，一个数组里有多个轨迹点
        moveAnimation.values = [NSValue(cgPoint: CGPoint(x: CGFloat(Float(arc4random_uniform(UInt32(frame.width)))), y: -imageView.frame.height)),NSValue(cgPoint: CGPoint(x:CGFloat(Float(arc4random_uniform(UInt32(frame.width)))), y: frame.height+10))]
        // 动画间隔
        moveAnimation.duration = redPackDropDownTime
        //重复次数
        moveAnimation.repeatCount = 1
        // 动画的速度
        moveAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        // 动画结束在视野外, 则销毁
        CATransaction.setCompletionBlock {
            if let yIndex = imageView.layer.presentation()?.frame.origin.y, yIndex > self.frame.height {
                imageView.removeFromSuperview()
            }
        }
        moveLayer.add(moveAnimation, forKey: "move")
    }

    @objc func clicked(tapgesture: UITapGestureRecognizer) {
        let touchPoint = tapgesture.location(in: self)
        let views = self.subviews
        // 倒序, 从最上层view找起
        for viewTuple in views.enumerated().reversed() {
            // 销毁界面外的红包
            if let yIndex = viewTuple.element.layer.presentation()?.frame.origin.y, yIndex > self.frame.height || yIndex < -(viewTuple.element.frame.size.height + viewTuple.element.frame.size.width)/4 {
                viewTuple.element.removeFromSuperview()
            }
            // 判断界面内的红包的点击事件
            if viewTuple.element.layer.presentation()?
                .hitTest(touchPoint) != nil {
                if viewTuple.element.tag == redPackCompomentTag {
                    // 点到的是红包,马上结束
                    redPackClickedCount += 1
                    clickHandle?(self, viewTuple.element)
                    return
                } else {
                    // 没开启点击穿透 或 点击 view 在不穿透列表中，则阻断点击
                    if !clickPenetrateEnable || viewTuple.element.tag == notPenetrateTag {
                        return
                    }
                }
            }
        }
    }
}
