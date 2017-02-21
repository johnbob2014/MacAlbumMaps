//
//  GCLocationAnalyser.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/20.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa
import CoreLocation

protocol GCLocationAnalyserProtocol {
    var location: CLLocation { get }
}

class GCLocationAnalyser: NSObject {
    class func divideLocationsInOrder(from sourceArray : Array<GCLocationAnalyserProtocol>,_ mergeDistance:CLLocationDistance) -> Array<Array<GCLocationAnalyserProtocol>>? {
        var currentMergeDistance = mergeDistance
        if currentMergeDistance <= 0{
            currentMergeDistance = 1_000_000 //CLLocationDistanceMax
        }
        
        if sourceArray.count == 0 {return nil}
        
        if sourceArray.count == 1 {return [sourceArray]}
        
        //var keyLocation = sourceArray.first!.location
        var previousObj = sourceArray.first!
        var tempArray:Array<GCLocationAnalyserProtocol> = [previousObj]
        var returnArray:Array<Array<GCLocationAnalyserProtocol>> = []
        var currentGroupFirstObj = sourceArray.first!
        var index:Int = 0
        for currentObj in sourceArray {
            if index > 0{
                let distanceToPrevious = fabs(previousObj.location.distance(from: currentObj.location))
                let distanceToFirst = fabs(currentGroupFirstObj.location.distance(from: currentObj.location))
                
                if distanceToPrevious < currentMergeDistance && distanceToFirst < currentMergeDistance {
                    tempArray.append(currentObj)
                }else{
                    returnArray.append(tempArray)
                    
                    // 开始下一轮计算
                    //keyLocation = currentObj.location
                    tempArray = []
                    tempArray.append(currentObj)
                    currentGroupFirstObj = currentObj
                }
                
                previousObj = currentObj
                
                if index == sourceArray.count - 1{
                    returnArray.append(tempArray)
                }
            }
            
            index += 1
        }
        
        return returnArray
    }
    
    class func divideLocationsOutOfOrder(from sourceArray : Array<GCLocationAnalyserProtocol>,_ mergeDistance:CLLocationDistance) -> Array<Array<GCLocationAnalyserProtocol>>? {
        var currentMergeDistance = mergeDistance
        if currentMergeDistance <= 0{
            currentMergeDistance = 1_000_000 //CLLocationDistanceMax
        }
        
        if sourceArray.count == 0 {return nil}
        
        if sourceArray.count == 1 {return [sourceArray]}
        
        let previousObj = sourceArray.first!
        var tempArray:Array<GCLocationAnalyserProtocol> = [previousObj]
        var returnArray:Array<Array<GCLocationAnalyserProtocol>> = []
        
        var restSourceArray : Array<GCLocationAnalyserProtocol> = []
        var index:Int = 0
        for currentObj in sourceArray {
            
            if index > 0{
                let currentDistance = fabs(previousObj.location.distance(from: currentObj.location))
                if currentDistance < currentMergeDistance {
                    tempArray.append(currentObj)
                }else{
                    restSourceArray.append(currentObj)
                }

            }
            
            index += 1
        }
        returnArray.append(tempArray)
        
        // 嵌套迭代
        if let nextLoopResult = GCLocationAnalyser.divideLocationsOutOfOrder(from: restSourceArray, currentMergeDistance){
            returnArray.append(contentsOf: nextLoopResult)
        }
        
        return returnArray
    }

}
