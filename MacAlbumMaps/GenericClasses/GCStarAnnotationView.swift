//
//  GCStarAnnotationView.swift
//  MacAlbumMaps
//
//  Created by 张保国 on 2017/3/6.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import MapKit


/// 星标 - MKAnnotationView
class GCStarAnnotationView: MKAnnotationView {
    
    /// 星标大小，默认为1.2
    var starScale = 1.2
    
    /// 星标字符属性
    var characterAttributes: Dictionary<String,Any>{
        get{
            return [NSFontAttributeName:NSFont.systemFont(ofSize: NSFont.systemFontSize() * CGFloat(self.starScale)),
                    NSStrokeColorAttributeName:DynamicColor.red,
                    NSStrokeWidthAttributeName:2.0] as [String : Any]
        }
    }
    
    /// 星标背景颜色，默认为红色
    var starBackColor = DynamicColor.red
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.layer?.backgroundColor = DynamicColor.clear.cgColor
        let startString: NSString = "⭐️"
        let stringSize = startString.size(withAttributes: self.characterAttributes)
        let edgeLength = (stringSize.width + stringSize.height)/2.0
        self.frame = NSRect.init(x: 0, y: 0, width: edgeLength, height: edgeLength)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        if self.isSelected {
            let circleBezierPath = NSBezierPath.init(ovalIn: dirtyRect)
            circleBezierPath.lineWidth = 1.0
            self.starBackColor.setStroke()
            self.starBackColor.setFill()
            circleBezierPath.stroke()
            circleBezierPath.fill()
        }
        
        let startString: NSString = "⭐️"
        startString.draw(in: dirtyRect, withAttributes: self.characterAttributes)
    }
    
}
