#
# Be sure to run `pod lib lint RxBLE.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'RxBLE'
s.version          = '0.1.0'
s.summary          = 'RxSwift wrapper around the CoreBluetooth framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

s.homepage         = 'https://github.com/dmsl1805/RxBLE'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'dmsl1805' => 'dmitriy.shulzhenko@brainbeanapps.com' }
s.source           = { :git => 'https://github.com/dmsl1805/RxBLE.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '10.0'

s.source_files = 'RxBLE/Classes/**/*'

# s.resource_bundles = {
#   'RxBLE' => ['RxBLE/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'CoreBluetooth'
s.dependency 'RxSwift'
s.dependency 'RxCocoa'
end
