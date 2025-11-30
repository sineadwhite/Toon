//
//  CategoryListVC.swift
//  WPNews
//
//  Created by itechnotion-mac1 on 29/06/18.
//  Copyright © 2018 itechnotion-mac1. All rights reserved.
//

import UIKit
import ObjectMapper

class CategoryListVC: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var tableCategoryList: UITableView!
    
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    var listCategoryName = [NewsNameData]()
    var activity = UIActivityIndicatorView()
    
    var searchBar:UISearchBar = UISearchBar()
    let window = UIApplication.shared.keyWindow!
    var viewSearch = UIView()
    var viewTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.title = viewTitle
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        
        let revealController : SWRevealViewController? = revealViewController()
        
//        revealController?.panGestureRecognizer
//        revealController?.tapGestureRecognizer
        
        let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
        navigationItem.leftBarButtonItem = revealBarButton
        
        if revealViewController() != nil {
            revealBarButton.target = revealViewController()
            revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tableListCategory = UINib(nibName: "NewsHeader", bundle: nil)
        tableCategoryList.register(tableListCategory, forHeaderFooterViewReuseIdentifier: "NewsHeader")
        
        let tableLatestNews = UINib(nibName: "CategoryListCell", bundle: nil)
        tableCategoryList.register(tableLatestNews, forCellReuseIdentifier: "cell")
        
        viewSearch = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44))
        viewSearch.backgroundColor = .white
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.placeholder = "Search"
        searchBar.backgroundColor = .blue
        searchBar.delegate = self
        viewSearch.addSubview(searchBar)
        self.addDoneButtonOnKeyboard()

        self.getCategoryList()
        self.activityIndication(view: tableCategoryList)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    //MARK:- IBAction methods (Click Events)
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
    //MARK:- Get Category Name
    func getCategoryList(){
        Webservice.web_category_all.webserviceFetchGetNew(parameters: "?per_page=100") {[weak self] (json) in
            guard let self = self, let j = json else{
                return
            }
            
            self.listCategoryName.removeAll()
            self.listCategoryName = Mapper<NewsNameData>.init().mapArray(JSONArray: j).filter({ return ($0.parent ?? 0) == 0 })
            self.tableCategoryList.reloadData()
        }
        
        /*
        Webservice.web_category_all.webserviceFetchGet(parameters: "?per_page=100")
        { (parsedData,error,httpResponse) in
            print(parsedData as Any)
            if(error){
                print("Network error")
            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                for info in parsedData!{
                    var newsName = NewsNameData()
                    print(info)
                    if let dict = info as? NSDictionary{
                        print(dict)
                        let parent = dict["parent"] as? Int
                        if (parent == 0){
                            let aString = dict["name"] as! String
                            let newString = aString.replacingOccurrences(of: "&amp;", with: "&")
                            newsName.name = newString
                            newsName.id = dict["id"] as? Int
                            self.listCategoryName.append(newsName)
                        }
                    }
                }
                self.tableCategoryList.reloadData()
            }else if httpResponse.statusCode == 401{
                print("Error")
            }
        }*/
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
}
//TableView Methods
extension CategoryListVC: UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2//self.listCategoryName.count+1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 0
        }else{
            return self.listCategoryName.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryListCell
        stopActivityIndicator()
        cell.lblCategoryName.text = listCategoryName[indexPath.row].name
        let requestResponse = listCategoryName[indexPath.row].name
        let separated = requestResponse?.split(separator: " ")
        if let some = separated?.first {
            cell.lblCategoryWord.text = String(some.first!)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let SubCategoryListVC = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryListVC") as! SubCategoryListVC
            SubCategoryListVC.listId = self.listCategoryName
            SubCategoryListVC.viewTitle = self.listCategoryName[indexPath.row].name!
            SubCategoryListVC.catId = self.listCategoryName[indexPath.row].id!
            self.navigationController?.pushViewController(SubCategoryListVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 70
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if 0 == section{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NewsHeader") as! NewsHeader
            headerView.lblCategory.text = "Latest News"
            headerView.lblAbbriviation.text = String((headerView.lblCategory.text?.prefix(1))!)
            headerView.row = section
            headerView.onClick = { (rowCount) in
                let NewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
                NewsVC.viewTitle = "Latest News"
                NewsVC.catId = 0
                self.navigationController?.pushViewController(NewsVC, animated: true)
            }
            return headerView
        }else{
            return nil
            }
    }
}
