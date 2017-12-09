/**
 *  GAdsManager
 *
 *  Copyright (c) 2017 Mahmud Ahsan. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import UIKit

enum AdIds : String {
    case banner = "ca-app-pub-3940256099942544/2934735716" // test id
    case interestial = "ca-app-pub-3940256099942544/4411468910" // test id
    /*
     https://developers.google.com/admob/ios/banner
     https://developers.google.com/admob/ios/interstitial
     */
}

let testDevices = [
    "6e429ada4c3d0bacdd26e0704df1cfff",   //iPhone 5s
    "7e511268fe0e0942360666821f6d5b92", // iPhone 6
    "ba46a538145922976119616abaac7a2e" // iPad Air 2
]

class ViewController: UIViewController {
    @IBOutlet weak var btnBanner: UIButton!
    @IBOutlet weak var btnBannerRem: UIButton!
    var adStatus: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBanner.isHidden = true
        btnBannerRem.isHidden = true
        
        //Call admanager with a delay so that safeAreaGuide value calculated correctly
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            AdManager.shared.bannerDelegate = self
            AdManager.shared.setTestDevics(testDevices: testDevices)
            AdManager.shared.createBannerAdInContainerView(viewController: self, unitId: AdIds.banner.rawValue)
        }
    }
    
    @IBAction func hideAds(_ sender: Any) {
        if adStatus {
            AdManager.shared.adBannerHide()
            adStatus = false
            let btn = sender as? UIButton
            btn?.setTitle("Show Ads", for: .normal)
        }
        else {
            AdManager.shared.adBannerShow()
            adStatus = true
            let btn = sender as? UIButton
            btn?.setTitle("Hide Ads", for: .normal)
        }
    }
    
    @IBAction func removeBannerPermanently(_ sender: Any) {
        AdManager.shared.adBannerRemovePermanently()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : AdManagerBannerDelegate {
    func adViewDidReceiveAd() {
        btnBanner.isHidden = false
        btnBannerRem.isHidden = false
    }
}

