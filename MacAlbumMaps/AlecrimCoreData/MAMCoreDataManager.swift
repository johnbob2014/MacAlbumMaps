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


/// 地址信息数据字典键
enum PlacemarkInfoDictionaryKey : String {
    case kCountryArray = "kCountryArray"
    case kAdministrativeAreaArray = "kAdministrativeAreaArray"
    case kSubAdministrativeAreaArray = "kSubAdministrativeAreaArray"
    case kLocalityArray = "kLocalityArray"
    case kSubLocalityArray = "kSubLocalityArray"
    case kThoroughfareArray = "kThoroughfareArray"
    case kSubThoroughfareArray = "kSubThoroughfareArray"
}

//MARK: - 扩展
extension CoordinateInfo : MKAnnotation{
    
    // MARK: - MKAnnotation Protocol
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((self.latitude?.doubleValue)!, (self.longitude?.doubleValue)!)
    }
    
    // MARK: -
    func updatePlacemark(geocoder: CLGeocoder) {
        geocoder.reverseGeocodeLocation(CLLocation.init(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)) { (placemarks, error) in
            if error == nil{
                
                if let placemark = placemarks?.last{
                    
                    
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
                    
                    self.localizedPlaceString_Placemark = placemark.localizedPlaceString(inReverseOrder: false, withInlandWaterAndOcean: false)
                    
                    print(self.localizedPlaceString_Placemark!)
                    self.reverseGeocodeSucceed = NSNumber.init(value: true)
                    try! appContext.save()
                }
                
            }else{
                self.reverseGeocodeSucceed = NSNumber.init(value: false)
            }
            
            //try! self.managedObjectContext?.save()
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

//MARK: - CoreData管理器
class MAMCoreDataManager: NSObject {
    
    
    // MARK: - MLMediaObject验证及更新
    
    /// 所有已更新照片的最晚一个导入到Mac的日期
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
    
    /// 验证数据
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
    
    /// 获取 MLMediaObject 的名字
    /// Obtains the title of the MLMediaObject (either the meta name or the last component of the URL).
    class func imageTitle(from mediaObject: MLMediaObject) -> String {
        guard let title = mediaObject.attributes["name"] else {
            return mediaObject.url!.lastPathComponent
        }
        return title as! String
    }

    /// 从指定的 MLMediaObject数组 中获取数据
    ///
    /// - Parameter mediaObjects: MLMediaObject数组
    class func updateCoreData(from mediaObjects:[MLMediaObject]){
        var validMediaObjects = [MLMediaObject]()
        
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
            print("Total CoordinateInfo Count: \(appContext.coordinateInfos.count())")
            print("Total MediaInfo Count: \(appContext.mediaInfos.count())")
        } catch  {
            print("添加失败!")
        }
    }
    
    // MARK: - 地址信息解析工具
    
    /// 更新CoordinateInfo的Placemark
    class func asyncUpdatePlacemarks() -> Void {
        DispatchQueue.global(qos: .default).async{
            let geocoder = CLGeocoder.init()
            let coordinateInfos = appContext.coordinateInfos.filter(){ $0.reverseGeocodeSucceed?.boolValue == false }
            let total = coordinateInfos.count
            for (index,coordinateInfo) in coordinateInfos.enumerated(){
                print("Parsing:\(index+1)/\(total)")
                coordinateInfo.updatePlacemark(geocoder: geocoder)
                Thread.sleep(forTimeInterval: 1.0)

//                if coordinateInfo.reverseGeocodeSucceed?.boolValue == false{
//                                    }
            }
            
        }
    }
    
    
    /// 统计一个 CoordinateInfo数组 的 地址信息数据
    ///
    /// - Parameter coordinateInfos: CoordinateInfo数组
    /// - Returns: 地址信息数据字典，只包含名称数组，不包含层级
    class func placemarkInfoDictionary(coordinateInfos: [CoordinateInfo]) -> Dictionary<PlacemarkInfoDictionaryKey, [String]> {
        var countryArray = [String]()
        var administrativeAreaArray = [String]()
        var subAdministrativeAreaArray = [String]()
        var localityArray = [String]()
        var subLocalityArray = [String]()
        var thoroughfareArray = [String]()
        var subThoroughfareArray = [String]()
        
        
        for info in coordinateInfos{
            if let country_Placemark = info.country_Placemark {
                if !countryArray.contains(country_Placemark){
                    countryArray.append(country_Placemark)
                }
            }
            
            if let administrativeArea_Placemark = info.administrativeArea_Placemark{
                if !administrativeAreaArray.contains(administrativeArea_Placemark){
                    administrativeAreaArray.append(administrativeArea_Placemark)
                }
            }
            
            if let subAdministrativeArea_Placemark = info.subAdministrativeArea_Placemark{
                if !subAdministrativeAreaArray.contains(subAdministrativeArea_Placemark){
                    subAdministrativeAreaArray.append(subAdministrativeArea_Placemark)
                }
            }
            
            if let locality_Placemark = info.locality_Placemark{
                if !localityArray.contains(locality_Placemark){
                    localityArray.append(locality_Placemark)
                }
            }
            
            if let subLocality_Placemark = info.subLocality_Placemark{
                if !subLocalityArray.contains(subLocality_Placemark){
                    subLocalityArray.append(subLocality_Placemark)
                }
            }
            
            if let thoroughfare_Placemark = info.thoroughfare_Placemark{
                if !thoroughfareArray.contains(thoroughfare_Placemark){
                    thoroughfareArray.append(thoroughfare_Placemark)
                }
            }
            
            if let subThoroughfare_Placemark = info.subThoroughfare_Placemark{
                if !subThoroughfareArray.contains(subThoroughfare_Placemark){
                    subThoroughfareArray.append(subThoroughfare_Placemark)
                }
            }
        }
        
        let countryTN = NSTreeNode.init(representedObject: countryArray)
        print(countryTN.children!)
        print(countryTN.representedObject!)

        return [.kCountryArray:countryArray,
                .kAdministrativeAreaArray:administrativeAreaArray,
                .kSubAdministrativeAreaArray:subAdministrativeAreaArray,
                .kLocalityArray:localityArray,
                .kSubLocalityArray:subLocalityArray,
                .kThoroughfareArray:thoroughfareArray,
                .kSubThoroughfareArray:subThoroughfareArray]
    }
    
    /// 统计一个 MediaInfo数组 的 地址信息数据
    ///
    /// - Parameter mediaInfos: MediaInfo数组
    /// - Returns: 地址信息数据字典，只包含名称数组，不包含层级
    class func placemarkInfoDictionary(mediaInfos: [MediaInfo]) -> Dictionary<PlacemarkInfoDictionaryKey, [String]> {
        var coordinateInfos = [CoordinateInfo]()
        for mediaInfo in mediaInfos {
            if let coordinateInfo = mediaInfo.coordinateInfo{
                coordinateInfos.append(coordinateInfo)
            }
        }
        return MAMCoreDataManager.placemarkInfoDictionary(coordinateInfos: coordinateInfos)
    }

    
    /// 统计一个 CoordinateInfo数组 的 地址信息数据
    ///
    /// - Parameter coordinateInfos: CoordinateInfo数组
    /// - Returns: 地址信息数据字典，包含层级，格式为 ["国家": ["省": ["市": ["县区": ["村镇街道": 村镇街道个数]]]]]
    class func placemarkHierarchicalInfoDictionary(coordinateInfos: [CoordinateInfo]) -> Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Int>>>>> {
        var countryDic = Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Int>>>>>()
        
        for info in coordinateInfos{
            if let country_Placemark = info.country_Placemark {
                if nil == countryDic[country_Placemark]{
                    // 如果不存在这个国家，创建一个
                    countryDic[country_Placemark] = Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Int>>>>()
                }
                
                if let administrativeArea_Placemark = info.administrativeArea_Placemark{
                    if nil == countryDic[country_Placemark]![administrativeArea_Placemark]{
                        // 如果不存在这个省，创建一个
                        countryDic[country_Placemark]![administrativeArea_Placemark] = Dictionary<String, Dictionary<String, Dictionary<String, Int>>>()
                    }
                    
                    if let locality_Placemark = info.locality_Placemark{
                        if nil == countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]{
                            // 如果不存在这个市，创建一个
                             countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark] = Dictionary<String, Dictionary<String, Int>>()
                        }
                        
                        if let subLocality_Placemark = info.subLocality_Placemark{
                            if nil == countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]![subLocality_Placemark]{
                                // 如果不存在这个县区，创建一个
                                countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]![subLocality_Placemark] = Dictionary<String, Int>()
                            }
                            
                            if let thoroughfare_Placemark = info.thoroughfare_Placemark{
                                if let thoroughfareCount = countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]![subLocality_Placemark]![thoroughfare_Placemark]{
                                    // 已经包含这个村镇街道，令这个的村镇街道的个数加1
                                    countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]![subLocality_Placemark]![thoroughfare_Placemark] = thoroughfareCount + 1
                                }else{
                                    // 创建一个村镇街道，并将其个数设为1
                                    countryDic[country_Placemark]![administrativeArea_Placemark]![locality_Placemark]![subLocality_Placemark]![thoroughfare_Placemark] = 1
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return countryDic
    }
    
    /// 统计一个 MediaInfo数组 的 地址信息数据
    ///
    /// - Parameter mediaInfos: MediaInfo数组
    /// - Returns: 地址信息数据字典，包含层级，格式为 ["国家": ["省": ["市": ["县区": ["村镇街道": 村镇街道个数]]]]]
    class func placemarkHierarchicalInfoDictionary(mediaInfos: [MediaInfo]) -> Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Int>>>>> {
        var coordinateInfos = [CoordinateInfo]()
        for mediaInfo in mediaInfos {
            if let coordinateInfo = mediaInfo.coordinateInfo{
                coordinateInfos.append(coordinateInfo)
            }
        }
        return MAMCoreDataManager.placemarkHierarchicalInfoDictionary(coordinateInfos: coordinateInfos)
    }
    
    
    /// 根据 地址信息数据字典，包含层级 生成 可用于NSOutlineView的GCTreeNode
    ///
    /// - Parameter placemarkHierarchicalInfoDictionary: 地址信息数据字典，包含层级
    /// - Returns: 可用于NSOutlineView的GCTreeNode
    class func placemarkHierarchicalInfoTreeNode(placemarkHierarchicalInfoDictionary: Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Dictionary<String, Int>>>>>) -> GCTreeNode{
        let rootTreeNode = GCTreeNode()
        rootTreeNode.isTop = true
        rootTreeNode.title = NSLocalizedString("全部", comment: "")
        
        for (countryTitle,countryDic) in placemarkHierarchicalInfoDictionary{
            let countryTN = GCTreeNode()
            countryTN.parent = rootTreeNode
            countryTN.title = countryTitle
            
            for (administrativeAreaTitle,administrativeAreaDic) in countryDic {
                let administrativeAreaTN = GCTreeNode()
                administrativeAreaTN.parent = countryTN
                administrativeAreaTN.title = administrativeAreaTitle
                
                for (localityTitle,localityDic) in administrativeAreaDic {
                    let localityTN = GCTreeNode()
                    localityTN.parent = administrativeAreaTN
                    localityTN.title = localityTitle
                    
                    for (subLocalityTitle,subLocalityDic) in localityDic {
                        let subLocalityTN = GCTreeNode()
                        subLocalityTN.parent = localityTN
                        subLocalityTN.title = subLocalityTitle
                        
                        for (thoroughfareTitle,thoroughfareCount) in subLocalityDic {
                            let thoroughfareTN = GCTreeNode()
                            thoroughfareTN.parent = subLocalityTN
                            thoroughfareTN.title = thoroughfareTitle
                            
                            thoroughfareTN.isLeaf = true
                            thoroughfareTN.representedObject = thoroughfareCount
                            
                            subLocalityTN.children.append(thoroughfareTN)
                        }
                        
                        localityTN.children.append(subLocalityTN)
                    }
                    
                    administrativeAreaTN.children.append(localityTN)
                }
                
                countryTN.children.append(administrativeAreaTN)
            }
            
            rootTreeNode.children.append(countryTN)
        }
        
        return rootTreeNode
    }
    
    
    /// 根据 CoordinateInfo数组 生成 可用于NSOutlineView的GCTreeNode
    ///
    /// - Parameter coordinateInfos: CoordinateInfo数组
    /// - Returns: 可用于NSOutlineView的GCTreeNode
    class func placemarkHierarchicalInfoTreeNode(coordinateInfos: [CoordinateInfo]) -> GCTreeNode{
        return MAMCoreDataManager.placemarkHierarchicalInfoTreeNode(placemarkHierarchicalInfoDictionary: MAMCoreDataManager.placemarkHierarchicalInfoDictionary(coordinateInfos: coordinateInfos))
    }
    
    /// 根据 MediaInfo数组 生成 可用于NSOutlineView的GCTreeNode
    ///
    /// - Parameter mediaInfos: MediaInfo数组
    /// - Returns: 可用于NSOutlineView的GCTreeNode
    class func placemarkHierarchicalInfoTreeNode(mediaInfos: [MediaInfo]) -> GCTreeNode{
        return MAMCoreDataManager.placemarkHierarchicalInfoTreeNode(placemarkHierarchicalInfoDictionary: MAMCoreDataManager.placemarkHierarchicalInfoDictionary(mediaInfos: mediaInfos))
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
