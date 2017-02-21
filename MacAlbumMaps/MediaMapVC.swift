//
//  MediaMapVC.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/17.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa
import MapKit
import MediaLibrary

class MediaMapVC: NSViewController,MKMapViewDelegate{
    let mediaLibraryLoader = GCMediaLibraryLoader()

    @IBOutlet weak var mainMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.initMapView()
        
        self.initData()
        //let ainfo = CoordinateInfo.create(CLLocation.init(latitude: 25.5, longitude: 30.5))
        
//        CoordinateInfo.deleteAll()
//        
//        if let all = CoordinateInfo.fetchAll(){
//            print(all.count)
//        }else{
//            print("None")
//        }
        
        
        
        //let ainfo = CoordinateInfo.create(CLLocation.init(latitude: 25.5, longitude: 30.5))
//        if let info = CoordinateInfo.fetch(25.5, 30.5){
//            print(info.latitude!)
//        }else{
//            print("NO")
//        }
        //print(ainfo)
        
//        self.initData()
        //MLMediaObject.
//        if let firstInfo = CoordinateInfo.fetchAll()?.first{
//            self.mainMapView.addAnnotation(firstInfo)
//            self.mainMapView.showAnnotations([firstInfo], animated: true)
//        }
        
        
 
    }
    
    private func initMapView(){
        mainMapView.delegate = self
        mainMapView.mapType = MKMapType.standard
        mainMapView.showsScale = true
        //mainMapView.showsUserLocation = true
    }
    
    private func initData(){
        mediaLibraryLoader.asyncLoadMedia()
        mediaLibraryLoader.loadCompleteHandler = { (loadedMediaObjects: [MLMediaObject]) -> Void in
            print("Load OK")
            
            for mediaObject in loadedMediaObjects {
                let latitude = (mediaObject.attributes[MLMediaObjectHiddenAttributeKeys.latitudeKey] as! NSNumber).doubleValue
                let longitude = (mediaObject.attributes[MLMediaObjectHiddenAttributeKeys.longitudeKey] as! NSNumber).doubleValue
                
                
                //let aInfo = CoordinateInfo.create(latitude, longitude)
            }
            
            
        }
    }
}
