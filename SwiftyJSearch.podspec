Pod::Spec.new do |s|
  s.name        = "SwiftyJSearch"
  s.version     = "0.1.0"
  s.summary     = "Extend SwiftyJSON functionality with searching and better formatting!"
  s.homepage    = "https://github.com/seanericksonpl12/SwiftyJSearch"
  s.license     = { :type => "MIT", :file => 'LICENSE' }
  s.author      = { "Sean" => "seanericksonpl12@gmail.com" }

  s.swift_version = "5.0"
  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/seanericksonpl12/SwiftyJSearch.git", :tag => s.version }
  s.source_files = "Sources/SwiftyJSearch/*.swift"
  
  s.dependency 'SwiftyJSON', '~> 5.0.1'
end
