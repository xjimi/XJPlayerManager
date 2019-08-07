#
# Be sure to run `pod lib lint XJPlayerManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJPlayerManager'
  s.version          = '0.0.1'
  s.summary          = 'A short description of XJPlayerManager.'
  s.homepage         = 'https://github.com/xjimi/XJPlayerManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xjimi' => 'fn5128@gmail.com' }
  s.source           = { :git => 'https://github.com/xjimi/XJPlayerManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.frameworks = 'UIKit', 'Foundation'

  s.source_files = 'XJPlayerManager/Classes/**/*'
  s.dependency 'XJUtil'
  s.dependency 'XJScrollViewStateManager'
  s.dependency 'Masonry'
  s.dependency 'YoutubePlayer-in-WKWebView'
  
  # s.resource_bundles = {
  #   'XJPlayerManager' => ['XJPlayerManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
end
