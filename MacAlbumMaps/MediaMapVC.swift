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
    
    var mapBaseMode: MapBaseMode = MapBaseMode.Moment
    
    var addedIDAnnotations = [MKAnnotation]()
    var addedMediaGroupAnnotations = [MediaGroupAnnotation]()
    var addedFootprintAnnotations = [FootprintAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.initMapView()
        
        self.initControls()
        
        self.updateMediaInfos()
        
    }
    
    private func initMapView(){
        mainMapView.delegate = self
        mainMapView.mapType = MKMapType.standard
        mainMapView.showsScale = true
        //mainMapView.showsUserLocation = true
    }
    
    private func initControls(){
        self.startDatePicker.dateValue = Date.init(timeIntervalSinceNow: -7*24*60*60)
        self.endDatePicker.dateValue = Date.init(timeIntervalSinceNow: 0)
        self.mergeDistanceForMomentTF.stringValue = "200"
    }
    
    private func updateMediaInfos(){
        
        mediaLibraryLoader.loadCompleteHandler = { (loadedMediaObjects: [MLMediaObject]) -> Void in
            print("Load OK")
            
            MAMCoreDataManager.updateCoreData(from: loadedMediaObjects)
            MAMCoreDataManager.asyncUpdatePlacemarks()
        }
        
        mediaLibraryLoader.asyncLoadMedia()
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
        
        self.showMediaInfos(mediaInfos: filteredMediaInfos,mapBaseMode: MapBaseMode.Location,mergeDistance: 200)
        
//        let infos2 = appContext.mediaInfos.filter { (info) -> NSPredicate in
//            info.modificationDate.isGreaterThan(self.startDatePicker.dateValue)
//        }
//        
//        let infos1 = appContext.mediaInfos.take(20)
        //print(filteredMediaInfos.count)
        //print(validInfos.count)
//        for aInfo in infos {
//            self.mainMapView.addAnnotation(aInfo)
//        }
        
        //self.mainMapView.addAnnotations(filteredMediaInfos)
        //self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
    }
    
    func showMediaInfos(mediaInfos: [MediaInfo],mapBaseMode: MapBaseMode,mergeDistance: CLLocationDistance) {
        var groupArray: Array<Array<GCLocationAnalyserProtocol>>? = nil
        if mapBaseMode == MapBaseMode.Moment {
            groupArray = GCLocationAnalyser.divideLocationsInOrder(from: mediaInfos,mergeDistance: mergeDistance)
        }else if mapBaseMode == MapBaseMode.Location{
            groupArray = GCLocationAnalyser.divideLocationsOutOfOrder(from: mediaInfos,mergeDistance: mergeDistance)
        }
        
        if groupArray == nil {
            return
        }
        
        self.mainMapView.removeAnnotations(self.addedIDAnnotations)
        self.addedMediaGroupAnnotations = []
        self.addedFootprintAnnotations = []
        
        for (groupIndex,currentGroup) in groupArray!.enumerated() {
            print("groupIndex: \(groupIndex)")
            
            let mediaGroupAnno = MediaGroupAnnotation.init()
            let footprintAnno = FootprintAnnotation.init()
            
            for (mediaInfoIndex,mediaObject) in currentGroup.enumerated() {
                print("mediaInfoIndex: \(mediaInfoIndex)")
                let mediaInfo = mediaObject as! MediaInfo
                let creationDate = mediaInfo.creationDate as! Date
                
                // 添加ID
                mediaGroupAnno.mediaIdentifiers.append(mediaInfo.identifier!)
                
                if mediaInfoIndex == 0 {
                    // 该组第1张照片
                    mediaGroupAnno.location = mediaInfo.location
                    
                    if let placeName = mediaInfo.coordinateInfo?.localizedPlaceString_Placemark{
                        mediaGroupAnno.annoTitle = placeName
                    }else{
                        mediaGroupAnno.annoTitle = NSLocalizedString("(Parsing location)", comment: "（正在解析位置）")
                    }
                    
                    if mapBaseMode == MapBaseMode.Moment {
                        mediaGroupAnno.annoSubtitle = creationDate.stringWithDefaultFormat()
                    }else if mapBaseMode == MapBaseMode.Location{
                        mediaGroupAnno.annoSubtitle = creationDate.stringWithFormat(format: "yyyy-MM-dd")
                    }
                    
                    //footprintAnno.customTitle = mediaGroupAnno.annoTitle
                    footprintAnno.coordinateWGS84 = mediaInfo.coordinate
                    footprintAnno.altitude = mediaInfo.location.altitude
                    footprintAnno.speed = mediaInfo.location.speed
                    footprintAnno.startDate = creationDate
                    
                }else if mediaInfoIndex == currentGroup.count - 1{
                    // 该组最后1张照片
                    if mapBaseMode == MapBaseMode.Location{
                        mediaGroupAnno.annoSubtitle += " ~ " + creationDate.stringWithFormat(format: "yyyy-MM-dd")
                        footprintAnno.endDate = creationDate
                    }

                }
                
            }
            
            // 将该点添加到地图
            self.mainMapView.addAnnotation(mediaGroupAnno)
            
            // 更新数组
            self.addedMediaGroupAnnotations.append(mediaGroupAnno)
            self.addedFootprintAnnotations.append(footprintAnno)
        }
        
        // 添加
        if mapBaseMode == MapBaseMode.Moment {
            self.addLineOverlays(annotations: self.addedMediaGroupAnnotations)
        }else if mapBaseMode == MapBaseMode.Location{
            self.addCircleOverlays(annotations: self.addedMediaGroupAnnotations, radius: mergeDistance)
        }
        
        self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
    }
    
    func addLineOverlays(annotations: [MKAnnotation]) {
        self.mainMapView.removeOverlays(self.mainMapView.overlays)
        
        if annotations.count < 2 {
            return
        }
        
        // 记录距离信息
        var totalDistance: CLLocationDistance = 0.0
        
        // 添加
        var previousCoord: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
        for (index,anno) in annotations.enumerated() {
            if index >= 1 {
                let polyline = MediaMapVC.createLineMKPolyline(startCoordinate: previousCoord, endCoordinate: anno.coordinate)
                let polygon = MediaMapVC.createArrowMKPolygon(startCoordinate: previousCoord, endCoordinate: anno.coordinate)
                
                self.mainMapView.addOverlays([polyline,polygon])
                
                totalDistance += MKMetersBetweenMapPoints(MKMapPointForCoordinate(previousCoord), MKMapPointForCoordinate(anno.coordinate))
            }
            
            previousCoord = anno.coordinate
        }
    }
    
    class func createLineMKPolyline(startCoordinate startCoord:CLLocationCoordinate2D,endCoordinate endCoord:CLLocationCoordinate2D) -> MKPolyline {
        let coordinates = [startCoord,endCoord]
        return MKPolyline.init(coordinates: coordinates, count: 2)
    }
    
    class func createArrowMKPolygon(startCoordinate startCoord:CLLocationCoordinate2D,endCoordinate endCoord:CLLocationCoordinate2D) -> MKPolyline {
        let start_MP: MKMapPoint = MKMapPointForCoordinate(startCoord)
        let end_MP: MKMapPoint = MKMapPointForCoordinate(endCoord)
        var x_MP: MKMapPoint = MKMapPoint.init()
        var y_MP = x_MP
        var z_MP = x_MP
        
        let arrowLength = MKMetersBetweenMapPoints(start_MP, end_MP)
        
        let z_radian = atan2(end_MP.x - start_MP.x, end_MP.y - start_MP.y)
        z_MP.x = end_MP.x - arrowLength * 0.75 * sin(z_radian);
        z_MP.y = end_MP.y - arrowLength * 0.75 * cos(z_radian);
        
        let arrowRadian = 90.0 / 360.0 * M_2_PI
        x_MP.x = end_MP.x - arrowLength * sin(z_radian - arrowRadian)
        x_MP.y = end_MP.y - arrowLength * cos(z_radian - arrowRadian)
        y_MP.x = end_MP.x - arrowLength * sin(z_radian + arrowRadian)
        y_MP.y = end_MP.y - arrowLength * cos(z_radian + arrowRadian)
        
        return MKPolyline.init(points: [z_MP,x_MP,end_MP,y_MP,z_MP], count: 5)
    }
    
    func addCircleOverlays(annotations: [MKAnnotation],radius circleRadius: CLLocationDistance) {
        self.mainMapView.removeOverlays(self.mainMapView.overlays)
        
        if annotations.count < 1 {
            return
        }
        var circleOverlays = [MKCircle]()
        for anno in annotations {
            let circle = MKCircle.init(center: anno.coordinate, radius: circleRadius)
            circleOverlays.append(circle)
        }
                
        self.mainMapView.addOverlays(circleOverlays)
    }
    
    
    // MARK - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MediaGroupAnnotation.self) {
            let pinAV = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pinAV")
            pinAV.pinTintColor = NSColor.blue
            pinAV.canShowCallout = true
            
            let mediaGroupAnno = annotation as! MediaGroupAnnotation
            if let mediaInfo = appContext.mediaInfos.first(where: { (info) -> Bool in
                info.identifier == mediaGroupAnno.mediaIdentifiers.first!
            }){
                print("Add a MediaGroupAnnotation")
                let imageView = NSImageView.init(frame: NSRect.init(x: 0, y: 0, width: 80, height: 80))
                //imageView.layer?.backgroundColor = NSColor.black.cgColor
                imageView.image = NSImage.init(contentsOf: URL.init(string: mediaInfo.thumbnailURLString!)!)
                //imageView.content
                pinAV.leftCalloutAccessoryView = imageView
                //pinAV.rightCalloutAccessoryView = imageView
            }
            
            return pinAV
        }else{
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            let polylineRenderer = MKPolylineRenderer.init(overlay: overlay)
            polylineRenderer.lineWidth = 2
            polylineRenderer.strokeColor = NSColor.red
            return polylineRenderer
        }else if overlay.isKind(of: MKPolygon.self) {
            let polygonRenderer = MKPolygonRenderer.init(overlay: overlay)
            polygonRenderer.lineWidth = 1
            polygonRenderer.strokeColor = NSColor.red
            return polygonRenderer
        }else if overlay.isKind(of: MKCircle.self) {
            let circleRenderer = MKCircleRenderer.init(overlay: overlay)
            circleRenderer.lineWidth = 1
            circleRenderer.fillColor = NSColor.green
            circleRenderer.strokeColor = NSColor.red
            return circleRenderer
        }else {
            return MKOverlayRenderer.init(overlay: overlay)
        }
    }
}
