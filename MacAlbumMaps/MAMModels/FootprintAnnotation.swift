//
//  FootprintAnnotation.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/23.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa
import MapKit


/// 足迹点
class FootprintAnnotation: NSObject,MKAnnotation,NSCoding,GCLocationAnalyserProtocol{
    
    /// 必需，coordinateWGS84
    var coordinateWGS84: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
    
    /// 必需，开始时间
    var startDate: Date = Date.init(timeIntervalSinceNow: 0.0)
    
    /// 结束时间
    var endDate: Date?
    
    /// 高度
    var altitude: CLLocationDistance = 0.0
    
    /// 速度
    var speed: CLLocationSpeed = 0.0
    
    /// 自定义标题，如果为空，则返回title
    var customTitle: String{
        get{
            if self.customTitle.isEmpty {
                if self.title != nil{
                    return self.title!
                }else{
                    return ""
                }
            }else{
                return self.customTitle
            }
        }
        set{
            self.customTitle = newValue
        }
    }
    
    /// 标记该FootprintAnnotation是否为用户手动添加，主要用于记录和编辑
    var isUserManuallyAdded: Bool = false
    
    /// 缩略图数组
    var thumbnailArray = [NSImage]()
    
    // MARK: - MKAnnotation
    var coordinate: CLLocationCoordinate2D{
        return self.coordinateWGS84
    }
    
    var title: String?{
        return self.customTitle
    }
    
    var subtitle: String?{
        return ""
    }
    
    // MARK: - GCLocationAnalyserProtocol
    var location: CLLocation{
        return CLLocation.init(latitude: self.coordinateWGS84.latitude, longitude: self.coordinateWGS84.longitude)
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }

}
