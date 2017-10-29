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

import Foundation
import GoogleMobileAds

protocol AdManagerDelegate{
    func interestialDismissed()        -> Void
    func interestialFailed()           -> Void
}

class AdManager: NSObject, GADBannerViewDelegate, GADInterstitialDelegate {
    static let sharedInstance = AdManager()
    static var interestialAdCount = 0
    
    let testDevices:[String]
    var viewController:UIViewController!
    var interestial:GADInterstitial!
    var delegate: AdManagerDelegate?
    var isInterestialLaunchAdReceived:Bool!
    var interestialAlreadyShown:Bool!
    
    let appDelegate:AppDelegate!
    
    var adView: GADBannerView?
    
    override init() {
        self.adView = nil
        isInterestialLaunchAdReceived = false
        interestialAlreadyShown       = false
        testDevices = [""]
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        super.init()
    }
    
    /*
    func loadInterestialAdLaunch(delegate: AdManagerDelegate?){
        if (!Constants.kAppAdEnabled) { return } // Exit
        if (ModelProperties.sharedInstance.isAdRemoved == true) { return } // Exit
        
        self.delegate           = delegate
        print("Interestial Launch Called", terminator: "")
        
        //check if no internet
        if (!ModelProperties.sharedInstance.isInternetAvailable()) {
            self.delegate?.interestialFailed()
            return  // Exit
        }
        
        interestial             = GADInterstitial(adUnitID: Constants.kADMOB_INTERESTIAL)
        interestial.delegate    = self
        
        let adRequest           = GADRequest()
        adRequest.testDevices   = testDevices
        interestial.load(adRequest)
    }
    
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interestial Ad Received", terminator: "")
        
        if (ad.adUnitID == Constants.kADMOB_INTERESTIAL){
            //Interestial Launch show later
            isInterestialLaunchAdReceived = true
            return //EXIT
        }
        
        //interestial.presentFromRootViewController(ModelProperties.sharedInstance.topViewController())
    }
    
    func showInterestialManually(){
        if isInterestialLaunchAdReceived == true {
            interestial.present(fromRootViewController: ModelProperties.sharedInstance.topViewController())
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("Interestial Ad Falied!", terminator: "")
        delegate?.interestialFailed()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("Interestial Ad Dismissed", terminator: "")
        delegate?.interestialDismissed()
    }
 */
}
