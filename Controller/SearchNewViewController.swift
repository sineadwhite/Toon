//
//  SearchNewViewController.swift
//  Ontin
//
//  Created by liemkk on 11/15/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SVPullToRefresh
import ObjectMapper
import GoogleMobileAds

class SearchNewViewController: UIViewController {
    @IBOutlet weak var tableNews: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var listNews = [NewsData]()
    fileprivate var count = 1
    fileprivate var listAds = [GADUnifiedNativeAd]()
    fileprivate var adLoader: GADAdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var deviceLanguage = ""
             
        
        
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
        if(deviceLanguage == "ar"){
            searchBar.semanticContentAttribute = .forceRightToLeft
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//            let searchTextField: UITextField = searchBar.value(forKey: "_searchField") as! UITextField
//            searchTextField.textAlignment = .right
            guard let searchField = searchBar.value(forKey: "searchField") as? UITextField else { return }
searchField.textAlignment = .right
        } else{
            searchBar.semanticContentAttribute = .forceLeftToRight
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        searchBar.delegate = self
        // addSearchBar()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
        
        setupTableview()
        setupAds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    fileprivate func setupAds(){
        adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        tableNews.backgroundColor = UIColor.white
    }
    
    fileprivate func addSearchBar(){
        searchBar.placeholder = "Search...."
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        
        
        
        // searchBar.placeholder = ""
        
    }
    
    fileprivate func setupTableview() {
        let tableAllFeatureNewsNib = UINib(nibName: "HomeScreenListCell", bundle: nil)
        tableNews.register(tableAllFeatureNewsNib, forCellReuseIdentifier: "cell")
        
        tableNews.addInfiniteScrolling {[weak self] in
            guard let self = self else{
                return
            }
            
            self.count = self.count + 1
            self.getNews("\(self.count)")
        }
        
        tableNews.refreshControl = UIRefreshControl()
        tableNews.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
                                            for: .valueChanged)
        tableNews.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @objc func handleRefreshControl() {
        self.count = 1
        self.getNews("1", true)
    }
    
}


extension SearchNewViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // searchBar.resignFirstResponder()
        self.count = 1
        self.getNews("\(count)")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //           searchedCountry = countryNameArr.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        //        if(searchText.count > 0){
        //           self.count = 1
        //           self.getNews("\(count)")
        //        } else {
        //            listNews.removeAll()
        //            self.tableNews.reloadData()
        //        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK:- GOOGLE ADS
extension SearchNewViewController: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
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
extension SearchNewViewController: UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listNews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Constant().NUMBER_NEWS_SHOW_ADS == 0{
            return 0.001
        }else if ((section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0 && section > 0){
            return 140
        }else{
            return 0.001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if Constant().NUMBER_NEWS_SHOW_ADS == 0{
            return nil
        }else if ((section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0 && section > 0){
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 140))
            if let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
                let nativeAdView = nibObjects.first as? GADUnifiedNativeAdView {
                nativeAdView.frame = view.bounds
                
                let index = (section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
                if index < listAds.count{
                    let nativeAd = listAds[index]
                    nativeAdView.nativeAd = nativeAd
                    
                    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
                    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
                    
                    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
                    nativeAdView.bodyView?.isHidden = nativeAd.body == nil
                    
                    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
                    nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
                    
                    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                    nativeAdView.iconView?.isHidden = nativeAd.icon == nil
                    
                    (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
                    nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
                    
                    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
                    nativeAdView.storeView?.isHidden = nativeAd.store == nil
                    
                    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
                    nativeAdView.priceView?.isHidden = nativeAd.price == nil
                    
                    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
                    nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
                    
                    // In order for the SDK to process touch events properly, user interaction should be disabled.
                    nativeAdView.callToActionView?.isUserInteractionEnabled = false
                }
                view.addSubview(nativeAdView)
            }
            return view
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableNews.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! HomeScreenListCell
        let new = self.listNews[indexPath.section]
        cell.imageFeatureNews.loadImageUsingCache(withUrl: new.featured_image_link ?? "")
        cell.lblFeatureTitle.text = new.categoryName
        cell.lblFeatureNews.text = new.title?.htmlDecoded
        cell.lblDate.text = new.dateString
        
        if (indexPath.section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0{
            let index = (indexPath.section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
            if index >= listAds.count{
                let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = listNews.count/Constant().NUMBER_NEWS_SHOW_ADS
                
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
        
        detailNewsVC.listCategory = self.listNews[indexPath.section]
        self.navigationController?.pushViewController(detailNewsVC, animated: true)
    }
}


extension SearchNewViewController{
    fileprivate func getNews(_ pageNumber: String, _ isRefresh: Bool = false){
        if !isRefresh && count == 1 {
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.show()
        }
        
        var parameter = API_VERSION_V1 ? "?page=\(pageNumber)" : "?_embed&page=\(pageNumber)"
        parameter = parameter.appending("&search=").appending(searchBar.text ?? "")
        
        News().getAllNews(parameter: parameter) {[weak self] (newsList, status,message) in
            guard let self = self else{
                return
            }
            
            if self.count > 1{
                self.tableNews.infiniteScrollingView.stopAnimating()
            }else if self.count == 1{
                if isRefresh{
                    self.tableNews.refreshControl?.endRefreshing()
                }else{
                    SVProgressHUD.dismiss()
                }
            }
            
            if status{
                let list = newsList.filter({ (new) -> Bool in
                    let slug = new.slug
                    return !Constant().listCategoryNotShow.contains(slug)
                })
                
                if list.count > 0{
                    if self.count == 1{
                        self.listNews = list
                    }else{
                        for news in list where !self.listNews.contains(where: { return (news.id ?? -1) == ($0.id ?? -1) }){
                            self.listNews.append(news)
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
}

extension UISearchBar {

    var textField : UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view : UIView in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
