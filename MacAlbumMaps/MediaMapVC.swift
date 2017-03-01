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

class MediaMapVC: NSViewController,MKMapViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource{
    
    // MARK: - 属性
    @IBOutlet var locationTreeController: NSTreeController!
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    
    
    
    
    @IBOutlet weak var imageView: NSImageView!
    var mediaURLsFromSelectedMediaGroupAnnotation = [URL]()
    var indexOfCurrentImage = 0
    
    let mediaLibraryLoader = GCMediaLibraryLoader()
    
    var mapBaseMode: MapBaseMode = MapBaseMode.Moment
    
    var addedIDAnnotations = [MKAnnotation]()
    var addedMediaGroupAnnotations = [MediaGroupAnnotation]()
    var addedFootprintAnnotations = [FootprintAnnotation]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.addNotificationObserver()
        
        self.initMapView()
        
        self.initControls()
        
        self.updateMediaInfos()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNotification(noti:)), name: NSNotification.Name(rawValue: "Placemark_Is_Updating"), object: nil)
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
        
        rootTreeNode = MAMCoreDataManager.placemarkHierarchicalInfoTreeNode(mediaInfos: appContext.mediaInfos.sorted(by: { _,_ in true }))
        self.locationOutlineView.reloadData()
        
    }
    
    private func updateMediaInfos(){
        
        mediaLibraryLoader.loadCompleteHandler = { (loadedMediaObjects: [MLMediaObject]) -> Void in
            print("Load OK")
            
            //MAMCoreDataManager.latestModificationDate = Date.init(timeIntervalSince1970: 0.0)
            MAMCoreDataManager.updateCoreData(from: loadedMediaObjects)
            MAMCoreDataManager.asyncUpdatePlacemarks()
        }
        
        mediaLibraryLoader.asyncLoadMedia()
    }
    
    // MARK: - 左侧视图 Left View
    
    // MARK: - 左侧时刻选项栏
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var mergeDistanceForMomentTF: NSTextField!
    @IBOutlet weak var momentBtn: NSButton!

    @IBAction func momentBtnTD(_ sender: NSButton) {
        self.mainMapView.removeAnnotations(self.mainMapView.annotations)
        
        let filteredMediaInfos = appContext.mediaInfos.filter { (info) -> NSPredicate in
            info.creationDate.isBetween(self.startDatePicker.dateValue..<self.endDatePicker.dateValue)
        }.sorted { (infoA, infoB) -> Bool in
            infoA.creationDate?.compare(infoB.creationDate as! Date) == ComparisonResult.orderedAscending
        }
        
        self.showMediaInfos(mediaInfos: filteredMediaInfos,mapBaseMode: MapBaseMode.Location,mergeDistance: 200)
    }
    
    
    // MARK: - 左侧地址选项栏
    // MARK: - 列表视图 
    @IBOutlet weak var locationOutlineView: NSOutlineView!
    var rootTreeNode = GCTreeNode()
    
    // NSOutlineViewDataSource
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item != nil{
            let treeNode = item as! GCTreeNode
            return treeNode.numberOfChildren
        }else{
            return rootTreeNode.numberOfChildren
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let treeNode = item as! GCTreeNode
        if treeNode.isLeaf {
            return false
        }else{
            return true
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        //print(item)
        if item != nil{
            let treeNode = item as! GCTreeNode
            return treeNode.childAtIndex(index: index)!
        }else{
            return rootTreeNode
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        let treeNode = item as! GCTreeNode
        
        if tableColumn?.identifier == "TC0" {
            view.textField?.stringValue =  treeNode.title
        }else if tableColumn?.identifier == "TC1"{
            view.textField?.stringValue = "\(treeNode.representedObject as! Int)"
        }
        
        return view
    }
    
    // NSOutlineViewDelegate
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return false
    }
    
    // MARK: - 左侧地址信息解析显示
    @IBOutlet weak var placemarkInfoTF: NSTextField!
    func didReceiveNotification(noti: NSNotification) {
        print(noti)
        placemarkInfoTF.stringValue = noti.userInfo!["Placemark_InfoString"] as! String
    }
    
    // MARK: - 左侧统计信息
    @IBOutlet var statisticalInfoTV: NSTextView!

    // MARK: - 右侧视图 Right View
    
    
    
    // MARK: - 右侧导航按钮 Navigation
    @IBAction func firstBtnTD(_ sender: NSButton) {
        if let first = self.mainMapView.annotations.first{
            self.mainMapView.setCenter(first.coordinate, animated: false)
            self.mainMapView.selectAnnotation(first, animated: true)
        }
        
    }
    
    @IBAction func previousBtnTD(_ sender: NSButton) {
    }
    
    @IBAction func playBtnTD(_ sender: NSButton) {
    }
    
    @IBAction func nextBtnTD(_ sender: NSButton) {
    }
    
    @IBAction func lastBtnTD(_ sender: NSButton) {
    }
    
    // MARK: - 右侧底部图片视图 Right Bottom Left Image View
    @IBAction func previousImageBtnTD(_ sender: NSButton) {
        self.indexOfCurrentImage -= 1
        if self.indexOfCurrentImage >= 0 {
            self.imageView.image = NSImage.init(contentsOf: mediaURLsFromSelectedMediaGroupAnnotation[self.indexOfCurrentImage])
        }else{
            self.indexOfCurrentImage = 0
        }
    }
    
    @IBAction func nextImageBtnTD(_ sender: NSButton) {
        self.indexOfCurrentImage += 1
        if self.indexOfCurrentImage < mediaURLsFromSelectedMediaGroupAnnotation.count {
            self.imageView.image = NSImage.init(contentsOf: mediaURLsFromSelectedMediaGroupAnnotation[self.indexOfCurrentImage])
        }else{
            self.indexOfCurrentImage = mediaURLsFromSelectedMediaGroupAnnotation.count - 1
        }
    }
    
    // MARK: - 相册地图核心方法
    
    func statisticalInfos(mediaInfos: [MediaInfo]) -> String {
        var statisticalString = ""
        
        let piDic = MAMCoreDataManager.placemarkInfoDictionary(mediaInfos: mediaInfos)
        statisticalString += NSLocalizedString("Location statistical info: ", comment: "地点统计信息：") + "\n"
        statisticalString += NSLocalizedString("Country: ", comment: "国家：") + "\(piDic[.kCountryArray]!.count)\n"
        statisticalString += NSLocalizedString("AdministrativeArea: ", comment: "省：") + "\(piDic[.kAdministrativeAreaArray]!.count)\n"
        statisticalString += NSLocalizedString("Locality: ", comment: "市：") + "\(piDic[.kLocalityArray]!.count)\n"
        statisticalString += NSLocalizedString("SubLocality: ", comment: "县乡：") + "\(piDic[.kSubLocalityArray]!.count)\n"
        statisticalString += NSLocalizedString("Thoroughfare: ", comment: "村镇街道：") + "\(piDic[.kThoroughfareArray]!.count)"
        
        return statisticalString
    }
    
    func showMediaInfos(mediaInfos: [MediaInfo],mapBaseMode: MapBaseMode,mergeDistance: CLLocationDistance) {
        
        statisticalInfoTV.string = self.statisticalInfos(mediaInfos: mediaInfos)
        
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
            //print("groupIndex: \(groupIndex)")
            
            let mediaGroupAnno = MediaGroupAnnotation.init()
            let footprintAnno = FootprintAnnotation.init()
            
            for (mediaInfoIndex,mediaObject) in currentGroup.enumerated() {
                //print("mediaInfoIndex: \(mediaInfoIndex)")
                let mediaInfo = mediaObject as! MediaInfo
                let creationDate = mediaInfo.creationDate as! Date
                
                // 添加ID
                mediaGroupAnno.mediaIdentifiers.append(mediaInfo.identifier!)
                
                if let urlString = mediaInfo.urlString{
                    mediaGroupAnno.mediaURLs.append(URL.init(string: urlString)!)
                }
                
                if mediaInfoIndex == 0 {
                    // 该组第1张照片
                    mediaGroupAnno.location = mediaInfo.location
                    
                    if let placeName = mediaInfo.coordinateInfo?.localizedPlaceString_Placemark{
                        mediaGroupAnno.annoTitle = placeName.placemarkBriefName()
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
        self.mainMapView.selectAnnotation(self.mainMapView.annotations.first!, animated: true)
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
    
    class func createLineMKPolyline(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D) -> MKPolyline {
        let coordinates = [startCoordinate,endCoordinate]
        return MKPolyline.init(coordinates: coordinates, count: 2)
    }
    
    class func createArrowMKPolygon(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D) -> MKPolyline {
        let start_MP: MKMapPoint = MKMapPointForCoordinate(startCoordinate)
        let end_MP: MKMapPoint = MKMapPointForCoordinate(endCoordinate)
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
    
    
    
    // MARK: - 地图视图代理方法 MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MediaGroupAnnotation {
            let pinAV = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pinAV")
            pinAV.pinTintColor = NSColor.blue
            pinAV.canShowCallout = true
            
            let mediaGroupAnno = annotation as! MediaGroupAnnotation
            if let mediaInfo = appContext.mediaInfos.first(where: { (info) -> Bool in
                info.identifier == mediaGroupAnno.mediaIdentifiers.first!
            }){
                //print("Add a MediaGroupAnnotation")
                let imageView = NSImageView.init(frame: NSRect.init(x: 0, y: 0, width: 80, height: 80))
                //imageView.layer?.backgroundColor = NSColor.black.cgColor
                imageView.image = NSImage.init(contentsOf: URL.init(string: mediaInfo.thumbnailURLString!)!)
                //imageView.content
                //pinAV.leftCalloutAccessoryView = imageView
                //pinAV.rightCalloutAccessoryView = imageView
            }
            
            return pinAV
        }else{
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer.init(overlay: overlay)
            polylineRenderer.lineWidth = 2
            polylineRenderer.strokeColor = NSColor.red
            return polylineRenderer
        }else if overlay is MKPolygon{
            let polygonRenderer = MKPolygonRenderer.init(overlay: overlay)
            polygonRenderer.lineWidth = 1
            polygonRenderer.strokeColor = NSColor.red
            return polygonRenderer
        }else if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer.init(overlay: overlay)
            circleRenderer.lineWidth = 1
            circleRenderer.fillColor = NSColor.green
            circleRenderer.strokeColor = NSColor.red
            return circleRenderer
        }else {
            return MKOverlayRenderer.init(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view is MKPinAnnotationView {
            if view.annotation is MediaGroupAnnotation{
                let mediaGroupAnno = view.annotation as! MediaGroupAnnotation
                mediaURLsFromSelectedMediaGroupAnnotation = mediaGroupAnno.mediaURLs
                
                self.imageView.image = NSImage.init(contentsOf: mediaURLsFromSelectedMediaGroupAnnotation.first!)
                self.indexOfCurrentImage = 0
            }
        }
    }
    
}
