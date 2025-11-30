//
//  ContactUsVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
class ContactUsVC: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var scrollBottom: NSLayoutConstraint!
    @IBOutlet weak var scroll : UIScrollView!
    @IBOutlet weak var viewForm: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtfieldUserName: UITextField!
    @IBOutlet weak var txtfieldUserEmail: UITextField!
    @IBOutlet weak var txtViewMessage: UITextView!
    @IBOutlet weak var btnSendPressed: UIButton!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    
    var isContactUs = Bool()
    var newsTitle = String()
    var newsId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var deviceLanguage = ""
                if Constant().FORCE_RTL{
                    deviceLanguage = "ar"
                }
        
               if(deviceLanguage == "ar"){
                   UIView.appearance().semanticContentAttribute = .forceRightToLeft
                txtfieldUserName.textAlignment = .right
                txtfieldUserEmail.textAlignment = .right
                txtViewMessage.textAlignment = .right

               } else{
                   UIView.appearance().semanticContentAttribute = .forceLeftToRight
               }
        lblTitle.font = UIFont.customMedium(20)
        txtfieldUserName.font = UIFont.customMedium(13)
        txtfieldUserEmail.font = UIFont.customMedium(13)
        txtViewMessage.font = UIFont.customMedium(13)
        btnSendPressed.titleLabel?.font = UIFont.customMedium(17)
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.title = Constant().navigationTitle
        
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        self.btnSendPressed.backgroundColor = Constant().THEMECOLOR
        self.viewForm.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        //        self.v.alpha = 0.0
        self.scroll.addSubview(viewForm)
        print(isContactUs)
        if isContactUs{
            lblTitle.text = "Contact Us"
        }else{
            lblTitle.text = newsTitle
        }
        if isContactUs{
            let revealController : SWRevealViewController? = revealViewController()
            
//            revealController?.panGestureRecognizer
//            revealController?.tapGestureRecognizer
            
            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
            navigationItem.leftBarButtonItem = revealBarButton
            
            if revealViewController() != nil {
                revealBarButton.target = revealViewController()
                revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
         if self.isContactUs{
            self.txtViewMessage.placeholder = "Brief Message"
         }else{
            self.txtViewMessage.placeholder = "Comment"
        }
        scroll.contentSize = CGSize(width:self.view.frame.width, height:self.scroll.frame.height)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    self.scrollBottom.constant = -keyboardFrame.size.height
                })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.scrollBottom.constant = 0
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchNewViewController") as? SearchNewViewController else {
            return
        }
        
        self.present(UINavigationController(rootViewController: searchVC), animated: false, completion: nil)
    }
    
    func alertOkAction(string: String){
        let alert = UIAlertController(title: Constant().navigationTitle, message: string, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            if self.isContactUs{
                self.goToHomeScreen()
            }else{
                self.goBackToDetails()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func goBackToDetails(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DetailNewsVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func goToHomeScreen(){
        let disController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")  as! HomeVC
        let newFrontViewController = UINavigationController.init(rootViewController:disController)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
    func displayAlertMessage(string: String){
        let alert = UIAlertController(title: Constant().navigationTitle, message: string, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func contactUs(){
        let parameters = "name=".appending(txtfieldUserName.text!).appending("&email=").appending(txtfieldUserEmail.text!).appending("&message=").appending(txtViewMessage.text!)
        Webservice.web_contactUs.webserviceFetch(parameters: parameters)
        { (parsedData,error,httpResponse) in
            print(parsedData as Any)
            if(error){
                print("Network error")
            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                print(parameters)
                let message = parsedData["message"] as? String ?? ""
                print(message as Any)
                self.alertOkAction(string: message)
                self.navigationController?.popViewController(animated: true)
                
            }else if httpResponse.statusCode == 401{
                print("Error")
            }
        }
    }
    
    func writeComments(){
        let parameters = "post=".appending(String(newsId)).appending("&author_name=").appending(txtfieldUserName.text!).appending("&author_email=").appending(txtfieldUserEmail.text!).appending("&content=").appending(txtViewMessage.text!)
        Webservice.web_view_comment.webserviceFetch(parameters: parameters)
        { (parsedData,error,httpResponse) in
            print(parsedData as Any)
            if(error){
                print("Network error")
            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                print(parameters)
//                let message = parsedData["message"] as? String ?? ""
//                print(message as Any)
                self.alertOkAction(string: "Comment posted successfully")
                self.navigationController?.popViewController(animated: true)
            }else if httpResponse.statusCode == 401{
                print("Error")
                self.alertOkAction(string: "Error posting comment")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func actionSendPressed(_ sender: Any) {
        if (txtfieldUserName.text!.isEmpty){
            self.displayAlertMessage(string: "Full Name field is required")
        }else if (txtfieldUserEmail.text!.isEmpty) {
            self.displayAlertMessage(string: "Email is required")
        }else if !(isValidEmail(testStr: txtfieldUserEmail.text!)){
            self.displayAlertMessage(string: "Please enter valid email address")
        }
        else if (txtViewMessage.text!.isEmpty){
                self.displayAlertMessage(string: "Message is required")
        }else{
            if isContactUs{
                self.contactUs()
            }else{
                self.writeComments()
            }
        }
    }
    
    @objc func doneButtonAction(){
    }
}


//TextField
extension ContactUsVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtfieldUserName {
            textField.resignFirstResponder()
        } else if textField == txtfieldUserEmail {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            if txtAfterUpdate.count < 2{
                let aSet = NSCharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567897890!@#$%^&*()_+}{|\"\\:~`-=><?,./").inverted
                let compSepByCharInSet = string.components(separatedBy: aSet)
                let numberFiltered = compSepByCharInSet.joined(separator: "")
                return string == numberFiltered
            }else{
                return true
            }
        }else{
            return true
        }
    }
}


//Text view
extension ContactUsVC: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard range.location == 0 else {
            return true
        }
        
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
}
