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
    s.version          = "0.1.1"
    s.summary          = "An API mapping library that handles your authorization requests(OAuth1, Basic), JSON parsing, and object instantiation, mapping your API calls to Swift models."
    s.description      = "An API mapping library that handles your authorization requests(OAuth1, Basic), JSON parsing, and object instantiation, mapping your API calls to Swift models."
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

    s.source_files = 'Pod/Classes/**/*'
    s.resource_bundles = {
        'Passenger' => [
            'Pod/Assets/*.png'
        ]
    }

    set_subspec = lambda do |name, subspec, path|
        s.subspec name do |f|
            f.source_files =  "#{path}#{name}/*.swift"
        end
        
        unless subspec.nil?
            subspec.each do |ss_name, ss_subspec|
                set_subspec.call(ss_name, ss_subspec, "#{path}#{name}/")
            end
        end
    end

    {
        'Utilities' => nil,
        'Http' => nil,
        'Passenger' => {
            'Protocols' => nil,
            'Relationships' => {
                'Protocols' => nil
            },
            'Media' => nil
        },
        'Protocols' => nil,
        'Api' => nil,
        'Extensions' => nil,
        'Authentication' => nil
    }.each do |name, subspec|
        set_subspec.call(name, subspec, "Classes/")
    end

    s.frameworks = 'UIKit'
    s.vendored_frameworks = 'Frameworks/CommonCrypto.framework'
    s.dependency 'Wildcard'
end
