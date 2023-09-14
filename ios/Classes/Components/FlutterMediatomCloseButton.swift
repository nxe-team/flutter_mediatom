//
//  FlutterMediatomCloseButton.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/14.
//

import Foundation

// 关闭按钮
class FlutterMediatomCloseButton: UIButton {
    init() {
        super.init(frame: CGRectMake(FlutterMediatomUtil.screenWidth - 30, 10, 20, 20))
        setTitle("X", for: UIControl.State.normal)
        setTitleColor(UIColor.gray, for: UIControl.State.normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
