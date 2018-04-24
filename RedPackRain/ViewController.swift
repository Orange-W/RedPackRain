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
    let closeButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(redPackRain)
        redPackRain.frame = self.view.bounds
        redPackRain.setRedPack(images:
            [UIImage.init(named: "redpack1.jpeg")!,
             UIImage.init(named: "redpack2.jpeg")!,
             UIImage.init(named: "redpack3.jpeg")!], size: CGSize.init(width: 100, height: 100)) { (redPackView, clickview) in
                
                print("累计\(redPackView.redPackClickedCount)个红包")
                clickview.removeFromSuperview()
                redPackView.redPackDropDownTime = redPackView.redPackDropDownTime * 0.95
                redPackView.redPackIntervalTime = redPackView.redPackIntervalTime *  0.95
        }
        redPackRain.setCompleteHandle { (redPackView) in
            print("一共点中了\(redPackView.redPackClickedCount)个红包")
        }

        redPackRain.setRedPackAppearHandle { (redpackView, count) in
            self.rollAnimation(view: redpackView)
        }

        redPackRain.setBomb(images: [UIImage.init(named: "bomb.jpg")!], size: CGSize.init(width: 250, height: 191), density: 8) { (redPackRainView, bomb) in
            print("点了个炸弹")
        }

        redPackRain.setBombAppearHandle { (bomb, count) in
            self.rollAnimation(view: bomb)
        }

        do { // 右上角关闭按钮
            closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
            closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 30, y: 0, width: 30, height: 30)
            closeButton.backgroundColor = .blue
            redPackRain.addSubview(closeButton)
        }
    }

    @objc func closeClick() {
        if closeButton.tag == 0 {
            closeButton.tag = 1
            redPackRain.stopRain()
            closeButton.backgroundColor = .red
        } else {
            closeButton.tag = 0
            redPackRain.restartRain()
            closeButton.backgroundColor = .green
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        redPackRain.beginToRain()
    }

    func rollAnimation(view: UIView) {
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
        view.layer.add(rotationAnim, forKey: nil)
    }
}

