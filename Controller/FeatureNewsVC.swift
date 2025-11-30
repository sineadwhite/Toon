//
//  FeatureNewsVC.swift
//  WPNews
//
//  Created by itechnotion-mac1 on 28/06/18.
//  Copyright © 2018 itechnotion-mac1. All rights reserved.
//

import UIKit
import SVPullToRefresh
import GoogleMobileAds

class FeatureNewsVC: UIViewController , UISearchBarDelegate{
    
    @IBOutlet weak var collectionFeatureNewsName: UICollectionView!
    @IBOutlet weak var tableFeatureNewsDetails: UITableView!
    @IBOutlet var viewFeatureNews: UIView!
    @IBOutlet weak var lblListFeatureNews: UILabel!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintTableView: NSLayoutConstraint!
    @IBOutlet weak var constraintViewFeatureNews: NSLayoutConstraint!
    
    var listCategoryDetail = [NewsData]()
    var listCategory = [NewsNameData]()
    var activity = UIActivityIndicatorView()
    var categoryId = Int()
    
    var searchBar:UISearchBar = UISearchBar()
    let window = UIApplication.shared.keyWindow!
    var viewSearch = UIView()
    var page = 1
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!

    var listAds = [GADUnifiedNativeAd]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        tableFeatureNewsDetails.backgroundColor = UIColor.white
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        //Name CollectionView
        let cellNibButton = UINib(nibName: "HomeScreenButtonCell", bundle: nil)
        collectionFeatureNewsName.register(cellNibButton, forCellWithReuseIdentifier: "cellForButton")
        
        let tableAllFeatureNewsNib = UINib(nibName: "HomeScreenListCell", bundle: nil)
        tableFeatureNewsDetails.register(tableAllFeatureNewsNib, forCellReuseIdentifier: "cell")
        
        activityIndication(view: view)
        self.collectionFeatureNewsName.reloadData()
        
        viewSearch = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44))
        viewSearch.backgroundColor = .white
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.placeholder = "Search"
        searchBar.backgroundColor = .blue
        searchBar.delegate = self
        viewSearch.addSubview(searchBar)
        self.addDoneButtonOnKeyboard()
        
        self.getCategoryDetails()
        configureRefreshControl()
    }
    
    func configureRefreshControl() {
       // Add the refresh control to your UIScrollView object.
       tableFeatureNewsDetails.refreshControl = UIRefreshControl()
       tableFeatureNewsDetails.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
        tableFeatureNewsDetails.addInfiniteScrolling {
            self.page = self.page + 1
            self.getCategoryDetails()
        }
    }

    @objc func handleRefreshControl() {
        page = 1
        self.getCategoryDetails()
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
    // MARK:- Fetch All Category Names(CollectionView)
    func getCategoryDetails(){
        for category in listCategory{
            if category.isSelect!{
                self.getTableDataById(categoryId: category.id!)
                self.lblListFeatureNews.text = category.name
            }
        }
    }
    func categoryEnable(index : Int){
        for i in 0..<listCategory.count{
            listCategory[i].isSelect = false
        }
        listCategory[index].isSelect = true
    }
    //MARK: - Fetch News By Id(TableView)
    func getTableDataById(categoryId: Int){
        DispatchQueue.main.async { [unowned self] in
            let parameters = "?page=\(self.page)&categories=\(categoryId)"
            self.categoryId = categoryId
            
            News().getAllNews(parameter: parameters) { (newsList, status,message) in
                if status{
                    if self.page == 1{
                        self.listCategoryDetail = newsList
                    }else if newsList.count > 0{
                        self.listCategoryDetail.append(contentsOf: newsList)
                        self.tableFeatureNewsDetails.infiniteScrollingView.stopAnimating()
                    }else{
                        self.tableFeatureNewsDetails.infiniteScrollingView.stopAnimating()
                        self.page = self.page - 1
                    }
                    
                    self.tableFeatureNewsDetails.reloadData()
//                    self.heightConstraints()
                }else{
                    print(message)
                }
            }
        }
    }
    //Height Constraint
    @objc func heightConstraints(){
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.viewFeatureNews.frame.size.height + self.viewFeatureNews.frame.origin.y)
        
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
    //Activity Indicator
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

extension FeatureNewsVC: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
  func adLoader(_ adLoader: GADAdLoader,
                didReceive nativeAd: GADUnifiedNativeAd) {
    listAds.append(nativeAd)
    self.tableFeatureNewsDetails.reloadData()
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

//Collection View Methods
extension FeatureNewsVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellBtn = collectionFeatureNewsName.dequeueReusableCell(withReuseIdentifier: "cellForButton", for: indexPath) as! HomeScreenButtonCell
        cellBtn.lblFeatureNewsName.text = listCategory[indexPath.row].name
        if listCategory[indexPath.row].isSelect!{
            cellBtn.lblFeatureNewsName.alpha = 1.0
        }else{
            cellBtn.lblFeatureNewsName.alpha = 0.5
        }
        return cellBtn
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.categoryEnable(index: indexPath.row)
        collectionView.reloadData()
        self.page = 1
        self.getTableDataById(categoryId: listCategory[indexPath.row].id!)
        //LabelNameDisplay
        lblListFeatureNews.text = listCategory[indexPath.row].name
        //ShowActivityIndicator
        activityIndication(view: tableFeatureNewsDetails)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let size: CGSize = listCategory[indexPath.row].name!.size(withAttributes: nil)
            return CGSize(width: size.width + 60.0, height: collectionFeatureNewsName.frame.size.height)
    }
}
//Table View Methods
extension FeatureNewsVC : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return listCategoryDetail.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableFeatureNewsDetails.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeScreenListCell
        stopActivityIndicator()
        
        if listCategoryDetail[indexPath.section].category_arr.count > 1{
            cell.lblFeatureTitle.text = listCategoryDetail[indexPath.section].category_arr[1].name
        }else if listCategoryDetail[indexPath.section].category_arr.count > 0{
            cell.lblFeatureTitle.text = listCategoryDetail[indexPath.section].category_arr[0].name
        }
        cell.lblFeatureNews.text = listCategoryDetail[indexPath.section].title?.htmlDecoded
        cell.lblDate.text = listCategoryDetail[indexPath.section].dateString
        cell.imageFeatureNews.loadImageUsingCache(withUrl: self.listCategoryDetail[indexPath.section].featured_image_link ?? "")
        if (indexPath.section + 1) % Constant().NUMBER_NEWS_SHOW_ADS == 0{
            let index = (indexPath.section + 1)/Constant().NUMBER_NEWS_SHOW_ADS
            if index >= listAds.count{
                let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = listCategoryDetail.count/Constant().NUMBER_NEWS_SHOW_ADS
                adLoader = GADAdLoader(adUnitID: Constant().ADNATIVE, rootViewController: self,
                                       adTypes: [ .unifiedNative ], options: [multipleAdsOptions])
                adLoader.delegate = self
                adLoader.load(GADRequest())
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let DetailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as! DetailNewsVC
        DetailNewsVC.listCategory = self.listCategoryDetail[indexPath.section]
        DetailNewsVC.catId = self.categoryId
        self.navigationController?.pushViewController(DetailNewsVC, animated: true)
    }
}
