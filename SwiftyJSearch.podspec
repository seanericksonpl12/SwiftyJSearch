Pod::Spec.new do |s|
  s.name        = "SwiftyJSearch"
  s.version     = "0.1.2"
  s.summary     = "Extend SwiftyJSON functionality with searching and better debug formatting!"
  s.homepage    = "https://github.com/seanericksonpl12/SwiftyJSearch"
  s.license     = { :type => "MIT", :file => 'LICENSE' }
  s.authors      = { "lingoer" => "lingoerer@gmail.com", "tangplin" => "tangplin@gmail.com", "Sean" => "seanericksonpl12@gmail.com" }

  s.swift_version = "5.0"
  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "13.0"
  s.source   = { :git => "https://github.com/seanericksonpl12/SwiftyJSearch.git", :tag => s.version }
  s.source_files = "Sources/*/*.swift"

end
