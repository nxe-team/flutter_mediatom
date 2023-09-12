//
//  FlutterMediatomUtil.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

class FlutterMediatomUtil {
    // 获取 UIViewController
    static func getVC() -> UIViewController {
        let viewController = UIApplication.shared.windows.filter { w -> Bool in
            w.isHidden == false
        }.first?.rootViewController
        return viewController!
    }
}
