# GAdsManager
<p align="center">
    <img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="swift 4.0" />
    <a href="https://twitter.com/mahmudahsan">
        <img src="https://img.shields.io/badge/contact%40-mahmudahsan-green.svg" alt="Twitter: @mahmudahsan" />
    </a>
</p>

<p>
GAdsManager is a library which I created to use all my iOS apps to show ads. The librarsoy is developed based on Google Mobile Ads Sdk. Currently I am refactoring my old codebase and improving it to make a reusable library for all. In This library, I am combining all of the fetures over time including banner ads, interestial, reward video etc. so that onc library can handle in different kind of apps.  
</p>
<p>
This GAdsManager is a loosely coupled component. So its easy to use in any iOS project. And it is also possible to replace Google AdMob by other 3rd party ad network library. As it's a loosely coupled, it doesn't need to update the ads integration code in the app just need to update GAdsManager layer.
</p>

## Features [ Version 0.1 ]

- [X] Loosely coupled component
- [X] Banner ads following Google AdMob Guideline
- [X] Banner ads with 5 pixel black border above 
- [X] Banner ads automatically adjust for portrait and landscape
- [X] Banner ads works on both iPhone and iPad

## Upcoming Features

-> Interestial Ads <br />
-> Reward Video Ads


<p align="center">
    <img src="banner.png" width="700" alt="Banner Bottom" />
    <img src="bannerLand.png" width="700" alt="Banner Bottom Landscape" />
    <img src="bannerLandiPad.png" width="800" alt="Banner Bottom iPad Landscape" />
    <img src="bannerPortraitiPad.png" width="500"  alt="Banner Bottom iPad Portrait" />
</p>	

## Examples

Integrate bottom banner ads within a UIViewController via code:
```swift
import UIKit

enum AdIds : String {
    case banner = "ca-app-pub-3940256099942544/2934735716" // test id
    case interestial = "ca-app-pub-3940256099942544/4411468910" // test id
}

let testDevices = [
    "XX",   //iPhone 5s
    "YY", // iPhone 6
]

//Call admanager with a delay so that safeAreaGuide value calculated correctly
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
    AdManager.shared.bannerDelegate = self
    AdManager.shared.setTestDevics(testDevices: testDevices)
    AdManager.shared.createBannerAdInContainerView(viewController: self, unitId: AdIds.banner.rawValue)
}

```
Get notification when banner ad received or failed by implementing the protocol and by setting the delegate:
```swift
public protocol AdManagerBannerDelegate{
    func adViewDidReceiveAd()
    func adViewDidFailToReceiveAd()
    func adViewWillPresentScreen()
    func adViewWillDismissScreen()
    func adViewDidDismissScreen()
}
```

## Usage in an iOS application

Either

- Drag the folders GAdsManager/Source folder into your application's Xcode project. 

## Questions or feedback?

Feel free to [open an issue](https://github.com/mahmudahsan/AppsPortfolio/issues/new), or find me [@mahmudahsan on Twitter](https://twitter.com/mahmudahsan).
