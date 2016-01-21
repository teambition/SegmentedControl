//
//  SegmentedControl.swift
//  SegmentedControl
//
//  Created by Xin Hong on 15/12/29.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

public protocol SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int)
}

public class SegmentedControl: UIControl {
    public var delegate: SegmentedControlDelegate?
    public private(set) var selectedIndex = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var segmentWidth: CGFloat?
    public var minimumSegmentWidth: CGFloat?
    public var maximumSegmentWidth: CGFloat?
    public var animationEnabled = true
    public var userDragEnabled = true
    public private(set) var style = SegmentedControlStyle.Text

    public var selectionBoxStyle = SegmentedControlSelectionBoxStyle.None
    public var selectionBoxColor = UIColor.blueColor()
    public var selectionBoxCornerRadius: CGFloat = 0
    public var selectionBoxEdgeInsets = UIEdgeInsetsZero

    public var selectionIndicatorStyle = SegmentedControlSelectionIndicatorStyle.None
    public var selectionIndicatorColor = UIColor.blackColor()
    public var selectionIndicatorHeight = SelectionIndicator.defaultHeight
    public var selectionIndicatorEdgeInsets = UIEdgeInsetsZero

    public private(set) var titles = [NSAttributedString]()
    public private(set) var selectedTitles: [NSAttributedString]?
    public private(set) var images = [UIImage]()
    public private(set) var selectedImages: [UIImage]?

    private lazy var scrollView: SCScrollView = {
        let scrollView = SCScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private lazy var selectionBoxLayer = CALayer()
    private lazy var selectionIndicatorLayer = CALayer()

    // MARK: - Public functions
    public class func initWithTitles(titles: [NSAttributedString], selectedTitles: [NSAttributedString]?) -> SegmentedControl {
        let segmentedControl = SegmentedControl(frame: CGRectZero)
        segmentedControl.style = .Text
        segmentedControl.titles = titles
        segmentedControl.selectedTitles = selectedTitles
        return segmentedControl
    }

    public class func initWithImages(images: [UIImage], selectedImages: [UIImage]?) -> SegmentedControl {
        let segmentedControl = SegmentedControl(frame: CGRectZero)
        segmentedControl.style = .Image
        segmentedControl.images = images
        segmentedControl.selectedImages = selectedImages
        return segmentedControl
    }

    public func setTitles(titles: [NSAttributedString], selectedTitles: [NSAttributedString]?) {
        style = .Text
        self.titles = titles
        self.selectedTitles = selectedTitles
    }

    public func setImages(images: [UIImage], selectedImages: [UIImage]?) {
        style = .Image
        self.images = images
        self.selectedImages = selectedImages
    }

    public func setSelected(selectedIndex selectedIndex: Int, animated: Bool) {
        if !(0..<segmentsCount() ~= selectedIndex) {
            return
        }
        self.selectedIndex = selectedIndex
        scrollToSelectedIndex(animated: animated)
        if !animated {
            selectionBoxLayer.actions = ["position": NSNull(), "bounds": NSNull()]
            selectionIndicatorLayer.actions = ["position": NSNull(), "bounds": NSNull()]
            selectionBoxLayer.frame = frameForSelectionBox()
            selectionIndicatorLayer.frame = frameForSelectionIndicator()
        } else {
            selectionBoxLayer.actions = nil
            selectionIndicatorLayer.actions = nil
        }
    }

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        addSubview(scrollView)
        contentMode = .Redraw
        if let parentViewController = scrollView.parentViewController {
            parentViewController.automaticallyAdjustsScrollViewInsets = false
        }
    }

    // MARK: - Overriding
    public override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }

    public override var frame: CGRect {
        didSet {
            update()
        }
    }

    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview == nil {
            return
        }
        update()
    }
}

public extension SegmentedControl {
    private func update() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.frame = CGRect(origin: CGPointZero, size: frame.size)
        scrollView.scrollEnabled = userDragEnabled
        scrollView.contentSize = CGSize(width: totalSegmentsWidth(), height: frame.height)
        scrollToSelectedIndex(animated: false)
    }

    private func scrollToSelectedIndex(animated animated: Bool) {
        let rectToScroll: CGRect = {
            var rectToScroll = self.rectForSelectedIndex()
            let scrollOffset = self.frame.width / 2 - self.singleSegmentWidth() / 2
            rectToScroll.origin.x -= scrollOffset
            rectToScroll.size.width += scrollOffset * 2
            return rectToScroll
        }()
        scrollView.scrollRectToVisible(rectToScroll, animated: animated)
    }
}

public extension SegmentedControl {
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            if !CGRectContainsPoint(bounds, touchLocation) {
                return
            }
            if singleSegmentWidth() == 0 {
                return
            }
            let touchIndex = Int((touchLocation.x + scrollView.contentOffset.x) / singleSegmentWidth())
            if 0..<segmentsCount() ~= touchIndex {
                if let delegate = delegate {
                    delegate.segmentedControl(self, didSelectIndex: touchIndex)
                }
                if touchIndex != selectedIndex {
                    setSelected(selectedIndex: touchIndex, animated: animationEnabled)
                }
            }
        }
    }
}

public extension SegmentedControl {
    public override func drawRect(rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(bounds)

        scrollView.layer.sublayers?.removeAll()
        selectionBoxLayer.backgroundColor = selectionBoxColor.CGColor
        selectionIndicatorLayer.backgroundColor = selectionIndicatorColor.CGColor

        switch style {
        case .Text:
            drawTitles()
        case .Image:
            drawImages()
        }

        if selectionIndicatorStyle != .None {
            drawSelectionIndicator()
        }
        if selectionBoxStyle != .None {
            drawSelectionBox()
        }
    }

    private func drawTitles() {
        for (index, title) in titles.enumerate() {
            let titleSize = sizeForAttributedString(title)
            let xPosition: CGFloat = {
                return singleSegmentWidth() * CGFloat(index) + (singleSegmentWidth() - titleSize.width) / 2
            }()
            let yPosition: CGFloat = {
                let yPosition = (frame.height - titleSize.height) / 2
                var yPositionOffset: CGFloat = 0
                switch selectionIndicatorStyle {
                case .Top:
                    yPositionOffset = selectionIndicatorHeight / 2
                case .Bottom:
                    yPositionOffset = -selectionIndicatorHeight / 2
                default:
                    break
                }
                return round(yPosition + yPositionOffset)
            }()

            let titleRect: CGRect = {
                let titleRect = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: titleSize)
                return CGRect(x: round(titleRect.origin.x), y: round(titleRect.origin.y), width: round(titleRect.width), height: round(titleRect.height))
            }()

            let titleString: NSAttributedString = {
                if index == selectedIndex {
                    if let selectedTitle = selectedTitleWithIndex(index) {
                        return selectedTitle
                    }
                }
                return title
            }()
            let titleLayer: CATextLayer = {
                let titleLayer = CATextLayer()
                titleLayer.frame = titleRect
                titleLayer.alignmentMode = kCAAlignmentCenter
                titleLayer.truncationMode = kCATruncationEnd
                titleLayer.string = titleString
                titleLayer.contentsScale = UIScreen.mainScreen().scale
                return titleLayer
            }()
            scrollView.layer.addSublayer(titleLayer)
        }
    }

    private func drawImages() {
        for (index, image) in images.enumerate() {
            let xPosition: CGFloat = {
                return singleSegmentWidth() * CGFloat(index) + (singleSegmentWidth() - image.size.width) / 2
            }()
            let yPosition: CGFloat = {
                let yPosition = (frame.height - image.size.height) / 2
                var yPositionOffset: CGFloat = 0
                switch selectionIndicatorStyle {
                case .Top:
                    yPositionOffset = selectionIndicatorHeight / 2
                case .Bottom:
                    yPositionOffset = -selectionIndicatorHeight / 2
                default:
                    break
                }
                return round(yPosition + yPositionOffset)
            }()
            let imageRect: CGRect = {
                let imageRect = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: image.size)
                return CGRect(x: round(imageRect.origin.x), y: round(imageRect.origin.y), width: round(imageRect.width), height: round(imageRect.height))
            }()

            let contents: CGImage? = {
                if index == selectedIndex {
                    if let selectedImage = selectedImageWithIndex(index) {
                        return selectedImage.CGImage
                    }
                }
                return image.CGImage
            }()
            let imageLayer: CALayer = {
                let imageLayer = CALayer()
                imageLayer.frame = imageRect
                imageLayer.contents = contents
                return imageLayer
            }()
            scrollView.layer.addSublayer(imageLayer)
        }
    }

    private func drawSelectionBox() {
        selectionBoxLayer.frame = frameForSelectionBox()
        selectionBoxLayer.cornerRadius = selectionBoxCornerRadius
        if selectionBoxLayer.superlayer == nil {
            scrollView.layer.insertSublayer(selectionBoxLayer, atIndex: 0)
        }
    }

    private func drawSelectionIndicator() {
        selectionIndicatorLayer.frame = frameForSelectionIndicator()
        if selectionBoxLayer.superlayer == nil {
            if let _ = selectionIndicatorLayer.superlayer {
                scrollView.layer.insertSublayer(selectionIndicatorLayer, above: selectionBoxLayer)
            } else {
                scrollView.layer.insertSublayer(selectionIndicatorLayer, atIndex: 0)
            }
        }
    }
}

public extension SegmentedControl {
    private func sizeForAttributedString(attributedString: NSAttributedString) -> CGSize {
        let size = attributedString.size()
        return CGRectIntegral(CGRect(origin: CGPointZero, size: size)).size
    }

    private func selectedImageWithIndex(index: Int) -> UIImage? {
        if let selectedImages = selectedImages {
            if 0..<selectedImages.count ~= index {
                return selectedImages[index]
            }
        }
        return nil
    }

    private func selectedTitleWithIndex(index: Int) -> NSAttributedString? {
        if let selectedTitles = selectedTitles {
            if 0..<selectedTitles.count ~= index {
                return selectedTitles[index]
            }
        }
        return nil
    }

    private func segmentsCount() -> Int {
        switch style {
        case .Text:
            return titles.count
        case .Image:
            return images.count
        }
    }

    private func frameForSelectionBox() -> CGRect {
        if selectionBoxStyle == .None {
            return CGRectZero
        }

        let xPosition: CGFloat = {
            return singleSegmentWidth() * CGFloat(selectedIndex)
        }()
        let fullRect = CGRect(x: xPosition, y: 0, width: singleSegmentWidth(), height: frame.height)
        let boxRect = CGRect(x: fullRect.origin.x + selectionBoxEdgeInsets.left,
            y: fullRect.origin.y + selectionBoxEdgeInsets.top,
            width: fullRect.width - (selectionBoxEdgeInsets.left + selectionBoxEdgeInsets.right),
            height: fullRect.height - (selectionBoxEdgeInsets.top + selectionBoxEdgeInsets.bottom))
        return boxRect
    }

    private func frameForSelectionIndicator() -> CGRect {
        if selectionIndicatorStyle == .None {
            return CGRectZero
        }

        let xPosition: CGFloat = {
            return singleSegmentWidth() * CGFloat(selectedIndex)
        }()
        let yPosition: CGFloat = {
            switch selectionIndicatorStyle {
            case .Bottom:
                return frame.height - selectionIndicatorHeight
            case .Top:
                return 0
            default:
                return 0
            }
        }()
        let fullRect = CGRect(x: xPosition, y: yPosition, width: singleSegmentWidth(), height: selectionIndicatorHeight)
        let indicatorRect = CGRect(x: fullRect.origin.x + selectionIndicatorEdgeInsets.left,
            y: fullRect.origin.y + selectionIndicatorEdgeInsets.top,
            width: fullRect.width - (selectionIndicatorEdgeInsets.left + selectionIndicatorEdgeInsets.right),
            height: fullRect.height - (selectionIndicatorEdgeInsets.top + selectionIndicatorEdgeInsets.bottom))
        return indicatorRect
    }

    private func rectForSelectedIndex() -> CGRect {
        return CGRect(x: singleSegmentWidth() * CGFloat(selectedIndex), y: 0, width:singleSegmentWidth() , height: frame.height)
    }

    private func singleSegmentWidth() -> CGFloat {
        func defaultSegmentWidth() -> CGFloat {
            if segmentsCount() == 0 {
                return 0
            }
            var segmentWidth = frame.width / CGFloat(segmentsCount())
            if let minimumSegmentWidth = minimumSegmentWidth {
                if segmentWidth < minimumSegmentWidth {
                    segmentWidth = minimumSegmentWidth
                }
            }
            if let maximumSegmentWidth = maximumSegmentWidth {
                if segmentWidth > maximumSegmentWidth {
                    segmentWidth = maximumSegmentWidth
                }
            }
            return segmentWidth
        }

        if let segmentWidth = segmentWidth {
            return segmentWidth
        }
        return defaultSegmentWidth()
    }

    private func totalSegmentsWidth() -> CGFloat {
        return CGFloat(segmentsCount()) * singleSegmentWidth()
    }
}

public extension SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {

    }
}
