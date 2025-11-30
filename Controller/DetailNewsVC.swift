//
//  DetailNewsVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Social
import SafariServices
import GoogleMobileAds
import AVFoundation
import WebKit

class DetailNewsVC: UIViewController{
    @IBOutlet weak var constraintRelatedContent: NSLayoutConstraint!
    @IBOutlet weak var constraintNewsData: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightRelatable: NSLayoutConstraint!
    @IBOutlet weak var tableRelatedContent: UITableView!
    @IBOutlet weak var scrollDetailsNews: UIScrollView!
    @IBOutlet weak var viewRelatedContent: UIView!
    @IBOutlet weak var viewNewsData: UIView!
    @IBOutlet weak var viewSocialMedia: UIView!
    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var imageTimeIcon: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var lblCategoryDate: UILabel!
    @IBOutlet weak var lblRelatableContent: UILabel!
    @IBOutlet weak var btnWriteComment: UIButton!
    @IBOutlet weak var btnViewComment: UIButton!
    @IBOutlet weak var btnShareNews: UIButton!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var imageShare: UIImageView!
    @IBOutlet weak var viewContentWeb: UIView!
    @IBOutlet weak var viewAdvtBanner: GADBannerView!
    
    var newsId = Int()
    var catId = Int()
    var listCategory = NewsData()
    var aString = String()
    var isLoadDetail = false
    
    fileprivate var activity = UIActivityIndicatorView()
    fileprivate var webViewDetail: WKWebView!
    fileprivate var listRelatedContent = [NewsData]()
    var deviceLanguage = ""
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil{
            if self.webViewDetail != nil{
                self.webViewDetail.loadHTMLString("<html><head></head><body></body></html>", baseURL: nil)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!Constant().isShowComment){
            btnWriteComment.alpha = 0.7
            btnWriteComment.isEnabled = false
        } else {
            btnWriteComment.alpha = 1
            btnWriteComment.isEnabled = true
        }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
        if( deviceLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.view.semanticContentAttribute = .forceRightToLeft
        } else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        setFont()
        self.title = Constant().navigationTitle
        self.lblCategoryName.backgroundColor = Constant().THEMECOLOR
        self.lblCategoryDate.textColor = Constant().THEMECOLOR
        self.imageTimeIcon.tintColor = Constant().THEMECOLOR
        self.btnViewComment.backgroundColor = Constant().THEMECOLOR
        self.btnWriteComment.backgroundColor = Constant().THEMECOLOR
        self.lblShare.textColor = Constant().THEMECOLOR
        self.imageShare.tintColor = Constant().THEMECOLOR
        self.btnShareNews.borderColor = Constant().THEMECOLOR
        
        let image = UIImage(named: "icon_menu_share")?.withRenderingMode(.alwaysTemplate)
        self.imageShare.tintColor = Constant().THEMECOLOR
        self.imageShare.image = image
        
        let cellNib = UINib(nibName: "DetailNewsRelatedCell", bundle: nil)
        tableRelatedContent.register(cellNib, forCellReuseIdentifier: "cell")
        tableRelatedContent.tableFooterView = UIView(frame: CGRect.zero)
        
        addWebview()
        
        self.activityIndicator(view: view)
        
        if isLoadDetail{
            self.getDetail()
        }else{
            self.setData(newsData : self.listCategory)
        }
        
        addAd()
    }
    
    fileprivate func addWebview(){
        webViewDetail = WKWebView.init(frame: viewContentWeb.bounds)
        webViewDetail.navigationDelegate = self
        webViewDetail.scrollView.isScrollEnabled = false
        viewContentWeb.addSubview(webViewDetail)
    }
    
    func setFont() {
        lblShare.font = UIFont.customMedium(16)
        lblCategoryName.font = UIFont.customMedium(13)
        lblCategoryTitle.font = UIFont.customBold(18)
        lblCategoryDate.font = UIFont.customBold(12)
        lblRelatableContent.font = UIFont.customBold(18)
        
        btnWriteComment.titleLabel?.font = UIFont.customMedium(15)
        btnViewComment.titleLabel?.font = UIFont.customMedium(15)
    }
    
    func addAd(){
        //Bottom Advt Banner
        viewAdvtBanner.adUnitID = Constant().ADBOTTOMBANNER
        viewAdvtBanner.rootViewController = self
        viewAdvtBanner.load(GADRequest())
        viewAdvtBanner.delegate = self
    }
}


//MARK: DATA
extension DetailNewsVC{
    fileprivate func getDetail() {
        News().getPostDetail(listCategory.id ?? 0) {[weak self] (data) in
            guard let self = self else{
                return
            }
            
            if let data = data{
                self.listCategory = data
                self.catId = data.cateId
                self.setData(newsData : self.listCategory)
            }
        }
    }
    
    fileprivate func setData(newsData : NewsData){
        aString = newsData.categoryName
        let newString = aString.replacingOccurrences(of: "&amp;", with: "&")
        self.lblCategoryName.text = newString
        self.lblCategoryTitle.text = newsData.title?.htmlDecoded
        self.lblCategoryDate.text = newsData.dateString
        
        if let html = Bundle.main.path(forResource: "new", ofType: "html"){
            do{
                let htmlString = try? String(contentsOfFile: html, encoding: String.Encoding.utf8)
                let content = htmlString?.replacingOccurrences(of: "NewContent", with: newsData.content ?? "")
                if( deviceLanguage == "ar"){
                    self.webViewDetail.loadHTMLString( "<html dir=\"rtl\" lang=\"\"><body>" + (content ?? "")  + "</body></html>", baseURL: nil)
                } else {
                self.webViewDetail.loadHTMLString(content ?? "", baseURL: nil)
                }
            }catch{
                
            }
        }
        
        self.scrollDetailsNews.isScrollEnabled = true
        self.heightConstraint()
        imageCategory.loadImageUsingCache(withUrl: newsData.featured_image_link ?? "")
        self.newsId = newsData.id ?? 0
        self.getRelatedContent()
    }
    
    @objc func heightConstraint(){
        scrollDetailsNews.contentSize = CGSize(width: self.view.frame.size.width, height: self.viewSocialMedia.frame.size.height + self.viewSocialMedia.frame.origin.y+10)
        _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.heightConstraint), userInfo: nil, repeats: false)
    }
    
    fileprivate func getRelatedContent(){
        var parameters = "?\(Constant().emble)&categories=\(catId)"
        if catId == 0{
            parameters = ""
        }
        
        News().getAllNews(parameter: parameters) {[weak self] (newsList, status,message) in
            guard let self = self else{
                return
            }
            
            if status{
                self.listRelatedContent = newsList
                self.tableRelatedContent.reloadData()
                self.constraintRelatedContent.constant = self.tableRelatedContent.contentSize.height + 30
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                    guard let self = self else{
                        return
                    }
                    
                    self.tableRelatedContent.isScrollEnabled = false
                    self.constraintRelatedContent.constant = self.tableRelatedContent.contentSize.height + 42
                    self.heightConstraint()
                    self.stopActivityIndicator()
                    self.view.layoutIfNeeded()
                }
            }else{
                print(message)
            }
        }
    }
    
    func activityIndication(view: UIView){
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.color = UIColor.black
        activity.clipsToBounds = true
        activity.center = self.tableRelatedContent.center
        activity.hidesWhenStopped = true
        activity.startAnimating()
        view.addSubview(activity)
    }
    
    func activityIndicator(view: UIView){
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


//MARK: ACTION
extension DetailNewsVC{
    @IBAction func actionWriteComment(_ sender: Any) {
        let contact = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        contact.isContactUs = false
        contact.newsId = newsId
        contact.newsTitle = self.lblCategoryTitle.text ?? ""
        self.navigationController?.pushViewController(contact, animated: true)
    }
    
    @IBAction func actionViewComment(_ sender: Any) {
        let viewCommentVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewCommentVC") as! ViewCommentVC
        viewCommentVC.newsId = newsId
        self.navigationController?.pushViewController(viewCommentVC, animated: true)
    }
    
    @IBAction func actionShare(_ sender: Any) {
        guard let imageURL = URL(string: self.listCategory.link ?? "") else {
            return
        }
        
        let objectsToShare: [AnyObject] = [imageURL as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [.airDrop]
        self.present(activityViewController, animated: true, completion: nil)
    }
}


//MARK: WEBVIEW
extension DetailNewsVC: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            webView.evaluateJavaScript("document.readyState", completionHandler: {[weak self] (complete, error) in
                guard let weakSelf = self else{
                    return
                }
                
                if complete != nil {
                    weakSelf.webViewDetail.invalidateIntrinsicContentSize()
                    weakSelf.constraintNewsData.constant = webView.scrollView.contentSize.height + 10
                    weakSelf.view.layoutIfNeeded()
                    weakSelf.webViewDetail.frame = weakSelf.viewContentWeb.bounds
                }
            })
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            guard let url = navigationAction.request.url else{
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
}


//MARK: TABLEVIEW
extension DetailNewsVC: UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (listRelatedContent.count <= 3){
            return listRelatedContent.count
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableRelatedContent.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailNewsRelatedCell
        self.tableRelatedContent.setNeedsLayout()
        self.tableRelatedContent.layoutIfNeeded()
        self.constraintRelatedContent.constant = self.lblRelatableContent.frame.size.height + self.tableRelatedContent.contentSize.height
        cell.lblNewsNumber.text =  String(indexPath.row+1)
        cell.lblNewsTitle.text = listRelatedContent[indexPath.row].title?.htmlDecoded
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndication(view: viewRelatedContent)
        scrollDetailsNews.scrollToTop()
        self.setData(newsData : listRelatedContent[indexPath.row])
    }
}


extension DetailNewsVC: GADBannerViewDelegate{
    
}




//    @IBAction func actionFacebookShare(_ sender: Any) {
//        let shareURL = URL(string: self.listCategory.link!)
//        if let string = URL(string: "fb://\(String(describing: shareURL))"){
//            if UIApplication.shared.canOpenURL(string){
//                let facebookShare = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//                if let facebookShare = facebookShare{
//                    facebookShare.add(URL(string: self.listCategory.link!))
//                    self.present(facebookShare, animated: true, completion: nil)
//                }
//            }else{
//                var urlComponents = URLComponents(string: "https://www.facebook.com/sharer?")
//
//                urlComponents!.queryItems = [URLQueryItem(name: "url", value: shareURL!.absoluteString)]
//
//                let url = urlComponents!.url!
//
//                if #available(iOS 9.0, *) {
//                    let svc = SFSafariViewController(url: url)
//                    svc.delegate = self as? SFSafariViewControllerDelegate
//                    self.present(svc, animated: true, completion: nil)
//                } else {
//                    debugPrint("Not available")
//                }
//            }
//        }
//    }
//    @IBAction func actionTwitterShare(_ sender: Any) {
//        let shareURL = URL(string: self.listCategory.link!)
//        if let string = URL(string: "twitter://\(String(describing: shareURL))"){
//            if UIApplication.shared.canOpenURL(string){
//                let twitterShare = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//                if let twitterShare = twitterShare{
//                    twitterShare.add(URL(string: self.listCategory.link!))
//                    self.present(twitterShare, animated: true, completion: nil)
//                }
//            }else{
//                var urlComponents = URLComponents(string: "https://www.twitter.com/share?")
//
//                urlComponents!.queryItems = [URLQueryItem(name: "url", value: shareURL!.absoluteString)]
//
//                let url = urlComponents!.url!
//
//                if #available(iOS 9.0, *) {
//                    let svc = SFSafariViewController(url: url)
//                    svc.delegate = self as? SFSafariViewControllerDelegate
//                    self.present(svc, animated: true, completion: nil)
//                } else {
//                    debugPrint("Not available")
//                }
//            }
//        }
//    }
//    @IBAction func actionPinterestShare(_ sender: Any) {
//        let shareURL = URL(string: self.listCategory.link!)
//        if let string = URL(string: "pinterest://\(String(describing: shareURL))"){
//            if UIApplication.shared.canOpenURL(string){
//
//                print("Not Available")
////                let twitterShare = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
////                if let twitterShare = twitterShare{
////                    twitterShare.add(URL(string: self.listCategory.link!))
////                    self.present(twitterShare, animated: true, completion: nil)
////                }
//            }else{
//                var urlComponents = URLComponents(string: "http://pinterest.com/share")
//
//                urlComponents!.queryItems = [URLQueryItem(name: "url", value: shareURL!.absoluteString)]
//
//                let url = urlComponents!.url!
//
//                if #available(iOS 9.0, *) {
//                    let svc = SFSafariViewController(url: url)
//                    svc.delegate = self as? SFSafariViewControllerDelegate
//                    self.present(svc, animated: true, completion: nil)
//                } else {
//                    debugPrint("Not available")
//                }
//            }
//        }
//    }
//    @IBAction func actionLinkedInShare(_ sender: Any) {
//        let shareURL = URL(string: self.listCategory.link!)
//        if let string = URL(string: "linkedin://\(String(describing: shareURL))"){
//            if UIApplication.shared.canOpenURL(string){
//                print("Not Available")
//
//                let linkedShare = SLComposeViewController(forServiceType: SLServiceTypeLinkedIn)
//                if let linkedShare = linkedShare{
//                    linkedShare.add(URL(string: self.listCategory.link!))
//                    self.present(linkedShare, animated: true, completion: nil)
//                }
//            }else{
//                let shareURL = URL(string: self.listCategory.link!)
//
//                var urlComponents = URLComponents(string:
//                    "https://www.linkedin.com/in/sinead-white-68755423/")
//
//                urlComponents!.queryItems = [URLQueryItem(name: "url", value: shareURL!.absoluteString)]
//
//                let url = urlComponents!.url!
//
//                if #available(iOS 9.0, *) {
//                    let svc = SFSafariViewController(url: url)
//                    svc.delegate = self as? SFSafariViewControllerDelegate
//                    self.present(svc, animated: true, completion: nil)
//                } else {
//                    debugPrint("Not available")
//                }
//            }
//        }
//    }
//    @IBAction func actionGooglePlusShare(_ sender: Any) {
//        let shareURL = URL(string: self.listCategory.link!)
//
//        var urlComponents = URLComponents(string: "https://plus.google.com/share")
//
//        urlComponents!.queryItems = [URLQueryItem(name: "url", value: shareURL!.absoluteString)]
//
//        let url = urlComponents!.url!
//
//        if #available(iOS 9.0, *) {
//            let svc = SFSafariViewController(url: url)
//            svc.delegate = self as? SFSafariViewControllerDelegate
//            self.present(svc, animated: true, completion: nil)
//        } else {
//            debugPrint("Not available")
//        }
//    }
