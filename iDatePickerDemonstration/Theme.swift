//
//  Theme.swift
//  iDatePickerDemonstration
//
//  Created by ebuser on 2018/06/01.
//  Copyright © 2018 ebuser. All rights reserved.
//

import UIKit

struct GlobalColor {
    static let primaryRed = UIColor(red: 216, green: 35, blue: 42)
    static let primaryBlack = UIColor(white: 0.098, alpha: 1)

    static let viewBackgroundLightGray = UIColor(white: 0.933, alpha: 1)
    static let popUpBackground = UIColor(white: 0, alpha: 0.33)
    static let seperatorGray = UIColor(white: 0.62, alpha: 1)

    static let noDataText = UIColor(white: 0.643, alpha: 1)
    static let grayText = UIColor(white: 0.5, alpha: 1)

    static let timelineOutdated = UIColor(white: 0.5, alpha: 1)
}

struct BaseInfoColor {
    static let baseInfoViewBackground = GlobalColor.viewBackgroundLightGray
    static let baseInfoHeaderCellBackground = UIColor(white: 0.878, alpha: 1)

    static let baseInfoPickerGray = UIColor(white: 0.62, alpha: 1)
    static let baseInfoPickerBlack = UIColor.black
    static let baseInfoPickerWhite = UIColor.white
}
