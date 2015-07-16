#
# Be sure to run `pod lib lint Passenger.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "Passenger"
    s.version          = "1.0.1"
    s.summary          = "A object-relational mapping library for APIs"
    s.description      = "A object-relational mapping library for APIs; handles OAuth1 requests, JSON parsing, and object instantiation"
    s.homepage         = "https://github.com/kellanburket/Passenger"
    s.license          = 'MIT'
    s.author           = {
        "Kellan Cummings" => "kellan.burket@gmail.com"
    }
    s.source           = {
        :git => "https://github.com/kellanburket/Passenger.git",
        :tag => s.version.to_s
    }

    s.platform     = :ios, '8.3'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*.swift'
       
    s.frameworks = 'UIKit'
    s.vendored_frameworks = 'Frameworks/CommonCrypto.framework'
    s.dependency 'Wildcard'
end
