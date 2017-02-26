//
//  FileManager+Assistant.swift
//  MacAlbumMaps
//
//  Created by 张保国 on 2017/2/26.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Foundation

extension FileManager{
    func directoryExists(directoryPath: String,autoCreate: Bool) -> Bool {
        
        var isDirectory: ObjCBool = false
        var exists = FileManager.default.fileExists(atPath: directoryPath,isDirectory: &isDirectory)
        
        if exists && isDirectory.boolValue == true{
            return true
        }else if exists && isDirectory.boolValue == false{
            try! FileManager.default.removeItem(atPath: directoryPath)
        }
        
        if autoCreate {
            try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        exists = FileManager.default.fileExists(atPath: directoryPath,isDirectory: &isDirectory)
        
        if exists && isDirectory.boolValue == true {
            return true
        }else{
            return false
        }
    }
}
