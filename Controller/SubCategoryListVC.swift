//
//  SubCategoryListVC.swift
//  WPNews
//
//  Created by itechnotion-mac1 on 12/07/18.
//  Copyright © 2018 itechnotion-mac1. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SVPullToRefresh
import ObjectMapper

class SubCategoryListVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableCategory: UITableView!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    var activity = UIActivityIndicatorView()
    var listId = [NewsNameData]()
    var listSubCategory = [NewsNameData]()
    var listCategory = [NewsData]()
    var catId = Int()
    var viewTitle = String()
    var isRoot = false
    
    var searchBar:UISearchBar = UISearchBar()
    let window = UIApplication.shared.keyWindow!
    var viewSearch = UIView()
    var page = 1
    var adLoader :GADAdLoader!
    
    var listAds = [GADUnifiedNativeAd]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        if isRoot{
            let revealController : SWRevealViewController? = revealViewController()
            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
            navigationItem.leftBarButtonItem = revealBarButton
            
            if revealViewController() != nil {
                revealBarButton.target = revealViewController()
                revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        self.title = viewTitle
        let tableListCategory = UINib(nibName: "NewsHeader", bundle: nil)
        tableCategory.register(tableListCategory, forHeaderFooterViewReuseIdentifier: "NewsHeader")
        tableCategory.backgroundColor = UIColor.white
        
        let tablecellNib = UINib(nibName: "HomeScreenListCell", bundle: nil)
        tableCategory.register(tablecellNib, forCellReuseIdentifier: "cell")
        
        self.activityIndication(view: self.tableCategory)
        
        viewSearch = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44))
        viewSearch.backgroundColor = .white
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.placeholder = "Search"
        searchBar.backgroundColor = .blue
        searchBar.delegate = self
        viewSearch.addSubview(searchBar)
        self.addDoneButtonOnKeyboard()

        self.getSubCategoryList()
        self.getCategory()
        
        adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
        configureRefreshControl()
    }
    
    func configureRefreshControl() {
       // Add the refresh control to your UIScrollView object.
       tableCategory.refreshControl = UIRefreshControl()
       tableCategory.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
        
        tableCategory.addInfiniteScrolling {
            self.page = self.page + 1
            self.getCategory()
        }
    }

    @objc func handleRefreshControl() {
        page = 1
        self.getCategory()
    }
    
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        self.viewSearch.frame = CGRect(x: self.view.frame.size.width, y: 20, width: self.view.frame.size.width, height: 44)
        
        self.window.addSubview(self.viewSearch)
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewSearch.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44)
        })
        self.searchBar.becomeFirstResponder()
    }
    //MARK:- UISearchbar delegate method (For search text)
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print(searchBar.text!)
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewSearch.frame = CGRect(x: self.view.frame.size.width, y: 20, width: self.view.frame.size.width, height: 44)
        })
        //        v.removeFromSuperview()
        searchBar.resignFirstResponder()
        let NewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
        NewsVC.viewTitle = "Search result"
        NewsVC.searchText = searchBar.text!
        self.navigationController?.pushViewController(NewsVC, animated: true)
    }
    
    func getSubCategoryList(){
        Webservice.web_category_all.webserviceFetchGetNew(parameters: "?per_page=100") {[weak self] (json) in
            guard let self = self, let j = json else{
                return
            }
            
            self.listSubCategory.removeAll()
            self.listSubCategory = Mapper<NewsNameData>.init().mapArray(JSONArray: j).filter({ return ($0.parent ?? 0) == 0 })
            self.tableCategory.reloadData()
        }
        
        /*
        Webservice.web_category_all.webserviceFetchGet(parameters: "?per_page=100")
        { (parsedData,error,httpResponse) in
            if(error){
                print("Network error")
            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                self.listSubCategory.removeAll()
                for info in parsedData!{
                    var newsName = NewsNameData()
                    if let dict = info as? NSDictionary{
                        let parent = dict["parent"] as? Int
                        if (parent == self.catId){
                            newsName.name = dict["name"] as? String
                            print(dict["name"] as? String as Any)
                            newsName.id = dict["id"] as? Int
                            self.listSubCategory.append(newsName)
                        }
                    }
                }
                self.tableCategory.reloadData()
                
            }else if httpResponse.statusCode == 401{
                print("Error")
            }
        }*/
    }
    
    //MARK:- get Category
    func getCategory(){
        let parameters = "?page=\(page)&categories=\(catId)"
        News().getAllNews(parameter: parameters) { (newsList, status,message) in
            if status{
                DispatchQueue.main.async {
                   self.tableCategory.refreshControl?.endRefreshing()
                }
                
                if self.page == 1{
                    self.listCategory = newsList
                }else if newsList.count > 0{
                    self.listCategory.append(contentsOf: newsList)
                    self.tableCategory.infiniteScrollingView.stopAnimating()
                }else{
                    self.tableCategory.infiniteScrollingView.stopAnimating()
                    self.page = self.page - 1
                }
                self.tableCategory.reloadData()
            }else{
                print(message)
            }
        }
    }
    
    //MARK:- Search done button
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        searchBar.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction(){
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewSearch.frame = CGRect(x: self.view.frame.size.width, y: 20, width: self.view.frame.size.width, height: 44)
        })
        //        v.removeFromSuperview()
        searchBar.resignFirstResponder()
    }
    func activityIndication(view: UIView){
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.color = UIColor.black
        activity.clipsToBounds = true
        activity.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        view.addSubview(activity)
    }
    func stopActivityIndicator(){
        activity.stopAnimating()
    }
}

extension SubCategoryListVC: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
      func adLoader(_ adLoader: GADAdLoader,
                    didReceive nativeAd: GADUnifiedNativeAd) {
        listAds.append(nativeAd)
        self.tableCategory.reloadData()
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

//Tableview Methods
extension SubCategoryListVC: UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return listCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeScreenListCell
        self.stopActivityIndicator()
        let categoty = self.listCategory[indexPath.section]
        cell.lblFeatureNews.text = categoty.title?.htmlDecoded
        
        if categoty.category_arr.count > 1{
            cell.lblFeatureTitle.text = categoty.category_arr[1].name
        }else if categoty.category_arr.count > 0{
            cell.lblFeatureTitle.text = categoty.category_arr[0].name
        }
        
        if (indexPath.section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0{
            let index = (indexPath.section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
            if index >= listAds.count{
                let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = listCategory.count/Constant().NUMBER_NEWS_SHOW_ADS
                adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                                       adTypes: [ .unifiedNative ], options: [multipleAdsOptions])
                adLoader.delegate = self
                adLoader.load(GADRequest())
            }
        }
        
        cell.lblDate.text = categoty.dateString
        cell.imageFeatureNews.loadImageUsingCache(withUrl: categoty.featured_image_link ?? "")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (indexPath.section == 1){
//            let NewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
//            NewsVC.catId = self.listSubCategory[indexPath.row].id!
//            NewsVC.viewTitle = self.listSubCategory[indexPath.row].name!
//            self.navigationController?.pushViewController(NewsVC, animated: true)
//        }else{
            let DetailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as! DetailNewsVC
            DetailNewsVC.listCategory = self.listCategory[indexPath.section]
            DetailNewsVC.catId = self.catId
            self.navigationController?.pushViewController(DetailNewsVC, animated: true)
//        }
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

                    // Set ourselves as the native ad delegate to be notified of native ad events.
                    //nativeAd.delegate = self

                    // Populate the native ad view with the native ad assets.
                    // The headline and mediaContent are guaranteed to be present in every native ad.
                    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
                    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

                    // These assets are not guaranteed to be present. Check that they are before
                    // showing or hiding them.
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
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if listSubCategory.count == section{
//            return 0
//        }else{
//            return 70
//        }
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if listSubCategory.count == section{
//            return nil
//        }else{
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NewsHeader") as! NewsHeader
//            headerView.lblCategory.text = self.listSubCategory[section].name
//            headerView.lblAbbriviation.text = String(self.listSubCategory[section].name!.characters.prefix(1))
//            headerView.row = section
//            headerView.onClick = { (rowCount) in
//                let NewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
//                NewsVC.catId = self.listSubCategory[rowCount].id!
//                print(self.listSubCategory[rowCount].id!)
//                NewsVC.viewTitle = self.listSubCategory[rowCount].name!
//                self.navigationController?.pushViewController(NewsVC, animated: true)
//            }
//            return headerView
//        }
//    }
}
