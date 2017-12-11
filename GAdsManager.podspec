Pod::Spec.new do |s|
  s.name         = "GAdsManager"
  s.version      = "0.1"
  s.summary      = "GAdsManager is a library which I am refactoring to use all my iOS apps to show ads. The library is developed based on Google Mobile Ads Sdk."
  s.description  = <<-DESC
      GAdsManager is a library which I created to use all my iOS apps to show ads. The library is developed based on Google Mobile Ads Sdk. Currently I am refactoring and improving it so I am not submitting it to cocoapod yet. Basically I used customized AdManager for my different apps. In This library, I am combining all of them so that once library can handle in different kind of apps.

This GAdsManager is a loosely coupled component. So its easy to use in any iOS project. And it is also possible to replace Google AdMob by other 3rd party ad network library. As it's a loosely coupled, it doesn't need to update the ads integration code in the app just need to update GAdsManager layer.
                   DESC

  s.homepage     = "https://github.com/mahmudahsan/GAdsManager"
  s.screenshots  = "https://github.com/mahmudahsan/GAdsManager/raw/master/banner.png", "https://github.com/mahmudahsan/GAdsManager/raw/master/bannerLand.png", "https://github.com/mahmudahsan/GAdsManager/raw/master/bannerLandiPad.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Mahmud Ahsan" => "mahmud@thinkdiff.net" }
  s.social_media_url   = "http://twitter.com/mahmudahsan"
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/mahmudahsan/GAdsManager", :tag => s.version.to_s }
  s.source_files = "GAdsManager/Source/**/*.{swift}"
  s.frameworks   = "Foundation"
  
  s.dependency   = "Firebase/AdMob"
end
