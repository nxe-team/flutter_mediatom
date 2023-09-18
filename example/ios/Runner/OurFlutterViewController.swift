//
//  OurFlutterViewController.swift
//  Runner
//
//  Created by Anand on 2023/9/18.
//

import Flutter
import Foundation

class OurFlutterViewController: FlutterViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 有其他 UIViewController 在展示
        // 如：穿山甲不喜欢页 使用新的 UIViewController 展示
        if presentedViewController != nil {
            return
        }

        // 百度联盟广告不喜欢页 展示在传入的 UIViewController
        if String(describing: view.subviews.last).contains("AdDislikeView") {
            return
        }

        super.touchesBegan(touches, with: event)
    }
}
