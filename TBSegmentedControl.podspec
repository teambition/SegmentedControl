#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'TBSegmentedControl'
  s.version          = '0.3.0'
  s.summary          = 'SegmentedControl is a highly customizable segmented control for iOS applications.'
  s.description      = <<-DESC
  SegmentedControl is a highly customizable segmented control for iOS applications.
                       DESC

  s.homepage         = 'https://github.com/teambition/SegmentedControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/SegmentedControl.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'SegmentedControl/*.swift'

end
