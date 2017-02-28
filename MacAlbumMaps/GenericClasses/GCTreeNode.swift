//
//  GCTreeNode.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/28.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa

class GCTreeNode: NSObject {
    override init() {
        self.children = [GCTreeNode]()
        self.isLeaf = false
        self.isTop = false
        self.title = "GCTreeNode"
        
        super.init()
    }
    
    var parent: GCTreeNode?
    var children: [GCTreeNode]
    var isLeaf: Bool
    var isTop: Bool
    var title: String
    var representedObject: Any?
    
    var numberOfChildren: Int{
        get{
            if self.isLeaf {
                return 0
            }else{
                return self.children.count
            }
        }
    }
    
    func childAtIndex(index: Int) -> GCTreeNode?{
        if self.numberOfChildren > 0 {
            return self.children[index]
        }else{
            return nil
        }
    }
    
}
