//
//  MAMSettingManager.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/23.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa

/// 地图基础模式
///
/// - Moment: 时刻模式
/// - Location: 地点模式
enum MapBaseMode: Int {
    case Moment = 0
    case Location
}

/// 地图扩展模式
///
/// - Browser: 浏览模式
/// - Record: 记录模式
enum MapExtendedMode: Int {
    case Browser = 0
    case Record
}

class MAMSettingManager: NSObject {
    /// 是否曾经登陆
    class var everLaunched: Bool{
        get{
            if let ever = NSUserDefaultsController.shared().defaults.value(forKey: "everLaunched"){
                return ever as! Bool
            }else{
                return false
            }
        }
        set{
            NSUserDefaultsController.shared().defaults.setValue(newValue, forKey: "everLaunched")
            NSUserDefaultsController.shared().defaults.synchronize()
        }
    }
}
