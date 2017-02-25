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
import MediaLibrary

let EntityName_CoordinateInfo = "CoordinateInfo"


extension CoordinateInfo : MKAnnotation{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((self.latitude?.doubleValue)!, (self.longitude?.doubleValue)!)
    }
    
    // MARK: -
    func updatePlacemark() {
        CLGeocoder.init().reverseGeocodeLocation(CLLocation.init(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)) { (placemarks, error) in
            if error == nil{
                
                if let placemark = placemarks?.last{
                    self.reverseGeocodeSucceed = NSNumber.init(value: true)
                    
                    self.name_Placemark = placemark.name
                    self.ccISOcountryCode_Placemark = placemark.isoCountryCode
                    self.country_Placemark = placemark.country;
                    self.postalCode_Placemark = placemark.postalCode;
                    self.administrativeArea_Placemark = placemark.administrativeArea;
                    self.subAdministrativeArea_Placemark = placemark.subAdministrativeArea;
                    self.locality_Placemark = placemark.locality;
                    self.subLocality_Placemark = placemark.subLocality;
                    self.thoroughfare_Placemark = placemark.thoroughfare;
                    self.subThoroughfare_Placemark = placemark.subThoroughfare;
                    self.inlandWater_Placemark = placemark.inlandWater;
                    self.ocean_Placemark = placemark.ocean;
                    
                    self.localizedPlaceString_Placemark = placemark.localizedPlaceString(inReverseOrder: true, withInlandWaterAndOcean: false)
                    
                    print(self.localizedPlaceString_Placemark)
                }
                
            }else{
                self.reverseGeocodeSucceed = NSNumber.init(value: false)
            }
            
            try! self.managedObjectContext?.save()
        }
    }

}

extension MediaInfo : MKAnnotation,GCLocationAnalyserProtocol{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return (self.coordinateInfo?.coordinate)!
    }
    
    var location: CLLocation{
        return CLLocation.init(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
}


class MAMCoreDataManager: NSObject {
    
    class var latestModificationDate: Date{
        get{
            if let md = NSUserDefaultsController.shared().defaults.value(forKey: "latestModificationDate"){
                return md as! Date
            }else{
                return Date.init(timeIntervalSince1970: 0.0)
            }
        }
        set{
            NSUserDefaultsController.shared().defaults.setValue(newValue, forKey: "latestModificationDate")
            NSUserDefaultsController.shared().defaults.synchronize()
        }
    }
    
    // MARK: - Utilities
    
    /// Helps to make sure the media object is the photo format we want.
    class func isValidImage(_ mediaObject: MLMediaObject) -> Bool{
        var isValidImage = false
        
        let attrs = mediaObject.attributes
        let contentTypeStr = attrs[MLMediaObjectHiddenAttributeKeys.contentTypeKey] as! String
        
        // We only want photos, not movies or older PICT formats (PICT image files are not supported in a sandboxed environment).
        if ((contentTypeStr != kUTTypePICT as String) && (contentTypeStr != kUTTypeQuickTimeMovie as String)){
            
            if let latitudeNumber = attrs[MLMediaObjectHiddenAttributeKeys.latitudeKey]{
                if let longitudeNumber = attrs[MLMediaObjectHiddenAttributeKeys.longitudeKey]{
                    let latitude = (latitudeNumber as! NSNumber).doubleValue
                    let longitude = (longitudeNumber as! NSNumber).doubleValue
                    if (latitude > -90 && latitude < 90 && latitude != 0 && longitude > -180 && longitude < 180 && longitude != 0){
                        print(MAMCoreDataManager.imageTitle(from: mediaObject),latitude,longitude)
                        
                        /*
                         if let Places = attrs[MLMediaObjectHiddenAttributeKeys.PlacesKey]{
                         print(Places)
                         }
                         
                         if let Name = attrs[MLMediaObjectHiddenAttributeKeys.NameKey]{
                         print(Name)
                         }
                         */
                        
                        if let DateAsTimerInterval = attrs[MLMediaObjectHiddenAttributeKeys.DateAsTimerIntervalKey]{
                            print(DateAsTimerInterval)
                            isValidImage = true
                        }
                        
                        if let FaceList = attrs[MLMediaObjectHiddenAttributeKeys.FaceListKey]{
                            print(FaceList)
                            let array = FaceList as! NSArray
                            let dic = array.firstObject as! NSDictionary
                            
                            let faceKey = dic["faceKey"] as! String
                            print(faceKey)
                            
                            let faceTileImageURL = dic["faceTileImageURL"] as! NSURL
                            print(faceTileImageURL.absoluteString!)
                            
                            let index = dic["index"] as! NSNumber
                            print(index)
                            
                            let name = dic["name"] as! String
                            print(name)
                            
                            let rectangle = dic["rectangle"] as! String
                            print(rectangle)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        return isValidImage
    }
    
    /// Obtains the title of the MLMediaObject (either the meta name or the last component of the URL).
    class func imageTitle(from mediaObject: MLMediaObject) -> String {
        guard let title = mediaObject.attributes["name"] else {
            return mediaObject.url!.lastPathComponent
        }
        return title as! String
    }

    class func updateCoreData(from mediaObjects:[MLMediaObject]){
        var validMediaObjects = [MLMediaObject]()
        //var latestModificationDate : Date?
        
        let latestMD = self.latestModificationDate
        var newLatestMD: Date = latestMD
        for mediaObject in mediaObjects {
            if let currentMD = mediaObject.modificationDate{
                if currentMD.compare(latestMD) == ComparisonResult.orderedDescending {
                    if (MAMCoreDataManager.isValidImage(mediaObject)){
                        validMediaObjects.append(mediaObject)
                    }
                }
                
                if currentMD.compare(newLatestMD) == ComparisonResult.orderedDescending{
                    newLatestMD = currentMD
                }
            }
        }
        
        // 更新所有照片的最新导入日期
        self.latestModificationDate = newLatestMD
        
        var keyArray : [String] = []
        
        for aMO in validMediaObjects {
            for aKey in aMO.attributes.keys {
                if !keyArray.contains(aKey) {
                    keyArray.append(aKey)
                }
            }
        }
        
        print(keyArray)
        
        print("本次更新照片数量：\(validMediaObjects.count)")
        
        var addCoordinateInfoCount = 0
        var addMediaInfoCount = 0
        
        for mediaObject in validMediaObjects {
            let latitude = mediaObject.attributes[MLMediaObjectHiddenAttributeKeys.latitudeKey] as! NSNumber
            let longitude = mediaObject.attributes[MLMediaObjectHiddenAttributeKeys.longitudeKey] as! NSNumber
            
            var currentCoordInfo : CoordinateInfo?
            
            let exitsCoordInfo = appContext.coordinateInfos.first(where: { $0.latitude == latitude && $0.longitude == longitude })
            if exitsCoordInfo == nil{
                let newCoordInfo = appContext.coordinateInfos.create()
                newCoordInfo.latitude = latitude
                newCoordInfo.longitude = longitude
                addCoordinateInfoCount += 1
                
                currentCoordInfo = newCoordInfo
            }else{
                currentCoordInfo = exitsCoordInfo
            }
            
            let exitsMediaInfo = appContext.mediaInfos.first(where: { $0.identifier == mediaObject.identifier })
            if exitsMediaInfo == nil{
                let newMediaInfo = appContext.mediaInfos.create()
                
                newMediaInfo.coordinateInfo = currentCoordInfo
                
                newMediaInfo.identifier = mediaObject.identifier
                newMediaInfo.contentType = mediaObject.contentType
                //newMediaInfo.faceListArray = NSData.ini (mediaObject.attributes[MLMediaObjectHiddenAttributeKeys.FaceListKey] as! NSArray)
                newMediaInfo.fileSize = Int64(mediaObject.fileSize)
                newMediaInfo.mediaSourceIdentifier = mediaObject.mediaSourceIdentifier
                newMediaInfo.mediaType = Int16(mediaObject.mediaType.rawValue)
                newMediaInfo.name = mediaObject.name
                newMediaInfo.originalURLString = mediaObject.originalURL?.absoluteString
                newMediaInfo.thumbnailURLString = mediaObject.thumbnailURL?.absoluteString
                newMediaInfo.urlString = mediaObject.url?.absoluteString
                newMediaInfo.modificationDate = mediaObject.modificationDate as NSDate?
                
                let attrs = mediaObject.attributes
                
                if let DateAsTimerInterval = attrs[MLMediaObjectHiddenAttributeKeys.DateAsTimerIntervalKey]{
                    newMediaInfo.creationDate = NSDate.init(timeIntervalSinceReferenceDate: DateAsTimerInterval as! TimeInterval)
                }
                
                addMediaInfoCount += 1
            }
        }
        
        do {
            try appContext.save()
            print("添加结果:")
            print("New CoordinateInfo Count: \(addCoordinateInfoCount)")
            print("New MediaInfo Count: \(addMediaInfoCount)")
            print("CoordinateInfo Count: \(appContext.coordinateInfos.count())")
            print("MediaInfo Count: \(appContext.mediaInfos.count())")
            
        } catch  {
            print("添加失败!")
        }


    }
    
    // MARK: - 
    class func asyncUpdatePlacemarks() -> Void {
        DispatchQueue.global(qos: .default).async{
            let coordinateInfos = appContext.coordinateInfos
            for coordinateInfo in coordinateInfos{
                if coordinateInfo.reverseGeocodeSucceed?.boolValue == false{
                    coordinateInfo.updatePlacemark()
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }
        }
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
