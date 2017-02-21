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

let appContext = AppDelegate().managedObjectContext

class MediaMapVC: NSViewController,MKMapViewDelegate{
    let mediaLibraryLoader = GCMediaLibraryLoader()

    @IBOutlet weak var mainMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.initMapView()
        
        //self.initData()
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
        
        //self.initData()
        //MLMediaObject.
        
        let infos = appContext.mediaInfos.take(10)
        
        for aInfo in infos {
            self.mainMapView.addAnnotation(aInfo)
        }
        
        
        self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
        
 
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
            var addCoordinateInfoCount = 0
            var addMediaInfoCount = 0
            
            for mediaObject in loadedMediaObjects {
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
                    
                    addMediaInfoCount += 1
                }
            }
            
            do {
                try appContext.save()
                print("Add Result:")
                print(addCoordinateInfoCount)
                print(addMediaInfoCount)
                print(appContext.coordinateInfos.count())
                
            } catch  {
                print("Add Error!")
            }
            
            
        }
    }
    
    // MARK - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let anotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "anno")
        let mediaInfo = annotation as! MediaInfo
        anotationView.image = NSImage.init(contentsOf: URL.init(string: mediaInfo.thumbnailURLString!)!)
        return anotationView
    }
}
