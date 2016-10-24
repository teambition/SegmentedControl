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
    @IBOutlet weak var segmentedControl3: SegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        configureNavigationTitleSegmentedControl()
        configureNavigationBelowSegmentedControl()
        configureSegmentedControl1()
        configureSegmentedControl2()
        configureSegmentedControl3()
    }
    
    fileprivate func configureNavigationTitleSegmentedControl() {
        let titleStrings = ["任务", "分享", "文件", "日程"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.darkGray]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        let segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.selectionBoxColor = kLivelyBlueColor
        segmentedControl.selectionBoxStyle = .default
        segmentedControl.selectionBoxCornerRadius = 15
        segmentedControl.frame.size = CGSize(width: 70 * titles.count, height: 30)
        segmentedControl.isLongPressEnabled = true
        segmentedControl.isUnselectedSegmentsLongPressEnabled = true
        segmentedControl.longPressMinimumPressDuration = 1
        segmentedControl.setTitleAttachedIcons([#imageLiteral(resourceName: "taskSegmentAdditionIcon")], selectedTitleAttachedIcons: [#imageLiteral(resourceName: "taskSegmentAdditionIconSelected")])
        navigationItem.titleView = segmentedControl
    }
    
    fileprivate func configureNavigationBelowSegmentedControl() {
        let titleStrings = ["任务", "分享", "文件", "日程", "账目", "标签", "通知", "聊天", "收件箱", "联系人"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: kLivelyBlueColor]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        let segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        segmentedControl.selectionIndicatorStyle = .bottom
        segmentedControl.selectionIndicatorColor = kLivelyBlueColor
        segmentedControl.selectionIndicatorHeight = 3
        segmentedControl.segmentWidth = 65
        segmentedControl.frame.origin.y = 64
        segmentedControl.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        segmentedControl.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 40)
        view.insertSubview(segmentedControl, belowSubview: navigationController!.navigationBar)
    }
    
    fileprivate func configureSegmentedControl1() {
        let titleStrings = ["任务", "分享", "文件", "日程", "聊天"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor(white: 0.1, alpha: 1)]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        segmentedControl1.setTitles(titles, selectedTitles: selectedTitles)
        segmentedControl1.delegate = self
        segmentedControl1.selectionBoxStyle = .default
        segmentedControl1.minimumSegmentWidth = 375.0 / 4.0
        segmentedControl1.selectionBoxColor = UIColor(white: 0.62, alpha: 1)
        segmentedControl1.selectionIndicatorStyle = .top
        segmentedControl1.selectionIndicatorColor = UIColor(white: 0.3, alpha: 1)
    }
    
    fileprivate func configureSegmentedControl2() {
        let images = [#imageLiteral(resourceName: "project"), #imageLiteral(resourceName: "me"), #imageLiteral(resourceName: "notification"), #imageLiteral(resourceName: "chat")]
        let selectedImages = [#imageLiteral(resourceName: "project-selected"), #imageLiteral(resourceName: "me-selected"), #imageLiteral(resourceName: "notification-selected"), #imageLiteral(resourceName: "chat-selected")]
        segmentedControl2.setImages(images, selectedImages: selectedImages)
        segmentedControl2.delegate = self
        segmentedControl2.selectionIndicatorStyle = .bottom
        segmentedControl2.selectionIndicatorColor = kLivelyBlueColor
        segmentedControl2.selectionIndicatorHeight = 3
        segmentedControl2.selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    fileprivate func configureSegmentedControl3() {
        let titleStrings = ["Tasks", "Posts", "Files", "Meetings", "Favourites", "Chats"]
        let titles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.darkGray]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        segmentedControl3.setTitles(titles, selectedTitles: selectedTitles)
        segmentedControl3.delegate = self
        segmentedControl3.layoutPolicy = .dynamic
        segmentedControl3.segmentSpacing = 5
        segmentedControl3.selectionBoxHeight = 30
        segmentedControl3.selectionHorizontalPadding = 15
        segmentedControl3.selectionBoxStyle = .default
        segmentedControl3.selectionBoxCornerRadius = 15
        segmentedControl3.selectionBoxColor = kLivelyBlueColor
        segmentedControl3.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        segmentedControl3.setTitleAttachedIcons([#imageLiteral(resourceName: "taskSegmentAdditionIcon")], selectedTitleAttachedIcons: [#imageLiteral(resourceName: "taskSegmentAdditionIconSelected")])
        segmentedControl3.titleAttachedIconPositionOffset = (5, 1)
        segmentedControl3.isLongPressEnabled = true
        segmentedControl3.isUnselectedSegmentsLongPressEnabled = true
        segmentedControl3.longPressMinimumPressDuration = 0.8
    }
}

extension ExampleViewController: SegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {
        print("Did select index \(selectedIndex)")
        switch segmentedControl.style {
        case .text:
            print("The title is “\(segmentedControl.titles[selectedIndex].string)”\n")
        case .image:
            print("The image is “\(segmentedControl.images[selectedIndex])”\n")
        }
    }

    func segmentedControl(_ segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int) {
        print("Did long press index \(longPressIndex)")
        if UIDevice.current.userInterfaceIdiom == .pad {
            let viewController = UIViewController()
            viewController.modalPresentationStyle = .popover
            viewController.preferredContentSize = CGSize(width: 200, height: 300)
            if let popoverController = viewController.popoverPresentationController {
                popoverController.sourceView = view
                let yOffset: CGFloat = 10
                popoverController.sourceRect = view.convert(CGRect(origin: CGPoint(x: 70 * CGFloat(longPressIndex), y: yOffset), size: CGSize(width: 70, height: 30)), from: navigationItem.titleView)
                popoverController.permittedArrowDirections = .any
                present(viewController, animated: true, completion: nil)
            }
        } else {
            let message = segmentedControl.style == .text ? "Long press title “\(segmentedControl.titles[longPressIndex].string)”" : "Long press image “\(segmentedControl.images[longPressIndex])”"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
