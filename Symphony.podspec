Pod::Spec.new do |s|
  s.name         = "Symphony"
  s.version      = "5.0.0"
  s.summary      = "High-level Networking And Storage Abstraction"
  s.description  = <<-DESC
                    Builds on August and ConvertibleArchiver frameworks to provide a higher-level networking and storage abstraction.
                   DESC
  s.homepage     = "https://github.com/bradhilton/Symphony"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Brad Hilton" => "brad@skyvive.com" }
  s.source       = { :git => "https://github.com/bradhilton/Symphony.git", :tag => s.version }
  s.swift_version = '5.0'

  s.ios.deployment_target = "8.0"

  s.source_files  = "Symphony", "Symphony/**/*.{swift,h,m}"
  s.requires_arc = true
  s.dependency 'AssociatedValues', '~> 5.0.0'
  s.dependency 'August', '~> 0.5.0'
  s.dependency 'ConvertibleArchiver', '~> 0.5.0'
end
