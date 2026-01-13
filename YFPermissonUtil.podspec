#
# Be sure to run `pod lib lint YFPermissonUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YFPermissonUtil'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YFPermissonUtil.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
在 Swift 项目中使用：
import YFPermissonUtillet cameraUtil = YFCameraUtil.sharedcameraUtil.requestCameraPermission { result in    print(result.result)}
在 Objective-C 项目中使用：
;
#import <YFPermissonUtil/YFPermissonUtil-Swift.h>YFCameraUtil *cameraUtil = [YFCameraUtil shared];[cameraUtil requestCameraPermissionWithHandler:^(CameraResult * _Nonnull result) {    NSLog(@"Result: %d", result.result);}];
                       DESC

  s.homepage         = 'https://github.com/yanwenbo78201/YFPermissonUtil'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Computer' => 'yanwenbo78201@gmail.com' }
  s.source           = { :git => 'https://github.com/yanwenbo78201/YFPermissonUtil.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'

  s.source_files = 'YFPermissonUtil/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YFPermissonUtil' => ['YFPermissonUtil/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'Contacts', 'AddressBook', 'AVFoundation', 'CoreLocation', 'AppTrackingTransparency', 'AdSupport'
  # s.dependency 'AFNetworking', '~> 2.3'
end
