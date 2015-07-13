#
# Be sure to run `pod lib lint Passenger.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "PassengerApiMapper"
    s.version          = "0.1.1"
    s.summary          = "A short description of Passenger."
    s.description      = <<-DESC
                       An optional longer description of Passenger

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
    s.homepage         = "https://github.com/kellanburket/Passenger"
    s.license          = 'MIT'
    s.author           = { "Kellan Cummings" => "kellan.burket@gmail.com" }
    s.source           = { :git => "https://github.com/kellanburket/Passenger.git", :tag => s.version.to_s }

    s.platform     = :ios, '8.3'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'
    s.resource_bundles = {
        'Passenger' => ['Pod/Assets/*.png']
    }

    set_subspec = ->{ |name, subspec, path = ""|
        s.subspec name do |f|
            f.source_files =  "Classes/#{path}#{name}/*.swift"
        end
        
        unless subspec.nil?
            subspec.each do |ss_name, ss_subspec|
                set_subspec(ss_name, ss_subspec, "#{path}#{name}/")
            end
        end
    }

    {
        'Utilities': nil,
        'Http': nil,
        'Passenger': {
            'Protocols': nil,
            'Relationships': {
                'Protocols': nil
            }
            'Media': nil
        },
        'Protocols': nil,
        'Api': nil,
        'Extensions': nil,
        'Authentication': nil
    }.each do |name, subspec|
        set_subspec(name, subspec)
    end

    s.frameworks = 'UIKit'
    s.vendored_frameworks = 'Frameworks/CommonCrypto.framework'
    s.dependency 'Wildcard'
end
