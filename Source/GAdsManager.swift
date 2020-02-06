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
import UIKit
import GoogleMobileAds

enum ViewTag : Int{
    case adContainer
    case adBanner
}

public protocol AdManagerBannerDelegate{
    func adViewDidReceiveAd()
    func adViewDidFailToReceiveAd()
    func adViewWillPresentScreen()
    func adViewWillDismissScreen()
    func adViewDidDismissScreen()
    func adViewWillLeaveApplication()
}

public protocol AdManagerInterestialDelegate{
    func interestialDidReceiveAd()
    func interestialDidFailToReceiveAd()
    func interestialWillPresentScreen()
    func interestialWillDismissScreen()
    func interestialDidDismissScreen()
    func interestialWillLeaveApplication()
}

public protocol AdManagerRewardDelegate{
    func rewardAdGiveRewardToUser(type:String, amount: NSDecimalNumber)
    func rewardAdFailedToLoad()
    func rewardAdDidReceive(rewardViewController: UIViewController?)
    func rewardAdDidOpen()
    func rewardAdDidStartPlaying()
    func rewardAdDidClose()
    func rewardAdWillLeaveApplication()
}

//default implementation AdManagerBannerDelegate
public extension AdManagerBannerDelegate {
    func adViewDidReceiveAd() {}
    func adViewDidFailToReceiveAd() {}
    func adViewWillPresentScreen() {}
    func adViewWillDismissScreen() {}
    func adViewDidDismissScreen() {}
    func adViewWillLeaveApplication() {}
}

//default implementation AdManagerInterestialDelegate
public extension AdManagerInterestialDelegate {
    func interestialDidReceiveAd() {}
    func interestialDidFailToReceiveAd() {}
    func interestialWillPresentScreen() {}
    func interestialWillDismissScreen() {}
    func interestialDidDismissScreen() {}
    func interestialWillLeaveApplication() {}
}

//default implementation AdManagerRewardDelegate
public extension AdManagerRewardDelegate{
    func rewardAdGiveRewardToUser(type:String, amount: NSDecimalNumber) {}
    func rewardAdFailedToLoad() {}
    func rewardAdDidReceive(rewardViewController: UIViewController?) {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            if let rewardViewController = rewardViewController {
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: rewardViewController)
            }
        }
    }
    func rewardAdDidOpen() {}
    func rewardAdDidStartPlaying() {}
    func rewardAdDidClose() {}
    func rewardAdWillLeaveApplication() {}
}

public class AdManager: NSObject {
    public static let shared = AdManager()
    public var ADS_DISABLED = false
    public var delegateBanner: AdManagerBannerDelegate?
    public var delegateInterestial: AdManagerInterestialDelegate?
    public var delegateReward: AdManagerRewardDelegate?
    
    private var viewController:UIViewController?
    private var bannerViewContainer:UIView?
    private var rewardViewController:UIViewController?
    
    var interestial:GADInterstitial?
    private var testDevices:[String] = [""]
    private var adsInterstialDict = [String : GADInterstitial]()
    
    let borderSizeBetweenBannerAndContent:CGFloat = 5
    
    
    public override init() {
        super.init()
    }
    
    public func configureWithApp(_ id : String){
        GADMobileAds.sharedInstance().start { status in
            print("Google Mobile Ads Started: \(status)")
        }
    }
    
    public func setTestDevics(testDevices: [String]){
        self.testDevices = testDevices
        self.testDevices += [kGADSimulatorID as! String ] //all simulator
    }
    
    private func getGADRequest() -> GADRequest{
        let request = GADRequest()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = self.testDevices
        return request
    }
    
    private func createAndLoadBannerAd(unitId:String, rootViewController:UIViewController) -> GADBannerView? {
        let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.tag = ViewTag.adBanner.rawValue
        bannerView.adUnitID = unitId
        bannerView.delegate = self
        bannerView.rootViewController = rootViewController
        bannerView.load(getGADRequest())
        return bannerView
    }
    
    private func adBannerPositionUpdate(){
        guard ADS_DISABLED == false else {
            return
        }
        
        if let bannerViewContainer = self.bannerViewContainer{
            if let adBanner = bannerViewContainer.viewWithTag(ViewTag.adBanner.rawValue) {
                print("Banner Ad Accessing")
                adBanner.frame = CGRect(x: 0, y: borderSizeBetweenBannerAndContent, width: adBanner.frame.size.width, height: adBanner.frame.size.height)
                //adBanner.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
                adBanner.translatesAutoresizingMaskIntoConstraints = false
                bannerViewContainer.addConstraints(
                    [NSLayoutConstraint(item: adBanner,
                                        attribute: .firstBaseline,
                                        relatedBy: .equal,
                                        toItem: bannerViewContainer,
                                        attribute: .top,
                                        multiplier: 1,
                                        constant: borderSizeBetweenBannerAndContent),
                     NSLayoutConstraint(item: adBanner,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: bannerViewContainer,
                                        attribute: .centerX,
                                        multiplier: 1,
                                        constant: 0)
                    ])
            }
        }
    }
    
    public func adBannerHide(){
        if let bannerViewContainer = self.bannerViewContainer{
            bannerViewContainer.isHidden = true
        }
    }
    
    public func adBannerShow(){
        guard ADS_DISABLED == false else {
            return
        }
        
        if let bannerViewContainer = self.bannerViewContainer {
            bannerViewContainer.isHidden = false
        }
    }
    
    public func adBannerRemovePermanently(){
        if let bannerViewContainer = self.bannerViewContainer {
            bannerViewContainer.removeFromSuperview()
        }
    }
    
    public func createBannerAdInContainerView(viewController:UIViewController, unitId:String) {
        guard ADS_DISABLED == false else {
            return
        }
        
        self.viewController = viewController
        
        if let bannerViewContainer = self.bannerViewContainer {
            bannerViewContainer.removeFromSuperview()
            self.bannerViewContainer = nil
        }
        
        let safeAreaGap:CGFloat =    getSafeAreaGap(viewController)
        let viewHeight:CGFloat  =    UIDevice.current.userInterfaceIdiom == .pad ? 90 + borderSizeBetweenBannerAndContent : 50.0 + borderSizeBetweenBannerAndContent //iPhone or iPad banner height + 5 pixel gap
        
        let adContainerview     =   UIView(frame: CGRect.zero)
        adContainerview.tag     =   ViewTag.adContainer.rawValue
        adContainerview.frame   =   CGRect(x: 0,
                                           y: viewController.view.frame.size.height - viewHeight - safeAreaGap,
                                           width: viewController.view.frame.size.width,
                                           height: viewController.view.frame.size.height)
        adContainerview.backgroundColor = UIColor.black
        adContainerview.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleRightMargin, .flexibleWidth]
        
        self.bannerViewContainer = adContainerview
        viewController.view.addSubview(adContainerview)
        viewController.view.bringSubview(toFront: adContainerview)
        
        let bannerView = createAndLoadBannerAd(unitId: unitId, rootViewController: viewController)
        adContainerview.addSubview(bannerView!)
        adBannerPositionUpdate()
    }
    
    public func getSafeAreaGap(_ viewController: UIViewController) -> CGFloat {
        if #available(iOS 11.0, *) {
            return viewController.view.safeAreaInsets.bottom
        }
        
        return 0.0
    }
    
    // MARK:- Interestial
    public func createAndLoadInterstitial(_ adUnit: String){
        interestial = GADInterstitial(adUnitID: adUnit)
        interestial?.delegate = self
        interestial?.load(getGADRequest())
    }
    
    public func showInterestial(_ viewController: UIViewController) -> Bool{
        if let interestial = self.interestial{
            if interestial.isReady {
                interestial.present(fromRootViewController: viewController)
                return true
            }
            else {
                print("Ad wasn't ready")
            }
        }
        return false
    }
    
    // MARK:- Reward Video Ads
    public func loadAndShowRewardAd(_ adUnit: String, viewController: UIViewController){
        self.rewardViewController = viewController
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: adUnit)
    }
}

// MARK:- GADBannerViewDelegate
extension AdManager : GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        delegateBanner?.adViewDidReceiveAd()
    }
    
    /// Tells the delegate an ad request failed.
    public func adView(_ bannerView: GADBannerView,
                       didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        delegateBanner?.adViewDidFailToReceiveAd()
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        delegateBanner?.adViewWillPresentScreen()
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        delegateBanner?.adViewWillDismissScreen()
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        delegateBanner?.adViewDidDismissScreen()
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
        delegateBanner?.adViewWillLeaveApplication()
    }
}

// MARK:- GADInterstitialDelegate
extension AdManager : GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        delegateInterestial?.interestialDidReceiveAd()
    }
    
    /// Tells the delegate an ad request failed.
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        delegateInterestial?.interestialDidFailToReceiveAd()
    }
    
    /// Tells the delegate that an interstitial will be presented.
    public func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
        delegateInterestial?.interestialWillPresentScreen()
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
        delegateInterestial?.interestialWillDismissScreen()
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        delegateInterestial?.interestialDidDismissScreen()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    public func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

// MARK:- GADRewardBasedVideoAdDelegate
extension AdManager : GADRewardBasedVideoAdDelegate {
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        delegateReward?.rewardAdGiveRewardToUser(type: reward.type, amount: reward.amount)
    }
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
        delegateReward?.rewardAdFailedToLoad()
    }
    
    public func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        delegateReward?.rewardAdDidReceive(rewardViewController: self.rewardViewController)
    }
    
    public func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
        delegateReward?.rewardAdDidOpen()
    }
    
    public func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
        delegateReward?.rewardAdDidStartPlaying()
    }
    
    public func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        delegateReward?.rewardAdDidClose()
    }
    
    public func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
        delegateReward?.rewardAdWillLeaveApplication()
    }

}
