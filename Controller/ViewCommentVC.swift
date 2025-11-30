//
//  ViewCommentVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class ViewCommentVC: UIViewController {
    
    @IBOutlet weak var tableViewComments: UITableView!
    @IBOutlet weak var lblViewComments: UILabel!
    var newsId = Int()
    var flag: Bool = false
    var listComments = [ViewComments]()
    var activity = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        var deviceLanguage = ""
                if Constant().FORCE_RTL{
                    deviceLanguage = "ar"
                }
        
               if( deviceLanguage == "ar"){
                   UIView.appearance().semanticContentAttribute = .forceRightToLeft
               } else{
                   UIView.appearance().semanticContentAttribute = .forceLeftToRight
               }
        self.title = Constant().navigationTitle
        lblViewComments.font = UIFont.customBold(18)
        print(newsId)
        let cellNib = UINib(nibName: "CommentsListCell", bundle: nil)
        tableViewComments.register(cellNib, forCellReuseIdentifier: "cell")
        
        self.activityIndication(view: tableViewComments)
        self.getAllCommentsById()
    }
    
    //MARK:- GetAllComments
    func getAllCommentsById(){
        let parameters = "?post=\(newsId)"
        Webservice.web_view_comment.webserviceFetchGet(parameters: parameters)
        {[weak self] (parsedData,error,httpResponse) in
            guard let self = self else{
                return
            }
            
            if(error){
                print("Network error")
            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                self.listComments = [ViewComments]()
                
                for info in parsedData!{
                    var commentData = ViewComments()
                    if let dict = info as? NSDictionary{
                        commentData.author_name = dict["author_name"] as? String
                       
                        let array = dict["content"] as? NSDictionary
                        commentData.content.rendered = array!["rendered"] as? String
                        
                        commentData.date = dict["date"] as? String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        
                        if let date = dateFormatter.date(from: commentData.date ?? ""){
                            dateFormatter.dateFormat = "MMMM dd yyy"
                            commentData.dateString = dateFormatter.string(from: date)
                        }
                        
                        self.listComments.append(commentData)
                    }
                }
                
                self.flag = true
                self.tableViewComments.reloadData()
            }else if httpResponse.statusCode == 401{
                print("Error")
            }
        }
    }
    //MARK:-
    func activityIndication(view: UIView){
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.color = UIColor.black
        activity.clipsToBounds = true
        activity.center = CGPoint(x: self.tableViewComments.frame.width / 2, y: self.tableViewComments.frame.height / 2)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        view.addSubview(activity)
    }
    func stopActivityIndicator(){
        activity.stopAnimating()
    }
}
//MARK:- UITablevieDelegate and Datasource methods
extension ViewCommentVC : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flag {
            if listComments.count == 0{
                TableViewHelper.EmptyMessage(message: "No Data Available", viewController: self.tableViewComments)
            }else{
                TableViewHelper.EmptyMessage(message: "", viewController: self.tableViewComments)
            }
        }
        return listComments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewComments.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentsListCell
        self.stopActivityIndicator()
        cell.lblName.text = self.listComments[indexPath.row].author_name
        cell.lblComment.text = self.listComments[indexPath.row].content.rendered?.html2String
        cell.lblDate.text = self.listComments[indexPath.row].dateString
        return cell
    }
}
