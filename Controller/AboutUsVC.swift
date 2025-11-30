//
//  AboutUsVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import WebKit

class AboutUsVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var viewTitle = String()
    var typelink = false
    var linkURL = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        var deviceLanguage = ""
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
               if( deviceLanguage == "ar"){
                   UIView.appearance().semanticContentAttribute = .forceRightToLeft
               } else{
                   UIView.appearance().semanticContentAttribute = .forceLeftToRight
               }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }
        
        self.title = viewTitle.count > 0 ? viewTitle : Constant().navigationTitle
        
        if viewTitle == "About Us" {
            let url = URL (string: "https://www.intolerablegluten.com/about-me")
            let requestObj = URLRequest(url: url!)
            webView.load(requestObj)
            
        }else{
            if(typelink){
                let revealController : SWRevealViewController? = revealViewController()

                           let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
                           navigationItem.leftBarButtonItem = revealBarButton
                

                           if revealViewController() != nil {
                               revealBarButton.target = revealViewController()
                               revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
                               view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                           }
                           
                           self.navigationController?.setNavigationBarHidden(false, animated: true)
                let url = URL (string: linkURL)
                           let requestObj = URLRequest(url: url!)
                           webView.load(requestObj)
            } else {
            let revealController : SWRevealViewController? = revealViewController()

            let revealBarButton : UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .plain, target: revealController, action: #selector(revealController!.revealToggle(_:)))
            navigationItem.leftBarButtonItem = revealBarButton

            if revealViewController() != nil {
                revealBarButton.target = revealViewController()
                revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)

            loadYoutube(videoID: Constant().LIVETVURL)
        }
        }
    }
    
    func loadYoutube(videoID:String) {
        guard
            let youtubeURL = URL(string: "\(videoID)")
            else { return }
        webView.load( URLRequest(url: youtubeURL) )
    }
}


