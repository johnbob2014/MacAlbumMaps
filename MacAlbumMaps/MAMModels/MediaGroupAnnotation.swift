//
//  MediaGroupAnnotation.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/23.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa
import MapKit

class MediaGroupAnnotation: NSObject , MKAnnotation{
    
    // MARK: - Properties
    
    /// 必需，location，座标为WGS84编码格式
    var location : CLLocation = CLLocation.init(latitude: 0.0, longitude: 0.0)
    
    /// 必需，Media的identifier数组
    var mediaIdentifiers = [String]()
    
    /// 可选，标题
    var annoTitle = ""
    
    /// 可选，子标题
    var annoSubtitle = ""
    
    /// 只读，计算属性，返回Media的数量
    var mediaCount : Int{
        get{
            return self.mediaIdentifiers.count
        }
    }
    
    // MARK: - MKAnnotation Delegate
    
    var coordinate: CLLocationCoordinate2D{
        return self.location.coordinate
    }
    
    var title: String?{
        return self.annoTitle
    }
    
    var subtitle: String?{
        return self.annoSubtitle
    }

}
