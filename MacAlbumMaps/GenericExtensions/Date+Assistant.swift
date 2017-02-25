//
//  Date+Assistant.swift
//  MacAlbumMaps
//
//  Created by 张保国 on 2017/2/25.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

import Foundation

let BigMonthArray = [1,3,5,7,8,10,12]
//let AutoupdatingCurrentCalendar = NSCalendar.autoupdatingCurrent

extension Date{
    
    //MARK: - 实用工具
    
    /// 查询所在月的天数
    ///
    /// - Returns: 天数
    func daysOfThisMonth() -> Int {
        let components = NSCalendar.current.dateComponents([.year,.month], from: self)
        var isBigMonth = false
        for month in BigMonthArray {
            if month == components.month {
                isBigMonth = true
            }
        }
        
        var days = 0
        
        if isBigMonth {
            days = 31
        }else if components.month != 2{
            days = 30
        }else if components.year! % 4 == 0{
            days = 29
        }else{
            days = 28
        }
        
        return days
    }
    
    //MARK: - 转化为字符串
    
    /// 以指定格式转化为字符串
    ///
    /// - Parameter format: 格式
    /// - Returns: 字符串
    func stringWithFormat(format: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    /// 以默认格式 yyyy-MM-dd hh:mm:ss 转化为字符串
    ///
    /// - Parameter format: 格式
    /// - Returns: 字符串
    func stringWithDefaultFormat() -> String {
        return self.stringWithFormat(format: "yyyy-MM-dd hh:mm:ss")
    }
    
    /// 以指定的日期、时间形式转化为字符串
    ///
    /// - Parameters:
    ///   - dateStyle: 日期形式
    ///   - timeStyle: 时间形式
    /// - Returns: 字符串
    func stringWithStyle(dateStyle: DateFormatter.Style,timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: self)
    }
    
    //MARK: - 从GPX时间字符串转化为日期
    
    /// 将格式 2007-10-14T10:10:50Z 转化为Date
    ///
    /// - Parameter timeString: GPX时间字符串
    /// - Returns: 日期
    static func dateFromGPXTimeString(timeString: String) -> Date? {
        var ts = timeString.replacingOccurrences(of: "T", with: " ")
        ts = ts.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatter.date(from: ts)
    }
}
