//
//  HomeVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds
import ObjectMapper
import SVProgressHUD

class HomeVC: UIViewController {
    @IBOutlet weak var viewAdvtBanner: GADBannerView!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    @IBOutlet weak var tableHome: UITableView!
    @IBOutlet weak var collection: UICollectionView!
    
    var listNews = [NewsData]()
    var listCategoryDetail = [NewsData]()
    var listCategory = [NewsNameData]()
    var listCategoryParent = [NewsNameData]()
    var listCategoryLoop = [NewsNameData]()
    var items = [[NewsNameData]()]
    var id = Int()
    var categoryId = String()
    var interstitialAd: GADInterstitial!
    var count = 1
    var isSupportRTL = false
    var deviceLanguage = ""
    var isClickMenu = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        
        self.title = Constant().navigationTitle
        
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        
        //        self.addAd()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        //            self.fullAd()
        //        }
        
        var languageCurrent = ""
        let preferredLanguage = Locale.preferredLanguages[0] as String
        print (preferredLanguage) //en-US
        let arr = preferredLanguage.components(separatedBy: "-")
        languageCurrent = arr.first ?? "ar"
        print (languageCurrent) //en
        
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
        print (deviceLanguage) //en
        if(deviceLanguage == "ar"){
           // UIView.appearance().semanticContentAttribute = .forceRightToLeft
            if(languageCurrent == "ar"){
                let revealController : SWRevealViewController? = revealViewController()
                          self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.size.width - 70
                          
                          let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.rightRevealToggle(_:)))
                          navigationItem.leftBarButtonItem = revealBarButton
            } else {
            let revealController : SWRevealViewController? = revealViewController()
            self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.size.width-70
            
            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.rightRevealToggle(_:)))
                if(!isClickMenu){
            navigationItem.rightBarButtonItem = revealBarButton
            navigationItem.leftBarButtonItem = barBtnSearch
                } else {
                    navigationItem.leftBarButtonItem = revealBarButton
                    navigationItem.rightBarButtonItem = barBtnSearch
                }
            }
            //                   if revealViewController() != nil {
            //                       revealBarButton.target = revealViewController()
            //                       revealBarButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            //                       view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            //                   }
            
            
            
            
        } else{
           // UIView.appearance().semanticContentAttribute = .forceLeftToRight
            let revealController : SWRevealViewController? = revealViewController()
            self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.size.width - 70
            
            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
            navigationItem.leftBarButtonItem = revealBarButton
            
            //            if revealViewController() != nil {
            //                revealBarButton.target = revealViewController()
            //                revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            //            }
        }
        
        
        
        if Constant().HOME_ANDROID{
            collection.delegate = self
            collection.dataSource = self
            collection.isHidden = false
            tableHome.isHidden = true
            setupCollectionView()
        }else{
            tableHome.delegate = self
            tableHome.dataSource = self
            collection.isHidden = true
            tableHome.isHidden = false
            setupTableview()
            configureRefreshControl()
        }
        
        view.showBlurLoader()
        self.getCategory()
        
        if Constant().HOME_ANDROID{
            self.getNewsAndroid()
        }else{
            tableHome.delegate = self
            self.getCollectionViewData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    
    fileprivate func setupTableview(){
        tableHome.register(UINib(nibName: "HomeScreenListCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableHome.register(UINib(nibName: "HomeFeatureCell", bundle: nil), forCellReuseIdentifier: "HomeFeatureCell")
        tableHome.register(UINib(nibName: "HomeTitileCell", bundle: nil), forCellReuseIdentifier: "HomeTitileCell")
    }
    
    fileprivate func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        tableHome.refreshControl = UIRefreshControl()
        tableHome.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
                                            for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        self.getCategory()
        self.getCollectionViewData()
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchNewViewController") as? SearchNewViewController else {
            return
        }
        
        //        self.present(UINavigationController(rootViewController: searchVC), animated: false, completion: nil)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func doneButtonAction(){
        
    }
}


//MARK: COLLECTION VIEW
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.listNews.count == 0{
            return 0
        }
        
        var number = 0
        if self.listNews.count%5 == 0{
            number = self.listNews.count/5
        }else{
            number = self.listNews.count/5 + 1
        }
        
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.listNews.count == 0{
            return 0
        }
        
        let numberRow = (section+1)*5
        if numberRow > self.listNews.count {
            return self.listNews.count - section*5 - 1
        }else{
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.section*5 + indexPath.row + 1
        if index >= self.listNews.count{
            return UICollectionViewCell()
        }
        
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "NewAndroidCell", for: indexPath) as? NewAndroidCell else {
            return UICollectionViewCell()
        }
        
        let new = self.listNews[index]
        cell.bindingData(new)
        if(deviceLanguage == "ar"){
            cell.lblNews.textAlignment = NSTextAlignment.right
        } else{
            cell.lblNews.textAlignment = NSTextAlignment.left
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionNewView", for: indexPath) as! HeaderCollectionNewView
        
        let index = indexPath.section*5
        if self.listNews.count > index {
            headerView.bindingData(self.listNews[index])
        }
        if(deviceLanguage == "ar"){
            headerView.lblNews.textAlignment = NSTextAlignment.right
        }else{
            headerView.lblNews.textAlignment = NSTextAlignment.left
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToNews(_:)))
        headerView.tag = indexPath.section
        headerView.addGestureRecognizer(tap)
        
        return headerView
    }
    
    @objc func tapToNews(_ tap: UITapGestureRecognizer) {
        guard let tag = tap.view?.tag else {
            return
        }
        
        let index = tag*5
        if index >= listNews.count {
            return
        }
        
        let new = self.listNews[index]
        guard let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as? DetailNewsVC else {
            return
        }
        
        detailNewsVC.listCategory = new
        self.navigationController?.pushViewController(detailNewsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - 15)/2, height: collectionView.bounds.size.width*160/375)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.width*160/375)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.section*5 + indexPath.row + 1
        if index >= self.listNews.count{
            return
        }
        
        let new = self.listNews[index]
        guard let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as? DetailNewsVC else {
            return
        }
        
        detailNewsVC.listCategory = new
        self.navigationController?.pushViewController(detailNewsVC, animated: true)
    }
    
    fileprivate func setupCollectionView(){
        // Add the refresh control to your UIScrollView object.
        collection.refreshControl = UIRefreshControl()
        collection.refreshControl?.addTarget(self, action:
            #selector(handleRefreshCollection),
                                             for: .valueChanged)
        collection.register(UINib(nibName: "NewAndroidCell", bundle: nil), forCellWithReuseIdentifier: "NewAndroidCell")
        collection.register(UINib(nibName: "HeaderCollectionNewView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionNewView")
        
        collection.addInfiniteScrolling {[weak self] in
            guard let self = self else{
                return
            }
            
            self.count = self.count + 1
            self.getNewsAndroid()
        }
    }
    
    @objc func handleRefreshCollection() {
        self.count = 1
        self.getCategory()
        self.getNewsAndroid()
    }
}


//MARK:- API
extension HomeVC{
    fileprivate func getCategory(completion: (([NewsData])->())?){
        let parameters = "?\(Constant().emble)"
        News().getAllNews(parameter: parameters) { (newsList, status,message) in
            var category = [NewsData]()
            if status{
                category = newsList
                completion?(category)
            }else{
                completion?(category)
            }
        }
    }
    
    //MARK: - Fetch News(CollectionView-1)
    fileprivate func getCollectionViewData(){
        self.getCategory {[weak self] (newsData) in
            guard let self = self else{
                return
            }
            
            self.listNews = newsData.filter({ (new) -> Bool in
                let slug = new.slug
                return !Constant().listCategoryNotShow.contains(slug)
            })
            
            self.tableHome.reloadData()
            self.tableHome.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func getNewsAndroid(){
        let parameter = API_VERSION_V1 ? "?page=\(count)" : "?_embed&page=\(count)"
        
        News().getAllNews(parameter: parameter) {[weak self] (newsList, status,message) in
            guard let self = self else{
                return
            }
            
            if self.count > 1{
                self.collection.infiniteScrollingView.stopAnimating()
            }else if self.count == 1{
                self.view.removeBluerLoader()
                self.collection.refreshControl?.endRefreshing()
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
                
                self.collection.reloadData()
            }
            
            
        }
    }
    
    // MARK:- Fetch All Category Names(CollectionView-2)
    fileprivate func getCategory(){
        Webservice.web_category_all.webserviceFetchGetNew(parameters: "?per_page=100") {[weak self] (json) in
            guard let self = self, let j = json else{
                return
            }
            
            self.listCategory.removeAll()
            self.listCategoryParent.removeAll()
            self.listCategory = Mapper<NewsNameData>.init().mapArray(JSONArray: j).filter({ (cate) -> Bool in
                return !Constant().listCategoryNotShow.contains(cate.slug ?? "") && cate.count > 0
            })
            self.listCategoryParent = Mapper<NewsNameData>.init().mapArray(JSONArray: j).filter({ (cate) -> Bool in
                return !Constant().listCategoryNotShow.contains(cate.slug ?? "") && cate.count > 0 && (cate.parent ?? 0) == 0
            })
            self.listCategoryLoop = Mapper<NewsNameData>.init().mapArray(JSONArray: j).filter({ (cate) -> Bool in
                return !Constant().listCategoryNotShow.contains(cate.slug ?? "") && cate.count > 0 && (cate.parent ?? 0) != 0
            })
            print(self.listCategoryLoop)
            self.listCategory.insert(NewsNameData(id:0, name: "Home", parent: 0, isSelect: false, subCat: "", slug: "Home", isHaveSub: false), at: 0)
            self.listCategoryParent.insert(NewsNameData(id:0, name: "Home", parent: 0, isSelect: false, subCat: "", slug: "Home", isHaveSub: false), at: 0)
            self.listCategory.insert(NewsNameData(id:0, name: "Settings", parent: 0, isSelect: false, subCat: "", slug: "Settings", isHaveSub: false), at: self.listCategory.count)
            self.listCategoryParent.insert(NewsNameData(id:0, name: "Settings", parent: 0, isSelect: false, subCat: "", slug: "Settings", isHaveSub: false), at: self.listCategoryParent.count)
            if(!Constant().listMenuAdd.isEmpty){
                for i in 0...Constant().listMenuAdd.count - 1{
                    self.listCategoryParent.insert(Constant().listMenuAdd[i], at: Constant().listMenuAdd[i].position ?? 0)
                }
                
            }
            
            for _ in 0...self.listCategoryParent.count - 1{
                self.items.append([NewsNameData]())
            }
            print(self.items)
            for i in 0...self.listCategoryParent.count - 1{
                var listTemp = [NewsNameData]()
                var isAdd = false
                if(self.listCategoryLoop.count > 0){
                    for j in 0...self.listCategoryLoop.count - 1{
                        if(self.listCategoryParent[i].id == self.listCategoryLoop[j].parent ){
                            listTemp.append(self.listCategoryLoop[j])
                            isAdd = true
                        }
                    }
                    
                }
                if(isAdd){
                    self.items[i] = listTemp
                }
                
            }
            print(self.items)
            //  if(self.deviceLanguage == "ar"){
            if let menuvc = self.revealViewController()?.rightViewController as? MenuNewViewController{
                menuvc.listCategoty = self.listCategory
                menuvc.listCategotyParent = self.listCategoryParent
                menuvc.items = self.items
            }
            // }
            //  else{
            if let menuvc = self.revealViewController()?.rearViewController as? MenuNewViewController{
                menuvc.listCategoty = self.listCategory
                menuvc.listCategotyParent = self.listCategoryParent
                menuvc.items = self.items
            }
            // }
            
            if self.listCategory.count > 0{
                Constant().cacheListCategory(self.listCategory)
                self.listCategory.shuffle()
                self.categoryEnable(index: 0)
            }
            
            if !Constant().HOME_ANDROID{
                self.tableHome.reloadData()
                
                if self.listCategory.count > 0{
                    let category = self.listCategory[0]
                    self.getTableDataById(categoryId: category.id ?? 0)
                }
            }
        }
        
    }
    
    fileprivate func categoryEnable(index : Int){
        for i in 0..<listCategory.count{
            listCategory[i].isSelect = false
        }
        listCategory[index].isSelect = true
    }
    
    //MARK: - Fetch News By Id(TableView-1)
    fileprivate func getTableDataById(categoryId: Int){
        let parameters = "?\(Constant().emble)&categories=\(categoryId)"
        self.categoryId = String(categoryId)
        News().getAllNews(parameter: parameters) {[weak self] (newsList, status,message) in
            guard let self = self else{
                return
            }
            
            self.listCategoryDetail = newsList.filter({ (new) -> Bool in
                let slug = new.slug
                return !Constant().listCategoryNotShow.contains(slug)
            })
            
            self.view.removeBluerLoader()
            self.tableHome.reloadData()
            self.stopActivityIndicator()
        }
    }
    
    fileprivate func stopActivityIndicator(){
        SVProgressHUD.dismiss()
    }
}


//MARK:- TableView Methods
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
            
        case 1:
            if (listCategoryDetail.count <= 5){
                return listCategoryDetail.count + 1
            }else{
                return 6
            }
            
        case 2:
            if (listNews.count <= 5){
                return listNews.count + 1
            }else{
                return 6
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return customCellTitle(indexPath)
        }else{
            if indexPath.section == 0{
                return customCellFeature(indexPath)
            }else{
                return customCellNew(indexPath)
            }
        }
    }
    
    fileprivate func customCellTitle(_ indexPath: IndexPath) -> UITableViewCell{
        let cell = tableHome.dequeueReusableCell(withIdentifier: "HomeTitileCell", for: indexPath) as! HomeTitileCell
        
        switch indexPath.section {
        case 0:
            cell.lblTitle.text = "Feature News"
            
        case 1:
            let list = self.listCategory.filter({ return $0.isSelect ?? false })
            if list.count > 0{
                let category = list[0]
                cell.lblTitle.text = category.name
            }
            
        case 2:
            cell.lblTitle.text = "Latest News"
            
        default:
            break
        }
        
        cell.clickAction = { [weak self] in
            self?.actionListNews(indexPath.section)
        }
        
        return cell
    }
    
    fileprivate func customCellNew(_ indexPath: IndexPath) -> UITableViewCell{
        let cell = tableHome.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeScreenListCell
        let new = indexPath.section == 1 ? self.listCategoryDetail[indexPath.row - 1] : self.listNews[indexPath.row - 1]
        
        cell.lblFeatureTitle.text = new.categoryName
        cell.lblFeatureNews.text = new.title?.htmlDecoded
        cell.lblDate.text = new.dateString
        cell.imageFeatureNews.loadImageUsingCache(withUrl: new.featured_image_link ?? "")
        
        return cell
    }
    
    fileprivate func customCellFeature(_ indexPath: IndexPath) -> UITableViewCell{
        let cell = tableHome.dequeueReusableCell(withIdentifier: "HomeFeatureCell", for: indexPath) as! HomeFeatureCell
        cell.bindingData(listNews: listNews, listCategory: listCategory)
        
        cell.selectCategory = { [weak self] (isFeatureNew, index) in
            guard let self = self else {
                return
            }
            
            self.doneButtonAction()
            
            if isFeatureNew {
                self.selectNewInFeature(index)
            }else{
                self.selectCategory(index)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.doneButtonAction()
        
        if indexPath.row > 0 && indexPath.section > 0 {
            guard let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as? DetailNewsVC else {
                return
            }
            
            if (indexPath.section == 1){
                detailNewsVC.listCategory = self.listCategoryDetail[indexPath.row - 1]
                detailNewsVC.catId = Int(self.categoryId) ?? 0
            }else{
                detailNewsVC.listCategory = self.listNews[indexPath.row - 1]
            }
            
            self.navigationController?.pushViewController(detailNewsVC, animated: true)
        }
    }
}


extension HomeVC{
    fileprivate func selectCategory(_ index: Int){
        guard index < listCategory.count else {
            return
        }
        
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.show()
        
        self.categoryEnable(index: index)
        self.tableHome.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        self.getTableDataById(categoryId: listCategory[index].id ?? 0)
    }
    
    fileprivate func selectNewInFeature(_ index: Int){
        guard let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as? DetailNewsVC, index < listNews.count else {
            return
        }
        
        detailNewsVC.listCategory = self.listNews[index]
        self.navigationController?.pushViewController(detailNewsVC, animated: true)
    }
    
    fileprivate func actionListNews(_ section: Int) {
        self.doneButtonAction()
        
        guard let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as? NewsVC else {
            return
        }
        
        if section == 1 {
            let list = self.listCategory.filter({ return $0.isSelect ?? false })
            if list.count > 0{
                let category = list[0]
                newsVC.viewTitle = category.name ?? ""
                newsVC.catId = category.id ?? 0
            }
        }else{
            newsVC.viewTitle = section == 0 ? "Feature News": "Latest News"
        }
        
        self.navigationController?.pushViewController(newsVC, animated: true)
    }
}


extension HomeVC : GADInterstitialDelegate,GADBannerViewDelegate{
    func fullAd(){
        interstitialAd = GADInterstitial(adUnitID: Constant().ADFULLBANNER)
        let request = GADRequest()
        interstitialAd.load(request)
        
        interstitialAd.present(fromRootViewController: self)
        interstitialAd.delegate = self
        if interstitialAd.isReady {
            interstitialAd.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    func addAd(){
        //Bottom Advt Banner
        viewAdvtBanner.adUnitID = Constant().ADBOTTOMBANNER
        viewAdvtBanner.rootViewController = self
        viewAdvtBanner.load(GADRequest())
        viewAdvtBanner.delegate = self
    }
    // Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitialAd.present(fromRootViewController: self)
        print("interstitialDidReceiveAd")
    }
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: Constant().ADBOTTOMBANNER)
        interstitial.delegate = self     
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    }
}


extension String {
    var htmlDecoded: String {
        do{
            let decoded = try? NSAttributedString(data: Data(utf8), options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil).string
            
            return decoded ?? self
        }catch{
            return self
        }
    }
}
