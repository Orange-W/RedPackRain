//
//  ViewController.swift
//  RedPackRain
//
//  Created by Orange on 2018/4/11.
//  Copyright © 2018年 Orange. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    let redPackRain = RedpackRainView()
    let closeButton = UIButton()
    let redpackSoundUrl = "hit.mp3"
    var redpackSoundId: SystemSoundID = 0
    let bombSoundUrl = "boom.mp3"
    var bombSoundId: SystemSoundID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(redPackRain)
        redPackRain.frame = self.view.bounds
        // 准备点击音乐
        prepareSound()

        // 初始化红包雨
        redPackRain.setRedPack(images:
            [UIImage.init(named: "下载1.png")!], size: CGSize.init(width: 100, height: 100)) { (redPackView, clickview) in

                guard let layer = clickview.layer.presentation() else {
                    return
                }
                // 点击音效
                self.playHitSound()
                // 点击后替换图片
                let newRedPack = UIImageView()
                newRedPack.image = UIImage(named: "下载.jpeg")
                newRedPack.bounds = clickview.bounds
                newRedPack.center = CGPoint(x: layer.frame.origin.x + layer.frame.width/2, y: layer.frame.origin.y + layer.frame.height/2)
                newRedPack.transform = layer.affineTransform()
                redPackView.addNotPenetrateViews(views: [newRedPack])
                redPackView.addSubview(newRedPack)
                // 只显示0.3秒
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                    newRedPack.removeFromSuperview()
                })

                print("累计\(redPackView.redPackClickedCount)个红包")
                clickview.removeFromSuperview()
//                // 每点一个红包加大难度
//                redPackView.redPackDropDownTime = redPackView.redPackDropDownTime * 0.95
//                redPackView.redPackIntervalTime = redPackView.redPackIntervalTime *  0.95
        }

        // 红包雨结束回调
        redPackRain.setCompleteHandle { (redPackView) in
            print("一共点中了\(redPackView.redPackClickedCount)个红包")
        }

        // 红包出现时添加旋转动画
        redPackRain.setRedPackAppearHandle { (redpackView, count) in
            self.rollAnimation(view: redpackView)
        }

        // 初始化炸弹
        redPackRain.setBomb(images: [UIImage.init(named: "bomb.jpg")!], size: CGSize.init(width: 250, height: 191), density: 8) { (redPackRainView, bomb) in
            bomb.removeFromSuperview()
            self.playBombSound()
            print("点了个炸弹")
        }
        // 旋转动画
        redPackRain.setBombAppearHandle { (bomb, count) in
            self.rollAnimation(view: bomb)
        }

        do { // 右上角关闭按钮
            closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
            closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: 0, width: 60, height: 60)
            closeButton.backgroundColor = .blue
            closeButton.setTitle("点我", for: .normal)
            redPackRain.addSubview(closeButton)
        }
    }

    @objc func closeClick() {
        if closeButton.tag == 0 {
            closeButton.tag = 1
            // 暂停与时间倒流
//            redPackRain.stopRain()
            redPackRain.timeBackRain()
            closeButton.backgroundColor = .red
        } else {
            closeButton.tag = 0
            redPackRain.continueRain()
            closeButton.backgroundColor = .green
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        redPackRain.startGame()
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

    /// 准备音效
    func prepareSound() {
        let url = Bundle.init(for: self.classForCoder).url(forResource: redpackSoundUrl, withExtension: nil)
        AudioServicesCreateSystemSoundID(url! as CFURL, &redpackSoundId)

        let url2 = Bundle.init(for: self.classForCoder).url(forResource: bombSoundUrl, withExtension: nil)
        AudioServicesCreateSystemSoundID(url2! as CFURL, &bombSoundId)
    }

    // 红包点击音效
    func playHitSound() {
        AudioServicesPlaySystemSound(redpackSoundId)
    }

    // 炸弹点击音效
    func playBombSound() {
        AudioServicesPlaySystemSound(bombSoundId)
    }

    deinit {
        // 回收
        AudioServicesDisposeSystemSoundID(redpackSoundId)
        AudioServicesDisposeSystemSoundID(bombSoundId)
    }
}

