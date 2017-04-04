source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'ZFRippleButton'
pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

target 'RFduinoLedButtonInSwift' do
end
