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
    
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var mergeDistanceForMomentTF: NSTextField!
    @IBOutlet weak var momentBtn: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.initMapView()
        
        self.initControls()
        
        //self.initData()
        
    }
    
    private func initMapView(){
        mainMapView.delegate = self
        mainMapView.mapType = MKMapType.standard
        mainMapView.showsScale = true
        //mainMapView.showsUserLocation = true
    }
    
    private func initControls(){
        self.startDatePicker.dateValue = Date.init(timeIntervalSinceNow: -30*24*60*60)
        self.endDatePicker.dateValue = Date.init(timeIntervalSinceNow: 0)
        self.mergeDistanceForMomentTF.stringValue = "200"
    }
    
    private func initData(){
        mediaLibraryLoader.asyncLoadMedia()
        mediaLibraryLoader.loadCompleteHandler = { (loadedMediaObjects: [MLMediaObject]) -> Void in
            print("Load OK")
            
            MAMCoreDataManager.updateCoreData(from: loadedMediaObjects)
        }
    }
    
    @IBAction func momentBtnTD(_ sender: NSButton) {
        //self.startDatePicker.dateValue
        self.mainMapView.removeAnnotations(self.mainMapView.annotations)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        
//        let infos = appContext.mediaInfos
//        var validInfos = [MediaInfo]()
//        for info in infos{
//            if let date = info.creationDate{
//                
//                if date.compare(self.startDatePicker.dateValue) == ComparisonResult.orderedDescending && date.compare(self.endDatePicker.dateValue) == ComparisonResult.orderedAscending{
//                    print(dateFormatter.string(from: date as Date))
//                    validInfos.append(info)
//                }
//            }
//        }
        
        let filteredMediaInfos = appContext.mediaInfos.filter { (info) -> NSPredicate in
            info.creationDate.isBetween(self.startDatePicker.dateValue..<self.endDatePicker.dateValue)
        }.sorted { (infoA, infoB) -> Bool in
            infoA.creationDate?.compare(infoB.creationDate as! Date) == ComparisonResult.orderedAscending
        }
        
        self.showMediaInfos(mediaInfos: filteredMediaInfos)
        
//        let infos2 = appContext.mediaInfos.filter { (info) -> NSPredicate in
//            info.modificationDate.isGreaterThan(self.startDatePicker.dateValue)
//        }
//        
//        let infos1 = appContext.mediaInfos.take(20)
        print(filteredMediaInfos.count)
        //print(validInfos.count)
//        for aInfo in infos {
//            self.mainMapView.addAnnotation(aInfo)
//        }
        
        self.mainMapView.addAnnotations(filteredMediaInfos)
        self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)

    }
    
    func showMediaInfos(mediaInfos: [MediaInfo]) {
        
    }
    
    // MARK - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let anotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "anno")
        let mediaInfo = annotation as! MediaInfo
        anotationView.image = NSImage.init(contentsOf: URL.init(string: mediaInfo.thumbnailURLString!)!)
        return anotationView
    }
}
