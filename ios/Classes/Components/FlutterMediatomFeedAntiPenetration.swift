//
//  FlutterMediatomFeedAntiPenetration.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/13.
//

import Foundation

// 信息流防穿透
class FlutterMediatomFeedAntiPenetration: UIView {
    /// 广告是否被覆盖
    var isCovered: Bool = false
    /// 广告的可见区域
    var visibleBounds: CGRect = .zero
        
    init(frame: CGRect, methodChannel: FlutterMethodChannel) {
        super.init(frame: frame)
        methodChannel.setMethodCallHandler(handle(_:result:))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateVisibleBounds":
            let args: [String: Any] = call.arguments as! [String: Any]
            isCovered = args["isCovered"] as! Bool
            visibleBounds = CGRect(
                x: args["x"] as! Double,
                y: args["y"] as! Double,
                width: args["width"] as! Double,
                height: args["height"] as! Double)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
        
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 在窗口的点击位置
        let windowPoint: CGPoint = convert(point, to: UIApplication.shared.keyWindow)
        // 被覆盖时 -> 点击位置不在可见区域
        if isCovered, !visibleBounds.contains(windowPoint) {
            return false
        } else if let overlay = getFlutterOverlayView(), overlay.frame.contains(windowPoint) {
            // 点击位置在 PlatformView 被遮盖时形成的 FlutterOverlayView 上时阻断点击穿透
            return false
        } else {
            // 不拦截
            return true
        }
    }
        
    // 获取 PlatformView 渲染的 FlutterOverlayView 视图
    // 当 PlatformView 被 Widget 覆盖时，FlutterOverlayView 会进行绘制
    private func getFlutterOverlayView() -> UIView? {
        // PlatformView 渲染后的层级：FlutterView -> ChildClippingView -> FlutterTouchInterceptingView -> 当前视图
        // FlutterOverlayView 和 ChildClippingView 同级
        if let views = superview?.superview?.superview?.subviews {
            for view in views.reversed() {
                if String(describing: view).contains("FlutterOverlayView") {
                    return view
                }
            }
        }
        return nil
    }
}
