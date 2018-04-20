//
//  ViewController.swift
//  RedPackRain
//
//  Created by Orange on 2018/4/11.
//  Copyright © 2018年 Orange. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let redPackRain = RedPackRainView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(redPackRain)
        redPackRain.frame = self.view.bounds
        redPackRain.setRedPack(images:
            [UIImage.init(named: "redpack1.jpeg")!,
             UIImage.init(named: "redpack2.jpeg")!,
             UIImage.init(named: "redpack3.jpeg")!]) { (redPackView, clickview) in
                
                print("累计\(redPackView.redPackClickedCount)个红包")
                clickview.removeFromSuperview()
                redPackView.redPackDropDownTime = redPackView.redPackDropDownTime * 0.95
                redPackView.redPackIntervalTime = redPackView.redPackIntervalTime *  0.9
//                if let frame = clickview.layer.presentation()?.frame {
//                    clickview.frame = frame
//                }

        }
        redPackRain.setCompleteHandle { (redPackView) in
            print("一共点中了\(redPackView.redPackClickedCount)个红包")
        }

        redPackRain.setRedPackAppearHandle { (redpack, index) in
            // 1.创建动画
            let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
            // 2.设置动画的属性
            rotationAnim.fromValue = 0

            rotationAnim.toValue = (arc4random_uniform(2))>0 ? (Double.pi * 2) : (-2 * Double.pi)
            rotationAnim.repeatCount = MAXFLOAT
            rotationAnim.duration = 2
            // 这个属性很重要 如果不设置当页面运行到后台再次进入该页面的时候 动画会停止
            rotationAnim.isRemovedOnCompletion = false
            // 3.将动画添加到layer中
            redpack.layer.add(rotationAnim, forKey: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        redPackRain.beginToRain()
    }
}

