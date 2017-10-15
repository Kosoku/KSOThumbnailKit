#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KSOThumbnailKit'
  s.version          = '0.3.0'
  s.summary          = 'KSOThumbnailKit contains classes used to generate and cache thumbnail images from a variety of source URLs.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
KSOThumbnailKit contains classes used to generate and cache thumbnail images from a variety of source URLs. Support is provided for images, movies, pdfs, html, plain text, rtf and a variety of other formats. Some formats are not supported on tvOS because the WebKit framework is not available on that platform.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/KSOThumbnailKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'BSD', :file => 'license.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/KSOThumbnailKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'KSOThumbnailKit/**/*.{h,m}'
  s.exclude_files = 'KSOThumbnailKit/KSOThumbnailKit-Info.h'
  s.ios.exclude_files = 'KSOThumbnailKit/Private/macOS'
  s.tvos.exclude_files = 'KSOThumbnailKit/Private/macOS', 'KSOThumbnailKit/Private/KSOWebKitThumbnailOperation.{h,m}'
  s.private_header_files = 'KSOThumbnailKit/Private/**/*.h'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  s.ios.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'MobileCoreServices', 'WebKit'
  s.tvos.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'MobileCoreServices'
  s.osx.frameworks = 'Foundation', 'AppKit', 'AVFoundation', 'WebKit', 'QuickLook'
  
  s.dependency 'Stanley'
  s.dependency 'Ditko'
  s.dependency 'Loki'
end
