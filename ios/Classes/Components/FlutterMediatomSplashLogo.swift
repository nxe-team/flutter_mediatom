//
//  FlutterMediatomSplashLogo.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

// 开屏广告 Logo
class FlutterMediaSplashLogo: UIView {
    private var imageName: String

    init(name: String) {
        imageName = name
        let screenSize: CGSize = UIScreen.main.bounds.size
        super.init(frame: CGRect(
            x: 0,
            y: 0,
            width: screenSize.width,
            height: screenSize.height * 0.15
        ))
        backgroundColor = UIColor.white
        addLogo()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLogo() {
        let image: UIView = UIImageView(image: UIImage(named: imageName))
        image.contentMode = UIView.ContentMode.center
        image.center = center
        addSubview(image)
    }
}
