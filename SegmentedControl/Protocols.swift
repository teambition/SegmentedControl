//
//  Protocols.swift
//  SegmentedControl
//
//  Created by Xin Hong on 2016/11/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

public protocol SegmentedControlDelegate: class {
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int)
    func segmentedControl(_ segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int)
}

public extension SegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {

    }

    func segmentedControl(_ segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int) {

    }
}
