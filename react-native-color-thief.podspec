require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-color-thief"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['repository']['url']
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/Ludus-Team/react-native-color-thief", :tag => "v#{s.version}" }
  s.source_files  = "ios/*.{h,m,swift}"

  s.dependency 'React'
end
