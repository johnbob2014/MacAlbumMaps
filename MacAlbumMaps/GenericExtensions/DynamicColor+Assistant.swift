//
//  DynamicColor+Assistant.swift
//  MacAlbumMaps
//
//  Created by BobZhang on 2017/3/3.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import AppKit

public extension DynamicColor {
    
    class func hsb(_ hue: CGFloat,_ saturation: CGFloat,_ brightness: CGFloat, alpha: CGFloat = 1.0) -> DynamicColor {
        return DynamicColor.init(hue: hue/360.0, saturation: saturation/360.0, brightness: brightness/360.0, alpha: alpha)
    }
    
    // MARK: - Chameleon - Light Shades
    
    /// 黑色
    class var flatBlackColor: DynamicColor{
        return DynamicColor.hsb(0, 0, 17);
    }
    
    /// 蓝色
    class var flatBlueColor: DynamicColor{
        return DynamicColor.hsb(224, 50, 63);
    }
    
    /// 棕色
    class var flatBrownColor: DynamicColor{
        return DynamicColor.hsb(24, 45, 37);
    }
    
    /// 咖啡色
    class var flatCoffeeColor: DynamicColor{
        return DynamicColor.hsb(25, 31, 64);
    }
    
    /// 森林绿色
    class var flatForestGreenColor: DynamicColor{
        return DynamicColor.hsb(138, 45, 37);
    }
    
    /// 灰色
    class var flatGrayColor: DynamicColor{
        return DynamicColor.hsb(184, 10, 65);
    }
    
    /// 绿色
    class var flatGreenColor: DynamicColor{
        return DynamicColor.hsb(145, 77, 80);
    }
    
    /// 绿黄色
    class var flatLimeColor: DynamicColor{
        return DynamicColor.hsb(74, 70, 78);
    }
    
    /// 洋红色
    class var flatMagentaColor: DynamicColor{
        return DynamicColor.hsb(283, 51, 71);
    }
    
    /// 褐红色
    class var flatMaroonColor: DynamicColor{
        return DynamicColor.hsb(5, 65, 47);
    }
    
    /// 薄荷（绿）色
    class var flatMintColor: DynamicColor{
        return DynamicColor.hsb(168, 86, 74);
    }
    
    /// 海军蓝；深蓝色；藏青色
    class var flatNavyBlueColor: DynamicColor{
        return DynamicColor.hsb(210, 45, 37);
    }
    
    /// 橙色
    class var flatOrangeColor: DynamicColor{
        return DynamicColor.hsb(28, 85, 90);
    }
    
    /// 粉色
    class var flatPinkColor: DynamicColor{
        return DynamicColor.hsb(324, 49, 96);
    }
    
    /// 紫红色
    class var flatPlumColor: DynamicColor{
        return DynamicColor.hsb(300, 45, 37);
    }
    
    /// 浅灰蓝色
    class var flatPowderBlueColor: DynamicColor{
        return DynamicColor.hsb(222, 24, 95);
    }
    
    /// 紫色
    class var flatPurpleColor: DynamicColor{
        return DynamicColor.hsb(253, 52, 77);
    }
    
    /// 红色
    class var flatRedColor: DynamicColor{
        return DynamicColor.hsb(6, 74, 91);
    }
    
    /// 沙色；棕褐色
    class var flatSandColor: DynamicColor{
        return DynamicColor.hsb(42, 25, 94);
    }
    
    /// 天空蓝色
    class var flatSkyBlueColor: DynamicColor{
        return DynamicColor.hsb(204, 76, 86);
    }
    
    /// 青绿色
    class var flatTealColor: DynamicColor{
        return DynamicColor.hsb(195, 55, 51);
    }
    
    /// 西瓜（红）色
    class var flatWatermelonColor: DynamicColor{
        return DynamicColor.hsb(356, 53, 94);
    }
    
    /// 白色
    class var flatWhiteColor: DynamicColor{
        return DynamicColor.hsb(192, 2, 95);
    }
    
    /// 黄色
    class var flatYellowColor: DynamicColor{
        return DynamicColor.hsb(48, 99, 100);
    }
    
    // MARK: - Chameleon - Dark Shades
    
    ///
    class var flatBlackColorDark: DynamicColor{
        return DynamicColor.hsb(0, 0, 15);
    }
    
    ///
    class var flatBlueColorDark: DynamicColor{
        return DynamicColor.hsb(224, 56, 51);
    }
    
    ///
    class var flatBrownColorDark: DynamicColor{
        return DynamicColor.hsb(25, 45, 31);
    }
    
    ///
    class var flatCoffeeColorDark: DynamicColor{
        return DynamicColor.hsb(25, 34, 56);
    }
    
    ///
    class var flatForestGreenColorDark: DynamicColor{
        return DynamicColor.hsb(135, 44, 31);
    }
    
    ///
    class var flatGrayColorDark: DynamicColor{
        return DynamicColor.hsb(184, 10, 55);
    }
    
    ///
    class var flatGreenColorDark: DynamicColor{
        return DynamicColor.hsb(145, 78, 68);
    }
    
    ///
    class var flatLimeColorDark: DynamicColor{
        return DynamicColor.hsb(74, 81, 69);
    }
    
    ///
    class var flatMagentaColorDark: DynamicColor{
        return DynamicColor.hsb(282, 61, 68);
    }
    
    ///
    class var flatMaroonColorDark: DynamicColor{
        return DynamicColor.hsb(4, 68, 40);
    }
    
    ///
    class var flatMintColorDark: DynamicColor{
        return DynamicColor.hsb(168, 86, 63);
    }
    
    ///
    class var flatNavyBlueColorDark: DynamicColor{
        return DynamicColor.hsb(210, 45, 31);
    }
    
    ///
    class var flatOrangeColorDark: DynamicColor{
        return DynamicColor.hsb(24, 100, 83);
    }
    
    ///
    class var flatPinkColorDark: DynamicColor{
        return DynamicColor.hsb(327, 57, 83);
    }
    
    ///
    class var flatPlumColorDark: DynamicColor{
        return DynamicColor.hsb(300, 46, 31);
    }
    
    ///
    class var flatPowderBlueColorDark: DynamicColor{
        return DynamicColor.hsb(222, 28, 84);
    }
    
    ///
    class var flatPurpleColorDark: DynamicColor{
        return DynamicColor.hsb(253, 56, 64);
    }
    
    ///
    class var flatRedColorDark: DynamicColor{
        return DynamicColor.hsb(6, 78, 75);
    }
    
    ///
    class var flatSandColorDark: DynamicColor{
        return DynamicColor.hsb(42, 30, 84);
    }
    
    ///
    class var flatSkyBlueColorDark: DynamicColor{
        return DynamicColor.hsb(204, 78, 73);
    }
    
    ///
    class var flatTealColorDark: DynamicColor{
        return DynamicColor.hsb(196, 54, 45);
    }
    
    ///
    class var flatWatermelonColorDark: DynamicColor{
        return DynamicColor.hsb(358, 61, 85);
    }
    
    ///
    class var flatWhiteColorDark: DynamicColor{
        return DynamicColor.hsb(204, 5, 78);
    }
    
    ///
    class var flatYellowColorDark: DynamicColor{
        return DynamicColor.hsb(40, 100, 100);
    }
    
    class var flatColors: [DynamicColor] {
        return [DynamicColor.flatSandColor,DynamicColor.flatSandColorDark,DynamicColor.flatOrangeColorDark,DynamicColor.flatYellowColorDark,DynamicColor.flatMagentaColorDark,DynamicColor.flatTealColor,DynamicColor.flatTealColorDark,DynamicColor.flatSkyBlueColorDark,DynamicColor.flatGreenColor,DynamicColor.flatGreenColorDark,DynamicColor.flatMintColor,DynamicColor.flatMintColorDark,DynamicColor.flatForestGreenColorDark,DynamicColor.flatPurpleColor,DynamicColor.flatPurpleColorDark,DynamicColor.flatBrownColorDark,DynamicColor.flatPlumColorDark,DynamicColor.flatWatermelonColorDark,DynamicColor.flatLimeColor,DynamicColor.flatLimeColorDark,DynamicColor.flatPinkColorDark,DynamicColor.flatMaroonColor,DynamicColor.flatMaroonColorDark,DynamicColor.flatCoffeeColor,DynamicColor.flatCoffeeColorDark];
    }

    class var preferredAnnotationViewColors: [DynamicColor] {
        return [DynamicColor.flatSkyBlueColor,DynamicColor.flatPinkColor,DynamicColor.flatGrayColor,DynamicColor.flatPlumColor,DynamicColor.flatBrownColor,DynamicColor.flatForestGreenColor,DynamicColor.flatOrangeColor,DynamicColor.flatWatermelonColor];
    }
    
    class var preferredOverlayColors: [DynamicColor] {
        //不适合显示的颜色 @[DynamicColor.flatSandColor,DynamicColor.flatSandColorDark]
        return [DynamicColor.flatOrangeColorDark,DynamicColor.flatYellowColorDark,DynamicColor.flatMagentaColorDark,DynamicColor.flatTealColor,DynamicColor.flatTealColorDark,DynamicColor.flatSkyBlueColorDark,DynamicColor.flatGreenColor,DynamicColor.flatGreenColorDark,DynamicColor.flatMintColor,DynamicColor.flatMintColorDark,DynamicColor.flatForestGreenColorDark,DynamicColor.flatPurpleColor,DynamicColor.flatPurpleColorDark,DynamicColor.flatBrownColorDark,DynamicColor.flatPlumColorDark,DynamicColor.flatWatermelonColorDark,DynamicColor.flatLimeColor,DynamicColor.flatLimeColorDark,DynamicColor.flatPinkColorDark,DynamicColor.flatMaroonColor,DynamicColor.flatMaroonColorDark,DynamicColor.flatCoffeeColor,DynamicColor.flatCoffeeColorDark];
    }
    
    class func randomColor(in colors: [DynamicColor]) -> DynamicColor{
        let randomIndex = Int(arc4random()) % colors.count
        let randomColor = colors[randomIndex]
        //print("randomColor: " + randomColor.toHexString())
        return randomColor
    }
    
    class var randomFlatColor: DynamicColor {
        return DynamicColor.randomColor(in: DynamicColor.flatColors)
    }
    
}
