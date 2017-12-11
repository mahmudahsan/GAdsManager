Pod::Spec.new do |s|
  s.name         = "GAdsManager"
  s.version      = "1.1.4"
  s.summary      = "GAdsManager is a Google Mobile Ads Sdk based library to use all my iOS apps to show ads."
  s.description  = <<-DESC
      GAdsManager is a library which I created to use all my iOS apps to show ads. The librarsoy is developed based on Google Mobile Ads Sdk. Currently I am refactoring my old codebase and improving it to make a reusable library for all. In This library, I am combining all of the fetures over time including banner ads, interestial, reward video etc. so that onc library can handle in different kind of apps.
                      DESC

  s.homepage     = "https://github.com/mahmudahsan/GAdsManager"
  s.screenshots  = "https://github.com/mahmudahsan/GAdsManager/raw/master/banner.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Mahmud Ahsan" => "mahmud@thinkdiff.net" }
  s.social_media_url   = "http://twitter.com/mahmudahsan"
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/mahmudahsan/GAdsManager.git", :tag => s.version.to_s }
  s.source_files = "Source/**/*.{swift}"

  s.frameworks   = 'UIKit', 'Foundation', 'GoogleMobileAds'
  s.dependency     'Google-Mobile-Ads-SDK'
end
