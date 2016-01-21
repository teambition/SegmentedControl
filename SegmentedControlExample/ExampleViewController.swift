//
//  ExampleViewController.swift
//  SegmentedControlExample
//
//  Created by 洪鑫 on 15/12/29.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit
import SegmentedControl

private let kLivelyBlueColor = UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)

class ExampleViewController: UIViewController {
    @IBOutlet weak var segmentedControl1: SegmentedControl!
    @IBOutlet weak var segmentedControl2: SegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        configureNavigationTitleSegmentedControl()
        configureNavigationBelowSegmentedControl()
        configureSegmentedControl1()
        configureSegmentedControl2()
    }
    
    private func configureNavigationTitleSegmentedControl() {
        let titleStrings = ["任务", "分享", "文件", "日程"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        let segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.clearColor()
        segmentedControl.selectionBoxColor = kLivelyBlueColor
        segmentedControl.selectionBoxStyle = .Default
        segmentedControl.selectionBoxCornerRadius = 15
        segmentedControl.frame.size = CGSize(width: 70 * titles.count, height: 30)
        navigationItem.titleView = segmentedControl
    }
    
    private func configureNavigationBelowSegmentedControl() {
        let titleStrings = ["任务", "分享", "文件", "日程", "账目", "标签", "通知", "聊天", "收件箱", "联系人"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.blackColor()]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: kLivelyBlueColor]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        let segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.autoresizingMask = [.FlexibleRightMargin, .FlexibleWidth]
        segmentedControl.selectionIndicatorStyle = .Bottom
        segmentedControl.selectionIndicatorColor = kLivelyBlueColor
        segmentedControl.selectionIndicatorHeight = 3
        segmentedControl.segmentWidth = 65
        segmentedControl.frame.origin.y = 64
        segmentedControl.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: 40)
        view.insertSubview(segmentedControl, belowSubview: navigationController!.navigationBar)
    }
    
    private func configureSegmentedControl1() {
        let titleStrings = ["任务", "分享", "文件", "日程", "聊天"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor(white: 0.1, alpha: 1)]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        segmentedControl1.setTitles(titles, selectedTitles: selectedTitles)
        segmentedControl1.delegate = self
        segmentedControl1.selectionBoxStyle = .Default
        segmentedControl1.minimumSegmentWidth = 375.0 / 4.0
        segmentedControl1.selectionBoxColor = UIColor(white: 0.62, alpha: 1)
        segmentedControl1.selectionIndicatorStyle = .Top
        segmentedControl1.selectionIndicatorColor = UIColor(white: 0.3, alpha: 1)
    }
    
    private func configureSegmentedControl2() {
        let images = [UIImage(named: "project")!, UIImage(named: "me")!, UIImage(named: "notification")!, UIImage(named: "chat")!]
        let selectedImages = [UIImage(named: "project-selected")!, UIImage(named: "me-selected")!, UIImage(named: "notification-selected")!, UIImage(named: "chat-selected")!]
        segmentedControl2.setImages(images, selectedImages: selectedImages)
        segmentedControl2.delegate = self
        segmentedControl2.selectionIndicatorStyle = .Bottom
        segmentedControl2.selectionIndicatorColor = kLivelyBlueColor
        segmentedControl2.selectionIndicatorHeight = 3
        segmentedControl2.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20)
    }
}

extension ExampleViewController: SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {
        print("Did select index \(selectedIndex)")
        switch segmentedControl.style {
        case .Text:
            print("The title is “\(segmentedControl.titles[selectedIndex].string)”\n")
        case .Image:
            print("The image is “\(segmentedControl.images[selectedIndex])”\n")
        }
    }
}
