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

class MediaMapVC: NSViewController,MKMapViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource,NSTabViewDelegate{
    
    // MARK: - 属性
    @IBOutlet var locationTreeController: NSTreeController!
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    let mediaLibraryLoader = GCMediaLibraryLoader()
    
    
    var indexOfTabViewItem = 0{
        didSet{
            
        }
    }
    
    //var mapBaseMode: MapBaseMode = MapBaseMode.Moment
    
    /// 当前添加的、用于导航的 MKAnnotation数组
    var currentIDAnnotations = [MKAnnotation]()
//        {
//        didSet{
//            indexOfCurrentAnnotation = 0
//        }
//    }
    var currentMediaInfoGroupAnnotations = [MediaInfoGroupAnnotation]()
    var currentFootprintAnnotations = [FootprintAnnotation]()
    
    /// 当前MKAnnotation序号 
    /// ☆带属性观测器的核心属性
    var indexOfCurrentAnnotation = 0{
        didSet{
            print("didSet: indexOfCurrentAnnotation")
            if indexOfCurrentAnnotation >= 0 && indexOfCurrentAnnotation < currentIDAnnotations.count{
                
                // 显示序号
                self.indexOfCurrentAnnotationLabel.stringValue = "\(self.indexOfCurrentAnnotation + 1)/\(self.currentIDAnnotations.count)"
                
                // ☆移动地图
                let annotation = self.currentIDAnnotations[indexOfCurrentAnnotation]
                self.mainMapView.setCenter(annotation.coordinate, animated: false)
                self.mainMapView.selectAnnotation(annotation, animated: true)
                
                // 如果是时刻模式，添加直线路线
                if indexOfTabViewItem == 0 {
//                    if self.currentIDAnnotations.count == 2{
//                        self.addLineOverlays(annotations: self.currentIDAnnotations)
//                    }else if self.currentIDAnnotations.count > 2{
//                        if indexOfCurrentAnnotation == 0{
//                            self.addLineOverlays(annotations: [currentIDAnnotations[0],currentIDAnnotations[1]])
//                        }else if indexOfCurrentAnnotation == self.currentIDAnnotations.count - 1{
//                            self.addLineOverlays(annotations: [currentIDAnnotations[self.currentIDAnnotations.count - 2],currentIDAnnotations[self.currentIDAnnotations.count - 1]])
//                        }else{
//                            self.addLineOverlays(annotations: [currentIDAnnotations[indexOfCurrentAnnotation - 1],currentIDAnnotations[indexOfCurrentAnnotation],currentIDAnnotations[indexOfCurrentAnnotation + 1]])
//                        }
//                    }
                    var annos = [MKAnnotation]()
                    if currentIDAnnotations.count == 2{
                        if indexOfCurrentAnnotation == 0 {
                            annos = currentIDAnnotations
                        }
                    }else if self.currentIDAnnotations.count > 2{
                        if indexOfCurrentAnnotation != self.currentIDAnnotations.count - 1{
                            annos = [currentIDAnnotations[indexOfCurrentAnnotation],currentIDAnnotations[indexOfCurrentAnnotation + 1]]
                        }
                    }
                    
                    self.asyncAddRouteOverlays(annotations: annos, completionHandler: { (routePolylineCount, routeTotalDistance) in
                        
                    })
                }
                
            }else{
                indexOfCurrentAnnotation = oldValue
            }
        }
    }
    
    /// 当前 MediaInfoGroupAnnotation 的 MediaInfo数组
    var currentMediaInfos = [MediaInfo](){
        didSet{
            self.indexOfCurrentMediaInfo = 0
        }
    }
    
    /// 当前MediaInfo序号
    /// ☆带属性观测器的核心属性
    var indexOfCurrentMediaInfo = 0{
        didSet{
            if indexOfCurrentMediaInfo >= 0 && indexOfCurrentMediaInfo < self.currentMediaInfos.count {
                let currentMediaInfo = self.currentMediaInfos[indexOfCurrentMediaInfo]
                
                // 显示MediaInfo序号和信息
                var stringValue = "\(indexOfCurrentMediaInfo + 1)/\(self.currentMediaInfos.count)\n"
                stringValue += currentMediaInfo.detailInfomation
                
                self.currentMediaInfoLabel.stringValue = stringValue
                
                eliminateCheckBtn.state = currentMediaInfo.eliminateThisMedia!.intValue
                shareCheckBtn.state = currentMediaInfo.actAsThumbnail!.intValue
                
                // 显示MediaInfo缩略图或原图
                if let thumbnailURL = URL.init(string: currentMediaInfo.thumbnailURLString!){
                    self.imageView.image = NSImage.init(contentsOf:thumbnailURL)
                }else if let imageURL = URL.init(string: currentMediaInfo.urlString!){
                    self.imageView.image = NSImage.init(contentsOf:imageURL)
                }
                
                // 如果是影片
                if currentMediaInfo.contentType == kUTTypeQuickTimeMovie as String{
                    
                }
                
            }else{
                indexOfCurrentMediaInfo = oldValue
            }
        }
    }
    
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
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNotification(noti:)), name: NSNotification.Name(rawValue: "App_Running_Info"), object: nil)
    }
    
    private func initMapView(){
        mainMapView.delegate = self
        mainMapView.mapType = MKMapType.standard
        mainMapView.showsScale = true
        //mainMapView.showsUserLocation = true
    }
    
    private func initControls(){
        mapModeTabView.delegate = self
        
        // 初始化日期选择器
        self.startDatePicker.dateValue = Date.init(timeIntervalSinceNow: -7*24*60*60)
        self.endDatePicker.dateValue = Date.init(timeIntervalSinceNow: 0)
        
        // 初始化分组距离
        mergeDistanceForMomentTF.stringValue = "200"
        mergeDistanceForLocationTF.stringValue = "1000"
        
        // 初始化NSOutlineView
        let sortedMediaInfos = appContext.mediaInfos.sorted{ (infoA, infoB) -> Bool in
            infoA.creationDate?.compare(infoB.creationDate as! Date) == ComparisonResult.orderedAscending
        }

        rootTreeNode = MAMCoreDataManager.placemarkHierarchicalInfoTreeNode(mediaInfos: sortedMediaInfos)
        self.locationOutlineView.reloadData()
        self.locationOutlineView.expandItem(rootTreeNode)
        
        // 初始化statisticalInfoTV
        statisticalInfoTVString = self.statisticalInfos(mediaInfos: sortedMediaInfos)
        
        //self.goBtn.layer?.backgroundColor = DynamicColor.randomFlatColor.cgColor
    }
    
    private func updateMediaInfos(){
        
        mediaLibraryLoader.loadCompletionHandler = { (loadedMediaObjects: [MLMediaObject]) -> Void in
            //MAMCoreDataManager.latestModificationDate = Date.init(timeIntervalSince1970: 0.0)
            self.goBtn.isEnabled = false
            self.loadProgressIndicator.startAnimation(self)
            MAMCoreDataManager.updateCoreData(from: loadedMediaObjects)
            self.goBtn.isEnabled = true
            self.loadProgressIndicator.stopAnimation(self)
            
            MAMCoreDataManager.asyncUpdatePlacemarks()
        }
        
        mediaLibraryLoader.asyncLoadMedia()
    }
    
    // MARK: - 左侧视图 Left View
    
    // MARK: - 主控TabView
    @IBOutlet weak var mapModeTabView: NSTabView!
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if tabViewItem != nil{
            let tabIndex = tabView.indexOfTabViewItem(tabViewItem!)
            indexOfTabViewItem = tabIndex
        }
    }
    
    // MARK: - 左侧时刻选项栏
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var mergeDistanceForMomentTF: NSTextField!
    
    // MARK: - 左侧地址选项栏
    @IBOutlet weak var mergeDistanceForLocationTF: NSTextField!
    
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
    
    // MARK: - 左侧主控按钮
    
    @IBOutlet weak var goBtn: NSButton!
    var currentMergeDistance: Double = 0.0
    @IBAction func goBtnTD(_ sender: NSButton) {
        goBtn.isEnabled = false
        loadProgressIndicator.startAnimation(self)
        
        var filteredMediaInfos = [MediaInfo]()
        
        switch indexOfTabViewItem {
        case 0:
            // 时刻模式
            filteredMediaInfos = appContext.mediaInfos.filter { $0.creationDate.isBetween(self.startDatePicker.dateValue..<self.endDatePicker.dateValue) }.sorted { (infoA, infoB) -> Bool in
                    infoA.creationDate?.compare(infoB.creationDate as! Date) == ComparisonResult.orderedAscending
            }
            
            currentMergeDistance = NSString.init(string: mergeDistanceForMomentTF.stringValue.replacingOccurrences(of: ",", with: "")).doubleValue
            if currentMergeDistance == 0{
                currentMergeDistance = 200
            }
            
            self.showMediaInfos(mediaInfos: filteredMediaInfos,mapBaseMode:MapBaseMode.Moment,mergeDistance: currentMergeDistance)
            
        case 1:
            // 地点模式
            if let item = locationOutlineView.item(atRow: locationOutlineView.selectedRow){
                let tn = item as! GCTreeNode
                
                let filteredMediaInfos = appContext.mediaInfos.filter { $0.coordinateInfo.localizedPlaceString_Placemark.contains(tn.title) }.sorted { (infoA, infoB) -> Bool in
                    infoA.creationDate?.compare(infoB.creationDate as! Date) == ComparisonResult.orderedAscending
                }
                
                currentMergeDistance = NSString.init(string: mergeDistanceForLocationTF.stringValue.replacingOccurrences(of: ",", with: "")).doubleValue
                if currentMergeDistance == 0{
                    currentMergeDistance = 1000
                }
                self.showMediaInfos(mediaInfos: filteredMediaInfos,mapBaseMode: MapBaseMode.Location,mergeDistance: currentMergeDistance)
            }
            
        default:
            // 浏览模式
            break
        }
        
        goBtn.isEnabled = true
        loadProgressIndicator.stopAnimation(self)
    }
    
    @IBAction func locationBtnTD(_ sender: NSButton) {
        
    }
    
    
    @IBOutlet weak var loadProgressIndicator: NSProgressIndicator!

    // MARK: - 左侧地址信息解析显示
    @IBOutlet weak var placemarkInfoTF: NSTextField!
    
    // MARK: - 左侧统计信息
    @IBOutlet var statisticalInfoTV: NSTextView!
    var statisticalInfoTVString = ""{
        didSet{
            let dateString = Date.init(timeIntervalSinceNow: 0.0).stringWithDefaultFormat()
            statisticalInfoTV.string = "\n" + dateString + "\n" + statisticalInfoTVString + "\n" + statisticalInfoTV.string!
        }
    }
    
    func didReceiveNotification(noti: NSNotification) {
        for (infoKey,info) in noti.userInfo! {
            switch infoKey as! String {
            case "Placemark_Updating_Info_String":
                placemarkInfoTF.stringValue = info as! String
            case "Scan_Photos_Result_String":
                statisticalInfoTVString = info as! String
            default:
                break
            }
        }
    }

    // MARK: - 右侧视图 Right View
    
    // MARK: - 右侧功能按钮
    @IBAction func mapTypeBtnTD(_ sender: NSButton) {
        if mainMapView.mapType == MKMapType.standard {
            mainMapView.mapType = MKMapType.hybrid
        }else{
            mainMapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func changeOverlayStyleBtnTD(_ sender: NSButton) {
        
    }
    
    @IBAction func shareFootprintsRepositoryBtnTD(_ sender: NSButton) {
        
    }

    // MARK: - 右侧Annotation序号
    @IBOutlet weak var indexOfCurrentAnnotationLabel: NSTextField!
    
    // MARK: - 右侧导航按钮 Navigation
    // var isPlaying = false
    var playTimer: Timer?
    
    @IBAction func firstBtnTD(_ sender: NSButton) {
        self.indexOfCurrentAnnotation = 0
    }
    
    @IBAction func previousBtnTD(_ sender: NSButton) {
        self.indexOfCurrentAnnotation -= 1
    }
    
    @IBAction func playBtnTD(_ sender: NSButton) {
        if playTimer == nil {
            playTimer = Timer.init(timeInterval: 2.0, repeats: true, block: { _ in self.indexOfCurrentAnnotation += 1 })
        }else{
            playTimer = nil
        }
    }
    
    @IBAction func nextBtnTD(_ sender: NSButton) {
        self.indexOfCurrentAnnotation += 1
    }
    
    @IBAction func lastBtnTD(_ sender: NSButton) {
        self.indexOfCurrentAnnotation = self.currentIDAnnotations.count - 1
    }
    
    // MARK: - 右侧底部图片视图 Right Bottom Left Image View
    
    @IBOutlet weak var imageView: NSImageView!
    
    // MARK: - 右侧底部MediaInfo信息视图
    @IBOutlet weak var currentMediaInfoLabel: NSTextField!
    
    // MARK: - 右侧底部按钮
    @IBAction func previousImageBtnTD(_ sender: NSButton) {
        self.indexOfCurrentMediaInfo -= 1
    }
    
    @IBAction func nextImageBtnTD(_ sender: NSButton) {
        self.indexOfCurrentMediaInfo += 1
    }
    
    @IBOutlet weak var eliminateCheckBtn: NSButton!
    @IBAction func eliminateCheckBtnTD(_ sender: NSButton) {
        let currentMediaInfo = currentMediaInfos[indexOfCurrentMediaInfo]
        currentMediaInfo.eliminateThisMedia = NSNumber.init(value: sender.state == 1 ? true : false)
        try! appContext.save()
    }
    
    @IBOutlet weak var shareCheckBtn: NSButton!
    @IBAction func shareCheckBtnTD(_ sender: NSButton) {
        //print(sender.state)
        let currentMediaInfo = currentMediaInfos[indexOfCurrentMediaInfo]
        currentMediaInfo.actAsThumbnail = NSNumber.init(value: sender.state == 1 ? true : false)
        try! appContext.save()
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
        
        statisticalInfoTVString = self.statisticalInfos(mediaInfos: mediaInfos)
        
        var groupArray: Array<Array<GCLocationAnalyserProtocol>>? = nil
        if mapBaseMode == MapBaseMode.Moment {
            groupArray = GCLocationAnalyser.divideLocationsInOrder(from: mediaInfos,mergeDistance: mergeDistance)
        }else if mapBaseMode == MapBaseMode.Location{
            groupArray = GCLocationAnalyser.divideLocationsOutOfOrder(from: mediaInfos,mergeDistance: mergeDistance)
        }
        
        if groupArray == nil {
            return
        }
        
        self.mainMapView.removeAnnotations(self.currentIDAnnotations)
        self.currentMediaInfoGroupAnnotations = []
        self.currentFootprintAnnotations = []
        
        for (groupIndex,currentGroup) in groupArray!.enumerated() {
            //print("groupIndex: \(groupIndex)")
            
            let mediaGroupAnno = MediaInfoGroupAnnotation.init()
            let footprintAnno = FootprintAnnotation.init()
            
            for (mediaInfoIndex,mediaObject) in currentGroup.enumerated() {
                //print("mediaInfoIndex: \(mediaInfoIndex)")
                let mediaInfo = mediaObject as! MediaInfo
                let creationDate = mediaInfo.creationDate as! Date
                
                // 添加MediaInfo
                mediaGroupAnno.mediaInfos.append(mediaInfo)
                
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
            
            if groupIndex == 0 {
                print("根据 currentMergeDistance 缩放地图")
                let span = MKCoordinateSpan.init(latitudeDelta: currentMergeDistance / 10000.0, longitudeDelta: currentMergeDistance / 10000.0)
                mainMapView.setRegion(MKCoordinateRegion.init(center: mediaGroupAnno.coordinate, span: span), animated: true)
                
            }
            
            // 更新数组
            self.currentMediaInfoGroupAnnotations.append(mediaGroupAnno)
            self.currentFootprintAnnotations.append(footprintAnno)
        }
        
        currentIDAnnotations = currentMediaInfoGroupAnnotations
        mainMapView.selectAnnotation(currentIDAnnotations.first!, animated: true)
        
        // 添加
        if mapBaseMode == MapBaseMode.Moment {
            //self.addLineOverlays(annotations: self.currentIDAnnotations)
        }else if mapBaseMode == MapBaseMode.Location{
            self.addCircleOverlays(annotations: self.currentIDAnnotations, radius: mergeDistance / 2.0)
        }
        
    }
    
    func addLineOverlays(annotations: [MKAnnotation],fixedArrowLength: CLLocationDistance = 0.0) {
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
                let polygon = MediaMapVC.createArrowMKPolygon(startCoordinate: previousCoord, endCoordinate: anno.coordinate ,fixedArrowLength: fixedArrowLength)
                
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
    
    class func createArrowMKPolygon(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D,fixedArrowLength: CLLocationDistance = 0.0) -> MKPolyline {
        let start_MP: MKMapPoint = MKMapPointForCoordinate(startCoordinate)
        let end_MP: MKMapPoint = MKMapPointForCoordinate(endCoordinate)
        var x_MP: MKMapPoint = MKMapPoint.init()
        var y_MP = x_MP
        var z_MP = x_MP
        
        let arrowLength = fixedArrowLength == 0 ? MKMetersBetweenMapPoints(start_MP, end_MP) : fixedArrowLength
        
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
    
    func asyncAddRouteOverlays(annotations: [MKAnnotation],completionHandler:((_ routePolylineCount:Int ,_ routeTotalDistance:CLLocationDistance) -> Void)?){
        
        mainMapView.removeOverlays(self.mainMapView.overlays)
        
        if annotations.count < 2 {
            completionHandler?(0,0)
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            var routeTotalDistance: CLLocationDistance = 0;
            var routePolylineCount = 0;
            var lastCoordinate = CLLocationCoordinate2D.init()
            
            for (annoIndex,anno) in annotations.enumerated() {
                if annoIndex > 0 {
                    MediaMapVC.asyncCreateRouteMKPolyline(startCoordinate: lastCoordinate, endCoordinate: anno.coordinate, completionHandler: { (routePolyline, routeDistance) in
                        var newPolyline = MKPolyline.init()
                        
                        if routePolyline != nil{
                            routePolylineCount += 1
                            routeTotalDistance += routeDistance
                            newPolyline = routePolyline!
                        }else{
                            newPolyline = MediaMapVC.createLineMKPolyline(startCoordinate: lastCoordinate, endCoordinate: anno.coordinate)
                            routeTotalDistance += MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(anno.coordinate))
                        }
                        
                        DispatchQueue.main.async {
                            self.mainMapView.addOverlays([newPolyline])
                        }
                        
                    })
                }
                lastCoordinate = anno.coordinate
                
                Thread.sleep(forTimeInterval: 0.2)
                if annoIndex % 50 == 0{
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }

        }
        
        
    }
    
    class func asyncCreateRouteMKPolyline(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D,completionHandler:@escaping (_ routePolyline:MKPolyline?,_ routeDistance:CLLocationDistance) -> Void) {
        let startMapItem = MKMapItem.init(placemark: MKPlacemark.init(coordinate: startCoordinate))
        let endMapItem = MKMapItem.init(placemark: MKPlacemark.init(coordinate: endCoordinate))
        
        let directionsRequest = MKDirectionsRequest.init()
        directionsRequest.source = startMapItem
        directionsRequest.destination = endMapItem
        
        let directions = MKDirections.init(request: directionsRequest)
        
        directions.calculate(completionHandler: { (directionsResponse, error) in
            if let route = directionsResponse?.routes.first{
                let polyline = route.polyline
                completionHandler(polyline,route.distance)
            }else{
                completionHandler(nil,0)
            }
        })
    }
    
    
    
    // MARK: - 地图视图代理方法 MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MediaInfoGroupAnnotation {
            let pinAV = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pinAV")
            pinAV.pinTintColor = DynamicColor.randomColor(in: DynamicColor.preferredAnnotationViewColors)
            pinAV.canShowCallout = true
            
            let mediaGroupAnno = annotation as! MediaInfoGroupAnnotation
            if let mediaInfo = mediaGroupAnno.mediaInfos.first{
                //print("Add a MediaInfoGroupAnnotation")
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
    
    var lastRandomColor = DynamicColor.randomColor(in: DynamicColor.preferredOverlayColors)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            lastRandomColor = NSColor.green
            let polylineRenderer = MKPolylineRenderer.init(overlay: overlay)
            polylineRenderer.lineWidth = 3
            polylineRenderer.strokeColor = lastRandomColor.withAlphaComponent(0.6)
            return polylineRenderer
        }else if overlay is MKPolygon{
            let polygonRenderer = MKPolygonRenderer.init(overlay: overlay)
            polygonRenderer.lineWidth = 1
            polygonRenderer.strokeColor = lastRandomColor.withAlphaComponent(0.6)
            return polygonRenderer
        }else if overlay is MKCircle {
            lastRandomColor = NSColor.green
            let circleRenderer = MKCircleRenderer.init(overlay: overlay)
            circleRenderer.lineWidth = 1
            circleRenderer.fillColor = lastRandomColor.withAlphaComponent(0.4)
            circleRenderer.strokeColor = lastRandomColor.withAlphaComponent(0.6)
            return circleRenderer
        }else {
            return MKOverlayRenderer.init(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("mapView didSelect")
        if let currentSelectedAnnotationIndex = self.currentIDAnnotations.index(where: { $0 === view.annotation }){
            self.indexOfCurrentAnnotation = currentSelectedAnnotationIndex.hashValue
        }
        
        if view is MKPinAnnotationView {
            if view.annotation is MediaInfoGroupAnnotation{
                let mediaGroupAnno = view.annotation as! MediaInfoGroupAnnotation
                self.currentMediaInfos = mediaGroupAnno.mediaInfos
            }
        }
    }
    
}
