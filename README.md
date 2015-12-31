#SegmentedControl
SegmentedControl is a highly customizable segmented control for  iOS applications. 

![Example](Gif/SegmentedControlExample.gif "SegmentedControlExample")

##How To Get Started
###Carthage
Specify "SegmentedControl" in your Cartfile:
```ogdl 
github "teambition/SegmentedControl"
```

###Usage
#####  Text
```swift
let titles: [NSAttributedString] = ...
let selectedTitles: [NSAttributedString] = ...

// for storyboard
segmentedControl.setTitles(titles, selectedTitles: selectedTitles)
// programmatically
let segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)

// assign delegate
segmentedControl.delegate = self

// configure selection box if needed, the default style is 'None'
segmentedControl.selectionBoxStyle = .Default
segmentedControl.selectionBoxColor = UIColor(white: 0.62, alpha: 1)
segmentedControl.selectionBoxCornerRadius = 15 // default is 0
segmentedControl.selectionBoxEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20) // default is UIEdgeInsetsZero

// configure selection indicator if needed, the default style is 'None'
segmentedControl.selectionIndicatorStyle = .Top
segmentedControl.selectionIndicatorColor = UIColor(white: 0.3, alpha: 1)
segmentedControl.selectionIndicatorHeight = 3 // default is 5
segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20) // default is UIEdgeInsetsZero
```

#####  Image
```swift
let images = ...
let selectedImages = ...

// for storyboard
segmentedControl.setImages(images, selectedImages: selectedImages)
// programmatically
let segmentedControl = SegmentedControl.initWithImages(images, selectedImages: selectedImages)

// assign delegate
segmentedControl.delegate = self

// configure selection box if needed, the default style is 'None'
segmentedControl.selectionBoxStyle = .Default
segmentedControl.selectionBoxColor = UIColor.lightGrayColor()
segmentedControl.selectionBoxCornerRadius = 15 // default is 0
segmentedControl.selectionBoxEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20) // default is UIEdgeInsetsZero

// configure selection indicator if needed, the default style is 'None'
segmentedControl.selectionIndicatorStyle = .Bottom
segmentedControl.selectionIndicatorColor = UIColor.darkGrayColor()
segmentedControl.selectionIndicatorHeight = 3 // default is 5
segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20) // default is UIEdgeInsetsZero
```

#####  Implement delegate
```swift
func segmentedControl(segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {
    // do something
}
```

## Minimum Requirement
iOS 8.0

## Release Notes
* [Release Notes](https://github.com/teambition/SegmentedControl/releases)

## License
SegmentedControl is released under the MIT license. See [LICENSE](https://github.com/teambition/SegmentedControl/blob/master/LICENSE.md) for details.

## More Info
Have a question? Please [open an issue](https://github.com/teambition/SegmentedControl/issues/new)!
