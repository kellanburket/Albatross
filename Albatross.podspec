#
# Be sure to run `pod lib lint Albatross.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Albatross"
  s.version          = "0.1.0"
  s.summary          = "A short description of Albatross."
  s.description      = <<-DESC
                       An optional longer description of Albatross

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/kellanburket/Albatross"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Kellan Cummings" => "kellan.burket@gmail.com" }
  s.source           = { :git => "https://github.com/kellanburket/Albatross.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.3'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Albatross' => ['Pod/Assets/*.png']
  }

# s.public_header_files = 'Pod/Classes/TypeReflector.h'
  s.frameworks = 'UIKit'
  s.dependency 'Wildcard'
end
