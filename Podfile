use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end

pod 'Realm'
pod 'RealmSwift'
pod 'ZFRippleButton'
pod 'Eureka'

target 'RFduinoLedButtonInSwift' do
end
