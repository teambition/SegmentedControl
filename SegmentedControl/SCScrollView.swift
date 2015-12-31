//
//  SCScrollView.swift
//  SegmentedControl
//
//  Created by Xin Hong on 15/12/30.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

class SCScrollView: UIScrollView {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesBegan(touches, withEvent: event)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesMoved(touches, withEvent: event)
        } else {
            super.touchesMoved(touches, withEvent: event)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesEnded(touches, withEvent: event)
        } else {
            super.touchesEnded(touches, withEvent: event)
        }
    }
}

extension SCScrollView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
