//
//  MenuVC.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {
    @IBOutlet weak var tableSideMenu: UITableView!
    @IBOutlet var viewMenu: UIView!
    var listCategoty = [NewsNameData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         var  deviceLanguage = ""
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
               if(deviceLanguage == "ar"){
                   UIView.appearance().semanticContentAttribute = .forceRightToLeft
               } else{
                   UIView.appearance().semanticContentAttribute = .forceLeftToRight
               }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }

        self.viewMenu.backgroundColor = Constant().THEMECOLOR
        self.tableSideMenu.backgroundColor = Constant().THEMECOLOR
        
        self.tableSideMenu.rowHeight = UITableView.automaticDimension
        self.tableSideMenu.estimatedRowHeight = 50.0
        
//        self.tableSideMenu.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(true)
       }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if self.view.frame.size.height > self.view.frame.size.width{
            self.tableSideMenu.isScrollEnabled = true
        }else{
            self.tableSideMenu.isScrollEnabled = false
        }
        
//        coordinator.animate(alongsideTransition: { context in
//            // Save the visible row position
//            self.visibleRows = self.tableView.indexPathsForVisibleRows!
//            context.viewController(forKey: UITransitionContextViewControllerKey.from)
//        }, completion: { context in
//            // Scroll to the saved position prior to screen rotate
//            self.tableView.scrollToRow(at: self.visibleRows[0], at: .top, animated: false)
//        })
    }

//    func alertOkAction(string: String){
//        let alert = UIAlertController(title: "WP News", message: string, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
//            if self.isContactUs{
//                self.goToHomeScreen()
//            }else{
//                self.goBackToDetails()
//            }
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
}


extension MenuVC : UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2{
            return 1
        }else{
            return listCategoty.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableSideMenu.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SliderTableViewCell
        if indexPath.section == 0 || indexPath.section == 2{
            cell.sliderLbl.text = indexPath.section == 0 ? "Home" : "Settings"
            cell.sliderImageView.image = indexPath.section == 0 ? UIImage(named: "icon_home") : UIImage(named: "icon_settings")
        }else{
            let category = listCategoty[indexPath.row]
            cell.sliderLbl.text = category.name
            cell.sliderImageView.image = UIImage(named: "icon_category")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let disController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")  as! HomeVC
            let newFrontViewController = UINavigationController.init(rootViewController:disController)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }else if indexPath.section == 2{
            let disController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            let newFrontViewController = UINavigationController.init(rootViewController:disController)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }else{
            
            guard let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as? NewsVC, indexPath.row < listCategoty.count else {
                return
            }
            
            let category = listCategoty[indexPath.row]
            newsVC.viewTitle = category.name ?? ""
            newsVC.catId = category.id ?? 0
            newsVC.isRoot = true
            let newFrontViewController = UINavigationController.init(rootViewController: newsVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
    }
}
