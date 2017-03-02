//
//  GCTreeNode.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/2/28.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Cocoa

/// 通用树节点类
class GCTreeNode: NSObject {
    
    /// 父节点
    var parent: GCTreeNode?{
        didSet{
            if let newParent = parent{
                self.tag = newParent.tag + 1
            }
        }
    }
    
    /// 可选，子节点数组，默认为空数组
    var children = [GCTreeNode]()
    
    /// 可选，节点标记，当设置父节点时，会自动设置为 parent.tag+1
    var tag = 0
    
    /// 是否为叶节点，默认为 false
    var isLeaf = false
    
    /// 可选，节点标题，默认为 GCTreeNode
    var title = "GCTreeNode"
    
    /// 可选，节点所表示的对象
    var representedObject: Any?
    
    /// 只读，子节点个数
    var numberOfChildren: Int{
        get{
            if self.isLeaf {
                return 0
            }else{
                return self.children.count
            }
        }
    }
    
    /// 按索引查找子节点
    ///
    /// - Parameter index: 索引
    /// - Returns: 子节点
    func childAtIndex(index: Int) -> GCTreeNode?{
        if self.numberOfChildren > 0 {
            return self.children[index]
        }else{
            return nil
        }
    }
    
}
