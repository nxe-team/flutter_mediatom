//
//  FlutterMediatomUtil.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

class FlutterMediatomUtil {
    // 屏幕宽
    static var screenWidth: CGFloat { UIScreen.main.bounds.size.width }

    // 获取 UIViewController
    static var VC: UIViewController {
        let viewController = UIApplication.shared.windows.filter { w -> Bool in
            w.isHidden == false
        }.first?.rootViewController
        return viewController!
    }
}
