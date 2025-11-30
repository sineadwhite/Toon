//
//  NewsVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import SVPullToRefresh
import GoogleMobileAds

class NewsVC: UIViewController  {
    @IBOutlet weak var tableNews: UITableView!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    
    fileprivate var activity = UIActivityIndicatorView()
    fileprivate var listAllFeatureNews = [NewsData]()
    fileprivate var count = 1
    var catId = Int()
    var viewTitle = String()
    var searchText = String()
    var isRoot = false
    var deviceLanguage = ""
    
    fileprivate var listAds = [GADUnifiedNativeAd]()
    
    fileprivate var adLoader: GADAdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var deviceLanguage = ""
                if Constant().FORCE_RTL{
                    deviceLanguage = "ar"
                }
        
               if( deviceLanguage == "ar"){
                   UIView.appearance().semanticContentAttribute = .forceRightToLeft
                  
                let revealController : SWRevealViewController? = revealViewController()
                  
                  
                  let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.rightRevealToggle(_:)))
                  navigationItem.leftBarButtonItem = revealBarButton
                  
                  if revealViewController() != nil {
                      revealBarButton.target = revealViewController()
                      revealBarButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
                      view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                  }

               } else{
                     UIView.appearance().semanticContentAttribute = .forceLeftToRight
                                 let revealController : SWRevealViewController? = revealViewController()
                                   
                                   
                                   let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
                                   navigationItem.leftBarButtonItem = revealBarButton
                                   
                                   if revealViewController() != nil {
                                       revealBarButton.target = revealViewController()
                                       revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
                                       view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                                   }
               }
//        if isRoot{
//            let revealController : SWRevealViewController? = revealViewController()
//            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
//            navigationItem.leftBarButtonItem = revealBarButton
//
//            if revealViewController() != nil {
//                revealBarButton.target = revealViewController()
//                revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
//                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//            }
//
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//        }
        
        adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        tableNews.backgroundColor = UIColor.white
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        let tableAllFeatureNewsNib = UINib(nibName: "HomeScreenListCell", bundle: nil)
        tableNews.register(tableAllFeatureNewsNib, forCellReuseIdentifier: "cell")
        
        self.title = viewTitle.count > 0 ? viewTitle : Constant().navigationTitle
        
        tableNews.addInfiniteScrolling {[weak self] in
            guard let self = self else{
                return
            }
            self.count = self.count + 1
            self.getAllFeatureNews(pageNumber: "\(self.count)")
        }

        
        self.getAllFeatureNews(pageNumber: String(count))
        activityIndication(view: tableNews)
        configureRefreshControl()
    }
    
    func configureRefreshControl() {
       // Add the refresh control to your UIScrollView object.
       tableNews.refreshControl = UIRefreshControl()
       tableNews.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        self.count = 1
        self.getAllFeatureNews(pageNumber: "1")
    }
    
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchNewViewController") as? SearchNewViewController else {
            return
        }
        
        self.present(UINavigationController(rootViewController: searchVC), animated: false, completion: nil)
    }
    
    @objc func doneButtonAction(){
    }
}


//MARK:- GetAll FeatureNews
extension NewsVC{
    fileprivate func getAllFeatureNews(pageNumber: String){
        var parameter = API_VERSION_V1 ? "?page=\(pageNumber)" : "?_embed&page=\(pageNumber)"
        
        if self.viewTitle == "Search result"{
            parameter = parameter.appending("&search=").appending(self.searchText)
        }else if self.catId != 0{
            parameter = parameter.appending("&categories=").appending(String(self.catId))
        }
        
        News().getAllNews(parameter: parameter) {[weak self] (newsList, status,message) in
            guard let self = self else{
                return
            }
            
            if self.count > 1{
                self.tableNews.infiniteScrollingView.stopAnimating()
            }else if self.count == 1{
                self.stopActivityIndicator()
                self.tableNews.refreshControl?.endRefreshing()
            }
            
            if status{
                let list = newsList.filter({ (new) -> Bool in
                    let slug = new.slug
                    return !Constant().listCategoryNotShow.contains(slug)
                })
                
                if list.count > 0{
                    if self.count == 1{
                        self.listAllFeatureNews = list
                    }else{
                        for news in list where !self.listAllFeatureNews.contains(where: { return (news.id ?? -1) == ($0.id ?? -1) }){
                            self.listAllFeatureNews.append(news)
                        }
                    }
                }else{
                    if self.count > 1 && newsList.count > 0{
                        self.count = self.count - 1
                    }
                }
                
                self.tableNews.reloadData()
            }
        }
    }
    
    //Activity Indicator
    func activityIndication(view: UIView){
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.color = UIColor.black
        activity.clipsToBounds = true
        activity.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        view.addSubview(activity)
    }
    
    func stopActivityIndicator(){
        activity.stopAnimating()
    }
}


//MARK:- GOOGLE ADS
extension NewsVC: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
  func adLoader(_ adLoader: GADAdLoader,
                didReceive nativeAd: GADUnifiedNativeAd) {
    listAds.append(nativeAd)
    self.tableNews.reloadData()
  }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
        
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
}


//MARK:- UITableView
extension NewsVC: UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listAllFeatureNews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Constant().NUMBER_NEWS_SHOW_ADS == 0{
            return 0.001
        }else if ((section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0 && section > 0){
            return 0.001
//            return 140
        }else{
            return 0.001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return nil
        
//        if Constant().NUMBER_NEWS_SHOW_ADS == 0{
//            return nil
//        }else if ((section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0 && section > 0){
//            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 140))
//            if let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
//            let nativeAdView = nibObjects.first as? GADUnifiedNativeAdView {
//              nativeAdView.frame = view.bounds
//
//              let index = (section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
//              if index < listAds.count{
//                  let nativeAd = listAds[index]
//                  nativeAdView.nativeAd = nativeAd
//
//                  // Set ourselves as the native ad delegate to be notified of native ad events.
//                  //nativeAd.delegate = self
//
//                  // Populate the native ad view with the native ad assets.
//                  // The headline and mediaContent are guaranteed to be present in every native ad.
//                  (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
//                  nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
//
//                  // These assets are not guaranteed to be present. Check that they are before
//                  // showing or hiding them.
//                  (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
//                  nativeAdView.bodyView?.isHidden = nativeAd.body == nil
//
//                  (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//                  nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
//
//                  (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//                  nativeAdView.iconView?.isHidden = nativeAd.icon == nil
//
//                  (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
//                  nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
//
//                  (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
//                  nativeAdView.storeView?.isHidden = nativeAd.store == nil
//
//                  (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
//                  nativeAdView.priceView?.isHidden = nativeAd.price == nil
//
//                  (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//                  nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
//
//                  // In order for the SDK to process touch events properly, user interaction should be disabled.
//                  nativeAdView.callToActionView?.isUserInteractionEnabled = false
//              }
//                view.addSubview(nativeAdView)
//            }
//            return view
//        }else{
//            return nil
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableNews.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! HomeScreenListCell
        let new = self.listAllFeatureNews[indexPath.section]
        cell.imageFeatureNews.loadImageUsingCache(withUrl: new.featured_image_link ?? "")

        cell.lblFeatureTitle.text = new.categoryName
        cell.lblFeatureNews.text = new.title?.htmlDecoded
        cell.lblDate.text = new.dateString
        
        if (indexPath.section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0{
            let index = (indexPath.section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
            if index >= listAds.count{
                let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = listAllFeatureNews.count/Constant().NUMBER_NEWS_SHOW_ADS
                
                adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                                       adTypes: [ .unifiedNative ], options: [multipleAdsOptions])
                adLoader.delegate = self
                adLoader.load(GADRequest())
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as? DetailNewsVC else{
            return
        }
        
        detailNewsVC.listCategory = self.listAllFeatureNews[indexPath.section]
        detailNewsVC.catId = self.catId
        self.navigationController?.pushViewController(detailNewsVC, animated: true)
    }
}
