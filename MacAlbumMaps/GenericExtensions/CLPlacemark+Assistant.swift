//
//  CLPlacemark+Assistant.swift
//  MacAlbumMaps
//
//  Created by 张保国 on 2017/2/25.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Foundation
import CoreLocation

extension String{
    func placemarkBriefName(separator: String = ",") -> String {
        var briefName = ""
        
        let stringArray = self.components(separatedBy: separator)
        if stringArray.count == 1 {
            briefName = stringArray.last!
        }else if stringArray.count > 1{
            let lastStr = stringArray.last!
            if lastStr.lengthOfBytes(using: String.Encoding.unicode) >= 10{
                briefName = lastStr
            }else{
                briefName = stringArray[stringArray.count - 2] + lastStr
            }
        }
        
        return briefName
    }
}

extension CLPlacemark{
    func localizedPlaceString(inReverseOrder reverseOrder: Bool,withInlandWaterAndOcean inlandWaterAndOcean: Bool,separator: String = ",") -> String {
        
        // subLocality及其之前的地址信息，以逗号分隔
        var detailLocationStringTillSubLocality = ""
        
        // 地址名称 或 街道信息
        // 如果能解析到具体地址名称，则self.name为具体地址名称，否则，为地址信息（包含街道信息）
        var trimmedNameString = ""
        if self.name != nil {
            trimmedNameString = self.name!
        }
        
        if let country = self.country{
            detailLocationStringTillSubLocality += country
            trimmedNameString = trimmedNameString.replacingOccurrences(of: country, with: "")
        }
        if let administrativeArea = self.administrativeArea{
            detailLocationStringTillSubLocality += separator + administrativeArea
            trimmedNameString = trimmedNameString.replacingOccurrences(of: administrativeArea, with: "")
        }
        if let subAdministrativeArea = self.subAdministrativeArea{
            detailLocationStringTillSubLocality += separator + subAdministrativeArea
            trimmedNameString = trimmedNameString.replacingOccurrences(of: subAdministrativeArea, with: "")
        }
        if let locality = self.locality{
            detailLocationStringTillSubLocality += separator + locality
            trimmedNameString = trimmedNameString.replacingOccurrences(of: locality, with: "")
        }
        if let subLocality = self.subLocality{
            detailLocationStringTillSubLocality += separator + subLocality
            trimmedNameString = trimmedNameString.replacingOccurrences(of: subLocality, with: "")
        }
        if let thoroughfare = self.thoroughfare{
            trimmedNameString = trimmedNameString.replacingOccurrences(of: thoroughfare, with: "")
        }
        if let subThoroughfare = self.subThoroughfare{
            trimmedNameString = trimmedNameString.replacingOccurrences(of: subThoroughfare, with: "")
        }
        
        // 全部地址信息，以逗号分隔
        var combinedDetailLocationString = ""
        
        if self.name == trimmedNameString {
            // self.name 是地点名称
            // 这时 trimmedNameString 也是 地点名称 ，稍后添加
            // 这时combinedDetailLocationString 是 地址信息，不含街道信息
            combinedDetailLocationString = detailLocationStringTillSubLocality
        }else{
            // self.name 是地址列表
            // 这时 trimmedNameString 是 街道信息 ，将其添加到地址信息中
            // 这时combinedDetailLocationString 是 地址信息，包含街道信息
            if trimmedNameString.isEmpty {
                combinedDetailLocationString = detailLocationStringTillSubLocality
            }else{
                combinedDetailLocationString = detailLocationStringTillSubLocality + separator + trimmedNameString
            }
        }
        
        if let thoroughfare = self.thoroughfare{
            combinedDetailLocationString += separator + thoroughfare
        }
        if let subThoroughfare = self.subThoroughfare{
            combinedDetailLocationString += separator + subThoroughfare
        }
        
        if self.name == trimmedNameString {
            // self.name 是地点名称
            // 在地下信息中添加地点名称
            combinedDetailLocationString += separator + trimmedNameString
        }
        
        var resultString = combinedDetailLocationString
        
        if reverseOrder{
            // 生成逆序地址
            resultString = ""
            let reversedStringArray = combinedDetailLocationString.components(separatedBy: separator).reversed()
            for (index,aStr) in reversedStringArray.enumerated() {
                resultString += aStr
                if index != reversedStringArray.count - 1 {
                    resultString += separator
                }
            }
        }
        
        if inlandWaterAndOcean{
            if let inlandWater = self.inlandWater {
                resultString += " inlandWater : " + inlandWater
            }
            if let ocean = self.ocean{
                resultString += " ocean : " + ocean
            }
        }
        
        resultString = resultString.replacingOccurrences(of: separator + separator, with: separator)
        
        return resultString
    }
    
    func areasOfInterestString(withIndex: Bool,separator: String = ",") -> String? {
        if let areasOfInterest = self.areasOfInterest{
            var resultString = ""
            for (index,interest) in areasOfInterest.enumerated() {
                // 是否带序号
                if withIndex {
                    resultString += "\(index + 1) : " + interest
                }else{
                    resultString += interest
                }
                
                // 每个兴趣点后添加,
                if index != areasOfInterest.count - 1 {
                    resultString += separator
                }
            }
            return resultString
        }else{
            return nil
        }
    }
}
