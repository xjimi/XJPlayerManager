#
# Be sure to run `pod lib lint XJPlayerManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJPlayerManager'
  s.version          = '0.0.57'
  s.summary          = 'A short description of XJPlayerManager.'
  s.homepage         = 'https://github.com/xjimi/XJPlayerManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xjimi' => 'fn5128@gmail.com' }
  s.source           = { :git => 'https://github.com/xjimi/XJPlayerManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.frameworks = 'UIKit', 'Foundation'

  s.source_files = 'XJPlayerManager/Classes/**/*'
  s.dependency 'XJUtil'
  s.dependency 'Masonry'
  s.dependency 'YoutubePlayer-in-WKWebView'
  s.dependency 'PINRemoteImage', '<= 3.0.0-beta.13'
  s.dependency 'GoogleAds-IMA-iOS-SDK', '<=3.9.0'
  s.xcconfig = {
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
      'OTHER_LDFLAGS' => '$(inherited) -framework "GoogleInteractiveMediaAds"',
      #'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**'
      #'LIBRARY_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**'
  }

  #s.subspec 'XJPlayerAdManager' do |ss|

      #ss.source_files = 'XJPlayerManager/Classes/XJPlayerAdManager/**/*.{h,m}'
      #ss.vendored_frameworks = 'XJPlayerManager/Classes/XJPlayerAdManager/Frameworks/FBAudienceNetwork.framework'
      #ss.dependency 'FBAudienceNetwork'
      #ss.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\"", "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\"",  "FRAMEWORK_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\""}
      #ss.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
      #ss.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/FBAudienceNetwork/**' }
      #https://developers.facebook.com/docs/audience-network/download/#ios

      #end

  s.resource_bundles = {
      s.name + '_resource_image' => ['XJPlayerManager/Assets/*.xcassets'],
      s.name + '_resource_xib' => ['XJPlayerManager/Classes/**/**/**/*.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
end
