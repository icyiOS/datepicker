//
//  Utils.swift
//  iDatePickerDemonstration
//
//  Created by ebuser on 2018/06/01.
//  Copyright © 2018 ebuser. All rights reserved.
//

import Foundation
import UIKit

extension TimeZone {

    static let tokyo: TimeZone = {
        return TimeZone(abbreviation: "JST")!
    }()

}

extension UIColor {
    convenience init(hex: String) {
        guard let hexInt = Int(hex, radix: 16) else {
            fatalError("Invalid hex string")
        }
        self.init(rgb: hexInt)
    }

    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(rgb: Int, alpha: CGFloat = 1) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }

    convenience init(baseColor: UIColor, alpha: CGFloat) {
        assert(alpha >= 0 && alpha <= 1, "Invalid alpha value")

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        baseColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "%06x", rgb)
    }
}

extension Date {

    var dateStringInTokyo: String {
        let formatter = DateFormatter()
        formatter.timeZone = .tokyo
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    func numberOfDaysInMonth() -> Int? {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        return range?.count
    }

    func firstWeekdayInMonth() -> Int? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.day = 1
        if let firstDayDate = Calendar.current.date(from: components) {
            return Calendar.current.component(.weekday, from: firstDayDate) - 1
        } else {
            return nil
        }
    }

}
