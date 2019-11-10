require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNColorThief"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNColorThief
                   DESC
  s.homepage     = package["repository"]["baseUrl"]
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => package["author"]["name"] }
  s.platform     = :ios, "10.0"
  s.source       = { :git => package["repository"]["url"], :tag => "#{s.version}" }

  s.source_files = "ios/*.swift", "ios/*.h", "ios/*.m"
  s.requires_arc = true

  s.dependency 'React'
end

