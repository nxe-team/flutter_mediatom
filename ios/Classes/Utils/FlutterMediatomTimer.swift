//
//  FlutterMediatomTimer.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/18.
//

import Foundation

typealias GCDTask = (_ cancel: Bool) -> ()

// See https://gist.github.com/wellcheng/00afd6a16b33bf17b6db5dfd6255ce18
class FlutterMediatomTimer: NSObject {
    @discardableResult static func delay(_ time: TimeInterval, task: @escaping () -> ()) -> GCDTask? {
        func dispatch_later(block: @escaping () -> ()) {
            let t = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (() -> ())? = task
        var result: GCDTask?
        
        let delayedClosure: GCDTask = {
            cancel in
            if let closure = closure {
                if !cancel {
                    DispatchQueue.main.async(execute: closure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let result = result {
                result(false)
            }
        }
        
        return result
    }
    
    static func cancel(_ task: GCDTask?) {
        task?(true)
    }
}
