//
//  MAMCoreDataAssistant.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/17.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

let EntityName_CoordinateInfo = "CoordinateInfo"

extension CoordinateInfo : MKAnnotation{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((self.latitude?.doubleValue)!, (self.longitude?.doubleValue)!)
    }

}

extension MediaInfo : MKAnnotation{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return (self.coordinateInfo?.coordinate)!
    }
    
}
/*
extension CoordinateInfo : MKAnnotation{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((self.latitude?.doubleValue)!, (self.longitude?.doubleValue)!)
    }
    
    // MARK: - Core Data
    class func truncatedValue(_ aValue:Double) -> Double {
        let truncateBase : Double = pow(10, 10)
        return floor(aValue * truncateBase) / truncateBase
    }
    
    class func fetch(_ latitude:Double , _ longitude:Double) -> CoordinateInfo? {
        var info:CoordinateInfo?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: EntityName_CoordinateInfo)
        // 查找时，对参数值进行截取
        fetchRequest.predicate = NSPredicate.init(format: "(latitude = %@) && (longitude = %@)", NSNumber.init(value: CoordinateInfo.truncatedValue(latitude)),NSNumber.init(value: CoordinateInfo.truncatedValue(longitude)))
        
        do {
            let matches = try appContext.fetch(fetchRequest)
            if matches.count >= 1 {
                info = matches.first as? CoordinateInfo
            }
            
        } catch {
            
        }
        
        return info;
    }
    
    class func fetchAll() -> [CoordinateInfo]?{
        var matches : [CoordinateInfo]?
        
        let fetchRequest = NSFetchRequest<CoordinateInfo>(entityName: EntityName_CoordinateInfo)
        do {
            matches = try appContext.fetch(fetchRequest)
        } catch  {
            
        }
        
        if matches?.count == 0 {
            print("No CoordinateInfo Yet!")
        }
        
        return matches
    }
    
    class func deleteAll(){
        if let all = CoordinateInfo.fetchAll(){
            for info in all {
                appContext.delete(info)
            }
            
            do {
                try appContext.save()
                print("save ok")
            } catch  {
                print("save error")
            }

        }
        
    }
    
    class func create(_ latitude:Double , _ longitude:Double) -> CoordinateInfo{
        if let fetchInfo = CoordinateInfo.fetch(latitude, longitude){
            return fetchInfo
        }else{
            let newInfo = NSEntityDescription.insertNewObject(forEntityName: EntityName_CoordinateInfo, into: appContext) as! CoordinateInfo
            
            // 赋值时，对参数值进行截取
            newInfo.latitude = NSNumber.init(value: CoordinateInfo.truncatedValue(latitude))
            newInfo.longitude = NSNumber.init(value: CoordinateInfo.truncatedValue(longitude))
            
            do {
                try appContext.save()
                print("save ok")
            } catch  {
                print("save error")
            }
            
            return newInfo;
        }

    }
    
    class func create(_ location:CLLocation) -> CoordinateInfo{
        if let fetchInfo = CoordinateInfo.fetch(location.coordinate.latitude, location.coordinate.longitude){
            return fetchInfo
        }else{
            let newInfo = NSEntityDescription.insertNewObject(forEntityName: EntityName_CoordinateInfo, into: appContext) as! CoordinateInfo
            
            // 赋值时，对参数值进行截取
            newInfo.latitude = NSNumber.init(value: CoordinateInfo.truncatedValue(location.coordinate.latitude))
            newInfo.longitude = NSNumber.init(value: CoordinateInfo.truncatedValue(location.coordinate.longitude))
            newInfo.altitude = NSNumber.init(value: location.altitude)
            
            newInfo.speed = NSNumber.init(value: location.speed)
            newInfo.course = NSNumber.init(value: location.course)
            newInfo.horizontalAccuracy = NSNumber.init(value: location.horizontalAccuracy)
            newInfo.verticalAccuracy = NSNumber.init(value: location.verticalAccuracy)
            //info.level = NSNumber.init(value: location.floor?.level)
            
            do {
                try appContext.save()
                print("save ok")
            } catch  {
                print("save error")
            }
            
            return newInfo;
        }
    }
}
*/
