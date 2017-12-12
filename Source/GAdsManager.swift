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

public protocol AdManagerInterestialDelegate{
    func interestialDidReceiveAd()
    func interestialDidFailToReceiveAd()
    func interestialWillPresentScreen()
    func interestialWillDismissScreen()
    func interestialDidDismissScreen()
}

public protocol AdManagerBannerDelegate{
    func adViewDidReceiveAd()
    func adViewDidFailToReceiveAd()
    func adViewWillPresentScreen()
    func adViewWillDismissScreen()
    func adViewDidDismissScreen()
}

//default implementation for optional
extension AdManagerBannerDelegate {
    func adViewDidReceiveAd() {}
    func adViewDidFailToReceiveAd() {}
    func adViewWillPresentScreen() {}
    func adViewWillDismissScreen() {}
    func adViewDidDismissScreen() {}
}

//default implementation for optional
extension AdManagerInterestialDelegate {
    func interestialDidReceiveAd() {}
    func interestialDidFailToReceiveAd() {}
    func interestialWillPresentScreen() {}
    func interestialWillDismissScreen() {}
    func interestialDidDismissScreen() {}
}

public class AdManager: NSObject {
    static let shared = AdManager()
    public var ADS_DISABLED = false
    public var bannerDelegate:AdManagerBannerDelegate?
    
    private var viewController:UIViewController?
    private var bannerViewContainer:UIView?
    
    var interestial:GADInterstitial?
    var delegateInterestial: AdManagerInterestialDelegate?
    var delegate: AdManagerBannerDelegate?
    
    private var testDevices:[String] = [""]
    private var adsInterstialDict = [String : GADInterstitial]()
    
    let borderSizeBetweenBannerAndContent:CGFloat = 5

    
    override init() {
        super.init()
    }
    
    public func configureWithApp(_ id : String){
         GADMobileAds.configure(withApplicationID: id)
    }
    
    public func setTestDevics(testDevices: [String]){
        self.testDevices = testDevices
        self.testDevices = [kGADSimulatorID as! String ] //all simulator
    }
    
    private func getGADRequest() -> GADRequest{
        let request = GADRequest()
        request.testDevices = self.testDevices
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
}

extension AdManager : GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        bannerDelegate?.adViewDidReceiveAd()
    }
    
    /// Tells the delegate an ad request failed.
    public func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerDelegate?.adViewDidFailToReceiveAd()
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        bannerDelegate?.adViewWillPresentScreen()
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        bannerDelegate?.adViewWillDismissScreen()
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        bannerDelegate?.adViewDidDismissScreen()
    }
}

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
}
