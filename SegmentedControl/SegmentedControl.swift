//
//  SegmentedControl.swift
//  SegmentedControl
//
//  Created by Xin Hong on 15/12/29.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

public protocol SegmentedControlDelegate: class {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int)
    func segmentedControl(segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int)
}

public class SegmentedControl: UIControl {
    public weak var delegate: SegmentedControlDelegate?
    public var layoutPolicy: SegmentedControlLayoutPolicy = .fixed

    public private(set) var selectedIndex = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// Only available in dynamic layout policy
    public var segmentSpacing: CGFloat = 0
    /// Only available in dynamic layout policy
    public var selectionBoxHeight: CGFloat = 0
    /// Only available in dynamic layout policy
    public var selectionHorizontalPadding: CGFloat = Constant.defaultSelectionHorizontalPadding
    /// Only available in dynamic layout policy, only the left and right inset works, the top and bottom inset will be ignored.
    public var contentInset = UIEdgeInsetsZero
    
    /// Only available in fixed layout policy

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
    public var titleAttachedIconPositionOffset: (x: CGFloat , y: CGFloat ) = (0, 0)

    public private(set) var titles = [NSAttributedString]() {
        didSet {
            titleSizes = titles.map { sizeForAttributedString($0) }
        }
    }

    public private(set) var selectedTitles: [NSAttributedString]?
    public private(set) var images = [UIImage]()
    public private(set) var selectedImages: [UIImage]?
    public private(set) var titleAttachedIcons: [UIImage]?
    public private(set) var selectedTitleAttachedIcons: [UIImage]?
    private var titleSizes = [CGSize]()


    public var longPressEnabled = false {
        didSet {
            if longPressEnabled {
                longPressGesture = UILongPressGestureRecognizer()
                longPressGesture!.addTarget(self, action: #selector(segmentedControlLongPressed(_:)))
                longPressGesture!.minimumPressDuration = longPressMinimumPressDuration
                scrollView.addGestureRecognizer(longPressGesture!)
                longPressGesture!.delegate = self
            } else if let _ = longPressGesture {
                scrollView.removeGestureRecognizer(longPressGesture!)
                longPressGesture!.delegate = nil
                longPressGesture = nil
            }
        }
    }
    public var unselectedSegmentsLongPressEnabled = false
    public var longPressMinimumPressDuration: CFTimeInterval = 0.5 {
        didSet {
            assert(longPressMinimumPressDuration >= 0.5, "MinimumPressDuration of LongPressGestureRecognizer must be no less than 0.5")
            if let longPressGesture = longPressGesture {
                longPressGesture.minimumPressDuration = longPressMinimumPressDuration
            }
        }
    }
    public private(set) var longPressActivated = false
    
    public var scrollContentInset: UIEdgeInsets {
        return scrollView.contentInset
    }
    public var scrollContentSize: CGSize {
        return scrollView.contentSize
    }
    public var scrollContentOffset: CGPoint {
        return scrollView.contentOffset
    }


    private lazy var scrollView: SCScrollView = {
        let scrollView = SCScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private lazy var selectionBoxLayer = CALayer()
    private lazy var selectionIndicatorLayer = CALayer()
    private var longPressGesture: UILongPressGestureRecognizer?

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

    public func setTitleAttachedIcons(titleAttachedIcons: [UIImage]?, selectedTitleAttachedIcons: [UIImage]?) {
        self.titleAttachedIcons = titleAttachedIcons
        self.selectedTitleAttachedIcons = selectedTitleAttachedIcons
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
    
    public func rectForSegment(at index: Int) -> CGRect? {
        guard 0..<segmentsCount() ~= index else {
            return nil
        }
        switch layoutPolicy {
        case .fixed:
            return CGRect(x: singleSegmentWidth() * CGFloat(index),
                          y: 0,
                          width: singleSegmentWidth(),
                          height: frame.height)
        case .dynamic:
            let frontWidths = totalSegmentsWidths(before: index)
            return CGRect(x: contentInset.left + frontWidths.reduce(0, combine: +) + segmentSpacing * CGFloat(frontWidths.count),
                          y: 0,
                          width: singleSegmentWidth(at: index),
                          height: frame.height)
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
//        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.frame = CGRect(origin: CGPointZero, size: frame.size)
        scrollView.scrollEnabled = userDragEnabled
//        scrollView.contentSize = CGSize(width: totalSegmentsWidth(), height: frame.height)
        switch layoutPolicy {
        case .fixed:
            scrollView.contentSize = CGSize(width: totalSegmentsWidth(), height: frame.height)
            scrollView.contentInset = UIEdgeInsetsZero
        case .dynamic:
            scrollView.contentSize = CGSize(width: totalSegmentsWidth() + contentInset.left + contentInset.right, height: frame.height)
            if (totalSegmentsWidth() + contentInset.left + contentInset.right) < frame.width {
                let padding = (frame.width - totalSegmentsWidth()) / 2
                scrollView.contentInset = UIEdgeInsets(top: 0, left: padding - contentInset.left, bottom: 0, right: padding - contentInset.right)
            } else {
                scrollView.contentInset = UIEdgeInsetsZero
            }
        }

        
        scrollToSelectedIndex(animated: false)
    }

    private func scrollToSelectedIndex(animated animated: Bool) {
        if layoutPolicy == .dynamic && (totalSegmentsWidth() + contentInset.left + contentInset.right) < frame.width {
            return
        }
        

        let rectToScroll: CGRect = {
            var rectToScroll = self.rectForSelectedIndex()
//            let scrollOffset = self.frame.width / 2 - self.singleSegmentWidth() / 2
            let scrollOffset: CGFloat = {
                switch layoutPolicy {
                case .fixed:
                    return frame.width / 2 - singleSegmentWidth() / 2
                case .dynamic:
                    return frame.width / 2 - singleSegmentWidth(at: selectedIndex) / 2
                }
            }()

            rectToScroll.origin.x -= scrollOffset
            rectToScroll.size.width += scrollOffset * 2
            return rectToScroll
        }()
        scrollView.scrollRectToVisible(rectToScroll, animated: animated)
    }
    
    private func evaluateTouchIndex(fromTouchLocation touchLocation: CGPoint) -> Int? {
        func startX(index: Int) -> CGFloat {
            return contentInset.left + totalSegmentsWidths(before: index).reduce(0, combine: +) + segmentSpacing * CGFloat(index)
        }
        func endX(index: Int) -> CGFloat {
            return startX(index) + singleSegmentWidth(at: index)
        }
        
        guard bounds.contains(touchLocation) else {
            return nil
        }
        
        switch layoutPolicy {
        case .fixed:
            if singleSegmentWidth() == 0 {
                return nil
            }
            let touchIndex = Int((touchLocation.x + scrollView.contentOffset.x) / singleSegmentWidth())
            return touchIndex
        case .dynamic:
            let touchX = touchLocation.x + scrollView.contentOffset.x
            var maxIndex = segmentsCount() - 1
            var minIndex = 0
            
            if startX(minIndex)...endX(minIndex) ~= touchX {
                return minIndex
            } else if startX(maxIndex)...endX(maxIndex) ~= touchX {
                return maxIndex
            } else {
                while (maxIndex - minIndex) / 2 > 0 {
                    let midIndex = minIndex + (maxIndex - minIndex) / 2
                    
                    if startX(minIndex)...endX(minIndex) ~= touchX {
                        return minIndex
                    } else if startX(maxIndex)...endX(maxIndex) ~= touchX {
                        return maxIndex
                    } else if startX(midIndex)...endX(midIndex) ~= touchX {
                        return midIndex
                    } else if touchX < startX(midIndex) {
                        maxIndex = midIndex
                    } else {
                        minIndex = midIndex
                    }
                }
            }
            return nil
        }
    }

}

public extension SegmentedControl {
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !longPressActivated else {
            return
        }
        guard let touch = touches.first else {

            return
        }

//        if let touch = touches.first {
//            let touchLocation = touch.locationInView(self)
//            if !CGRectContainsPoint(bounds, touchLocation) {
//                return
//            }
//            if singleSegmentWidth() == 0 {
//                return
//            }
//            let touchIndex = Int((touchLocation.x + scrollView.contentOffset.x) / singleSegmentWidth())
//            if 0..<segmentsCount() ~= touchIndex {
//                if let delegate = delegate {
//                    delegate.segmentedControl(self, didSelectIndex: touchIndex)
//                }
//                if touchIndex != selectedIndex {
//                    setSelected(selectedIndex: touchIndex, animated: animationEnabled)
//                }
        let touchLocation = touch.locationInView(self)
        guard let touchIndex = evaluateTouchIndex(fromTouchLocation: touchLocation) else {
            return
        }
        
        if 0..<segmentsCount() ~= touchIndex {
            delegate?.segmentedControl(self, didSelectIndex: touchIndex)
            if touchIndex != selectedIndex {
                setSelected(selectedIndex: touchIndex, animated: animationEnabled)

            }
        }
    }
}

extension SegmentedControl: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == longPressGesture {
            if let longPressIndex = locationIndexForGesture(gestureRecognizer) {
                return unselectedSegmentsLongPressEnabled ? true : longPressIndex == selectedIndex
            }
        }
        return false
    }

    func segmentedControlLongPressed(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .Possible:
            print("LongPressGesture Possible!")
            break
        case .Began:
            print("LongPressGesture Began!")
            longPressActivated = true
            longPressDidBegin(gesture)
            break
        case .Changed:
            print("LongPressGesture Changed!")
            break
        case .Ended:
            print("LongPressGesture Ended!")
            longPressActivated = false
            break
        case .Cancelled:
            print("LongPressGesture Cancelled!")
            longPressActivated = false
            break
        case .Failed:
            print("LongPressGesture Failed!")
            longPressActivated = false
            break
        }
    }

    private func locationIndexForGesture(gesture: UIGestureRecognizer) -> Int? {
        let longPressLocation = gesture.locationInView(self)
        if !CGRectContainsPoint(bounds, longPressLocation) {
            return nil
        }
        if singleSegmentWidth() == 0 {
            return nil
        }
        let longPressIndex = Int((longPressLocation.x + scrollView.contentOffset.x) / singleSegmentWidth())
        return longPressIndex
    }

    private func longPressDidBegin(gesture: UIGestureRecognizer) {
        if let longPressIndex = locationIndexForGesture(gesture) {
            if longPressIndex != selectedIndex && !unselectedSegmentsLongPressEnabled {
                return
            }
            if 0..<segmentsCount() ~= longPressIndex {
                if let delegate = delegate {
                    delegate.segmentedControl(self, didLongPressIndex: longPressIndex)
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
            let attachedIcon = index == selectedIndex ? selectedTitleAttachedIconWithIndex(index) : titleAttachedIconWithIndex(index)
            var attachedIconRect = CGRectZero

            let titleRect: CGRect = {
                var titleRect = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: titleSize)

                if let attachedIcon = attachedIcon {
                    let addedWidth = attachedIcon.size.width + titleAttachedIconPositionOffset.x
                    titleRect.origin.x -= addedWidth / 2

                    let xPositionOfAttachedIcon = titleRect.origin.x + titleRect.width + titleAttachedIconPositionOffset.x
                    let yPositionOfAttachedIcon: CGFloat = {
                        let yPositionOfAttachedIcon = (frame.height - attachedIcon.size.height) / 2
                        var yPositionOffset = titleAttachedIconPositionOffset.y
                        switch selectionIndicatorStyle {
                        case .Top:
                            yPositionOffset += selectionIndicatorHeight / 2
                        case .Bottom:
                            yPositionOffset += -selectionIndicatorHeight / 2
                        default:
                            break
                        }
                        return round(yPositionOfAttachedIcon + yPositionOffset)
                    }()
                    attachedIconRect = CGRect(x: round(xPositionOfAttachedIcon), y: round(yPositionOfAttachedIcon), width: round(attachedIcon.size.width), height: round(attachedIcon.size.height))
                }

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
                if #available(iOS 10.0, *) {
                    titleLayer.truncationMode = kCATruncationNone
                } else {
                    titleLayer.truncationMode = kCATruncationEnd
                }
                titleLayer.string = titleString
                titleLayer.contentsScale = UIScreen.mainScreen().scale
                return titleLayer
            }()

            if let attachedIcon = attachedIcon {
                let attachedIconLayer = CALayer()
                attachedIconLayer.frame = attachedIconRect
                attachedIconLayer.contents = attachedIcon.CGImage
                scrollView.layer.addSublayer(attachedIconLayer)
            }

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

    private func titleAttachedIconWithIndex(index: Int) -> UIImage? {
        if let titleAttachedIcons = titleAttachedIcons {
            if 0..<titleAttachedIcons.count ~= index {
                return titleAttachedIcons[index]
            }
        }
        return nil
    }

    private func selectedTitleAttachedIconWithIndex(index: Int) -> UIImage? {
        if let selectedTitleAttachedIcons = selectedTitleAttachedIcons {
            if 0..<selectedTitleAttachedIcons.count ~= index {
                return selectedTitleAttachedIcons[index]
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
//        return CGRect(x: singleSegmentWidth() * CGFloat(selectedIndex), y: 0, width:singleSegmentWidth() , height: frame.height)
        switch layoutPolicy {
        case .fixed:
            return CGRect(x: singleSegmentWidth() * CGFloat(selectedIndex), y: 0, width: singleSegmentWidth(), height: frame.height)
        case .dynamic:
            let frontWidths = totalSegmentsWidths(before: selectedIndex)
            let xPosition = contentInset.left + frontWidths.reduce(0, combine: +) + segmentSpacing * CGFloat(frontWidths.count)
            return CGRect(x: xPosition, y: 0, width: singleSegmentWidth(at: selectedIndex), height: frame.height)
        }

    }

    private func singleSegmentWidth(at index: Int? = nil) -> CGFloat {

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

//        if let segmentWidth = segmentWidth {
        switch layoutPolicy {
        case .fixed:
            if let segmentWidth = segmentWidth {
                return segmentWidth
            }
            return defaultSegmentWidth()
        case .dynamic:
            guard let index = index where 0..<titleSizes.count ~= index else {
                return 0
            }
            var segmentWidth = titleSizes[index].width + selectionHorizontalPadding * 2
            if let attachedIcon = titleAttachedIconWithIndex(index) {
                segmentWidth += attachedIcon.size.width + titleAttachedIconPositionOffset.x
            }

            return segmentWidth
        }
//        return defaultSegmentWidth()
    }

    private func totalSegmentsWidth() -> CGFloat {
//        return CGFloat(segmentsCount()) * singleSegmentWidth()
        switch layoutPolicy {
        case .fixed:
            return CGFloat(segmentsCount()) * singleSegmentWidth()
        case .dynamic:
            let segmentsWidths = titleSizes.enumerate().map { singleSegmentWidth(at: $0.index) }
            return segmentsWidths.reduce(0, combine: +) + segmentSpacing * CGFloat(segmentsWidths.count - 1)
        }
    }
    
    private func totalSegmentsWidths(before index: Int) -> [CGFloat] {
        switch layoutPolicy {
        case .fixed:
            return Array(count: index, repeatedValue: singleSegmentWidth())
        case .dynamic:
            return titleSizes[0..<index].enumerate().map { singleSegmentWidth(at: $0.index) }
        }

    }
}

public extension SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {

    }

    func segmentedControl(segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int) {

    }
}
