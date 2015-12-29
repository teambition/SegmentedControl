//
//  SegmentedControl.swift
//  SegmentedControl
//
//  Created by 洪鑫 on 15/12/29.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

public enum SegmentedControlSelectionIndicatorStyle {
    case None
    case Top
    case Bottom
}

public enum SegmentedControlSelectionBoxStyle {
    case None
    case Default
}

public protocol SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int)
}

public class SegmentedControl: UIControl {
    public private(set) var selectedIndex = 0
    public var switchAnimationEnabled = true
    public var dragToSwitchEnabled = true
    
    public var selectionBoxStyle = SegmentedControlSelectionBoxStyle.None
    public var selectionBoxColor = UIColor.blueColor()
    public var selectionBoxCornerRadius: CGFloat = 0
    public var selectionBoxWidthOffset: CGFloat = 0
    
    public var selectionIndicatorStyle = SegmentedControlSelectionIndicatorStyle.None
    public var selectionIndicatorColor = UIColor.blackColor()
    public var selectionIndicatorHeight: CGFloat = 5
    public var selectionIndicatorWidthOffset: CGFloat = 0
    
    public private(set) var titles = [NSAttributedString]()
    public private(set) var selectedTitles = [NSAttributedString]()
    public private(set) var images = [UIImage]()
    public private(set) var selectedImages = [UIImage]()
    
    private var segmentWidth: CGFloat {
        get {
            if titles.count > 0 {
                return frame.width / CGFloat(titles.count)
            } else if images.count > 0 {
                return frame.width / CGFloat(images.count)
            }
            return 0
        }
    }
    
    public func initWithTitles(titles: [NSAttributedString], selectedTitles: [NSAttributedString]?) {
        
    }
    
    public func initWithImages(images: [UIImage], selectedImages: [UIImage]?) {
        
    }
    
    public func setSelected(selectedIndex selectedIndex: Int, animated: Bool) {
        
    }
}

extension SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {

    }
}
