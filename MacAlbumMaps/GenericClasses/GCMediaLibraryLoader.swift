//
//  GCMediaLibraryLoader.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/16.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa
import MediaLibrary

typealias LoadCompletionHandler = (_ loadedMediaObjects: [MLMediaObject]) -> Void

public struct MLMediaObjectHiddenAttributeKeys{
    static let contentTypeKey = "contentType"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let modelIdKey = "modelId"
    static let DateAsTimerIntervalKey = "DateAsTimerInterval"
    static let FaceListKey = "FaceList"
    static let RDMediaSpecialTypeKey = "RDMediaSpecialType"
    static let PlacesKey = "Places"
    static let NameKey = "Name"
}

class GCMediaLibraryLoader: NSObject {
    
    
    // MARK: - Types
    
    // MLMediaLibrary property values for KVO.
    public struct MLMediaLibraryPropertyKeys{
        static let mediaSourcesKey = "mediaSources"
        static let rootMediaGroupKey = "rootMediaGroup"
        static let mediaObjectsKey = "mediaObjects"
    }
    
    
    
    // MARK: - Properties
    
    /**
     The KVO contexts for `MLMediaLibrary`.
     This provides a stable address to use as the `context` parameter for KVO observation methods.
     */
    private var mediaSourcesContext = 1
    private var rootMediaGroupContext = 2
    private var mediaObjectsContext = 3
    
    public var loadCompletionHandler : LoadCompletionHandler?
    //public var validMediaObjects: [MLMediaObject] = []
    
    // MLMediaLibrary instances for loading the photos.
    private var mediaLibrary: MLMediaLibrary!
    private var mediaSource: MLMediaSource!
    private var rootMediaGroup: MLMediaGroup!
    
    public func asyncLoadMedia(){
        
        let loadOptions: [String : AnyObject] = [MLMediaLoadSourceTypesKey : MLMediaSourceType.image.rawValue as AnyObject,
                                                 MLMediaLoadIncludeSourcesKey : [MLMediaSourceiPhotoIdentifier] as AnyObject]
        // Create our media library instance to get our photo.
        mediaLibrary = MLMediaLibrary(options: loadOptions)
        
        // We want to be called when media sources come in that's available (via observeValueForKeyPath).
        self.mediaLibrary.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaSourcesKey, options: NSKeyValueObservingOptions.new, context: &mediaSourcesContext)
        
        // Reference returns nil but starts the asynchronous loading.
        if ((self.mediaLibrary.mediaSources) == nil){
            print("Start loading")
        }
    }
    
    deinit {
        // Make sure to remove us as an observer before "mediaLibrary" is released.
        self.mediaLibrary.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaSourcesKey, context: &mediaSourcesContext)
        print("removeObserver")
    }
    
        
    // MARK: - Photo Loading
    
    /// Observer for all key paths returned from the MLMediaLibrary.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == MLMediaLibraryPropertyKeys.mediaSourcesKey && object! is MLMediaLibrary && context == &mediaSourcesContext){
            
            // The media sources have loaded, we can access the its root media.
            
            if let mediaSource = self.mediaLibrary.mediaSources?[MLMediaSourcePhotosIdentifier] {
                self.mediaSource = mediaSource
                print("GCMediaLibraryLoader: MLMediaSourcePhotosIdentifier")
            }
            else if let mediaSource = self.mediaLibrary.mediaSources?[MLMediaSourceiPhotoIdentifier] {
                self.mediaSource = mediaSource
                //print("MLMediaSourceiPhotoIdentifier")
            }
            else {
                // Can't find any media sources.
                return  // No photos found.
            }

            // Media Library is loaded now, we can access mediaSource for photos
            self.mediaSource.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.rootMediaGroupKey, options: NSKeyValueObservingOptions.new, context: &rootMediaGroupContext)
            // Obtain the media grouping (reference returns nil but starts asynchronous loading).
            if (self.mediaSource.rootMediaGroup != nil){}
        }else if (keyPath == MLMediaLibraryPropertyKeys.rootMediaGroupKey && object! is MLMediaSource){
            // The root media group is loaded, we can access the media objects.
            
            // Done observing for media groups.
            self.mediaSource.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.rootMediaGroupKey, context: &rootMediaGroupContext)
            
            self.rootMediaGroup = self.mediaSource.rootMediaGroup
            self.rootMediaGroup.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaObjectsKey, options: NSKeyValueObservingOptions.new, context: &mediaObjectsContext)
            if (self.rootMediaGroup.mediaObjects != nil){}
        }else if (keyPath == MLMediaLibraryPropertyKeys.mediaObjectsKey && object! is MLMediaGroup){
            // The media objects are loaded, we can now finally access each photo.
            
            // Done observing for media objects that group.
            self.rootMediaGroup.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaObjectsKey, context: &mediaObjectsContext)
            
            /*
            if let childGroups = self.rootMediaGroup.childGroups{
                for (index,mediaGroup) in childGroups.enumerated() {
                    print("childGroups: \(index)")
                    print(mediaGroup.identifier)
                    print(mediaGroup.typeIdentifier)
                    //print(mediaGroup.modificationDate!)
                }
            }
            */
            print("GCMediaLibraryLoader: Load Complete")
            
            if (self.loadCompletionHandler != nil) {
                self.loadCompletionHandler!(self.rootMediaGroup.mediaObjects!)
            }
            
            // 获取数据后便移除观察
            self.mediaLibrary.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaSourcesKey, context: &mediaSourcesContext)
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }


}
