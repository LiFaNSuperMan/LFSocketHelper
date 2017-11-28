#
#  Be sure to run `pod spec lint BaseClasses.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "LFSocketHelper"
s.version      = "0.0.1"
s.summary      = "Common LFSocketHelper."
s.homepage     = "https://github.com/LiFaNSuperMan/LFSocketHelper.git"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "lifan" => "897049669@qq.com" }
s.source       = { :git => 'https://github.com/LiFaNSuperMan/LFSocketHelper.git',:tag => "0.0.1"}
s.source_files  = "LFSocketHelper/LFSocketHelper/*"
s.exclude_files = "Classes/Exclude"
s.platform = :ios, '8.0'
s.requires_arc = true
s.public_header_files = 'LFSocketHelper/LFSocketHelper/*'
s.ios.deployment_target = '8.0'

end
