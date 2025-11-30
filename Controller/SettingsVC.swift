//
//  SettingsVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
//import UserNotifications
import OneSignal

class SettingsVC: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblPushNotification: UILabel!
    @IBOutlet weak var lblAboutUs: UIButton!
    @IBOutlet weak var lAboutUs: UILabel!
    @IBOutlet weak var barBtnSearch: UIBarButtonItem!
    
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
        lblSettings.font = UIFont.customBold(18)
        lblPushNotification.font = UIFont.customMedium(17)
        lAboutUs.font = UIFont.customMedium(16)
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.title = Constant().navigationTitle
        switchNotification.addTarget(self, action: #selector(stateChanged(switchState:)), for: .touchUpInside)
        self.barBtnSearch.tintColor = Constant().THEMECOLOR
        self.switchNotification.onTintColor = Constant().THEMECOLOR
        //Add Target for UISwitch
       
  
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc func stateChanged(switchState: UISwitch) {
        if switchNotification.isOn {
            if UIApplication.shared.responds(to: #selector(getter: UIApplication.isRegisteredForRemoteNotifications)) {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                // For iOS < 8
                UIApplication.shared.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
            }
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchNewViewController") as? SearchNewViewController else {
            return
        }
        
        self.present(UINavigationController(rootViewController: searchVC), animated: false, completion: nil)
    }
    
    @IBAction func actionAboutUs(_ sender: Any) {
        let AboutUsVC = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        AboutUsVC.viewTitle = "About Us"
        self.navigationController?.pushViewController(AboutUsVC, animated: true)
    }
    
    @objc func doneButtonAction(){
    }
}
