#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint momagic_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'momagic_flutter'
  s.version          = '0.0.2'
  s.summary          = 'The MoMagic Flutter SDK'
  s.description      = 'Allows you to easily add MoMagic to your flutter projects, to make sending and handling push notifications easy'
  s.homepage         = 'http://izooto.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Amit Kumar Gupta' => 'amit@datability.co' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
 s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.dependency 'MomagiciOSSDK'

  s.ios.deployment_target = '12.0'
  
  s.static_framework = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end