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
        }
        redPackRain.setCompleteHandle { (redPackView) in
            print("一共点中了\(redPackView.redPackClickedCount)个红包")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        redPackRain.beginToRain()
    }
}

