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
    func interestialDidFailToReceiveAd()
    func interestialDidPresentScreen()
    func interestialDidDismissScreen()
}

public protocol AdManagerRewardDelegate{
    func rewardAdGiveRewardToUser(type:String, amount: NSDecimalNumber)
    func rewardAdFailedToLoad()
    func rewardAdDidReceive(
        rewardViewController: UIViewController?,
        rewardedAd: GADRewardedAd?,
        delegate: AdManager
    )
    func rewardAdDidOpen()
    func rewardAdDidClose()
    func rewardAdFailedToPresent()
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
    func interestialDidFailToReceiveAd() {}
    func interestialDidPresentScreen() {}
    func interestialDidDismissScreen() {}
}

//default implementation AdManagerRewardDelegate
public extension AdManagerRewardDelegate{
    func rewardAdGiveRewardToUser(type:String, amount: NSDecimalNumber) {}
    func rewardAdFailedToLoad() {}
    func rewardAdDidReceive(
        rewardViewController: UIViewController?,
        rewardedAd: GADRewardedAd?,
        delegate: AdManager
    ) {
        if let rewardedAd = rewardedAd, let rewardViewController = rewardViewController {
            rewardedAd.present(fromRootViewController: rewardViewController) {
                // give reward
                let reward = rewardedAd.adReward
                rewardAdGiveRewardToUser(type: reward.type, amount: reward.amount)
            }
        }
    }
    func rewardAdDidOpen() {}
    func rewardAdDidClose() {}
    func rewardAdFailedToPresent() {}
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
    
    var interestial:GADInterstitialAd?
    private var testDevices:[String] = [""]
    private var adsInterstialDict = [String : GADInterstitialAd]()
    
    private var rewardedAd: GADRewardedAd?
    
    let borderSizeBetweenBannerAndContent:CGFloat = 5
    
    
    public override init() {
        super.init()
    }
    
    public func configureWithApp(){
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDevices
    }
    
    public func setTestDevics(testDevices: [String]){
        self.testDevices = testDevices
        self.testDevices += [kGADSimulatorID as! String ] //all simulator
    }
    
    private func getGADRequest() -> GADRequest{
        let request = GADRequest()
        return request
    }
    
    private func createAndLoadBannerAd(unitId:String, rootViewController:UIViewController) -> GADBannerView? {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
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
        viewController.view.bringSubviewToFront(adContainerview)
        
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
        GADInterstitialAd.load(
            withAdUnitID: adUnit,
            request: getGADRequest(),
            completionHandler: { (interestialAd, error) in
                if let interstialAd = interestialAd {
                    self.interestial = interstialAd
                    self.interestial?.fullScreenContentDelegate = self
                }
                else if let error = error {
                    print("Interestial Ad Loading Error: \(error.localizedDescription)")
                    self.delegateInterestial?.interestialDidFailToReceiveAd()
                }
            }
        )
    }
    
    public func showInterestial(_ viewController: UIViewController) -> Bool {
        if let interestial = self.interestial{
            interestial.present(fromRootViewController: viewController)
            return true
        }
        return false
    }
    
    // MARK:- Reward Video Ads
    public func loadAndShowRewardAd(_ adUnit: String, viewController: UIViewController){
        self.rewardViewController = viewController
        
        GADRewardedAd.load(
            withAdUnitID: adUnit,
            request: getGADRequest()) { (rewardedAd, error) in
            if let rewardedAd = rewardedAd {
                // Ad successfully loaded.
                print("Reward based video ad is received.")
                self.rewardedAd = rewardedAd
                self.delegateReward?.rewardAdDidReceive(
                    rewardViewController: self.rewardViewController,
                    rewardedAd: self.rewardedAd,
                    delegate: self
                )
            }
            else if let error = error {
                print("Reward based video ad failed to load. \(error.localizedDescription)")
                self.delegateReward?.rewardAdFailedToLoad()
            }
        }
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
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        delegateBanner?.adViewDidFailToReceiveAd()
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        delegateBanner?.adViewWillPresentScreen()
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        delegateBanner?.adViewWillDismissScreen()
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
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
extension AdManager : GADFullScreenContentDelegate {
    /// Tells the delegate that a fullscreen ad presented.
    public func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("interstitialDidPresentScreen")
        delegateInterestial?.interestialDidPresentScreen()
    }
    
    /// Tells the delegate the fullscreen ad had been animated off the screen.
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("interstitialDidDismissScreen")
        delegateInterestial?.interestialDidDismissScreen()
    }
    
    /// Tells the delegate a fullscreen ad request failed.
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        delegateInterestial?.interestialDidFailToReceiveAd()
    }
}
