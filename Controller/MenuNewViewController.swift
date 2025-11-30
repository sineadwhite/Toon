//
//  MenuNewViewController.swift
//  OnWP
//
//  Created by dong luong on 1/3/20.
//  Copyright © 2020 Patcell. All rights reserved.
//

import UIKit
class MenuNewViewController: UIViewController,OnCLicSubMenuViewDelegate{
    func clickSubMenu(position: Int,section: Int) {
        print("Did select cell at section \(section) row \(position)")
        guard let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as? NewsVC else {
            return
        }
        
        let category = items[section][position]
        newsVC.viewTitle = category.name ?? ""
        newsVC.catId = category.id ?? 0
        newsVC.isRoot = true
        let newFrontViewController = UINavigationController.init(rootViewController: newsVC)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
    
    @IBOutlet weak var expandableTableView: LUExpandableTableView!
    var listCategoty = [NewsNameData]()
    var listCategotyParent = [NewsNameData]()
    let section = ["First Header", "Second Header", "Third Header"]
    //Array for Items in sections
    var items = [[NewsNameData]()]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        var deviceLanguage = ""
       
        if Constant().FORCE_RTL{
            deviceLanguage = "ar"
        }
        
        if(deviceLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        print(listCategoty)
        let headerNib = UINib.init(nibName: "MyExpandableTableViewSectionHeader", bundle:nil)
        expandableTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "MyExpandableTableViewSectionHeader")
        expandableTableView.register(UINib(nibName: "SubMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "SubMenuTableViewCell")
        expandableTableView.expandableTableViewDataSource = self
        expandableTableView.expandableTableViewDelegate = self
        
    }
}

extension MenuNewViewController: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        // return section.count
        return listCategotyParent.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        //        if(items[section] == [""]){
        //            return 0
        //        } else{
        return items[section].count
        // }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "SubMenuTableViewCell") as? SubMenuTableViewCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        cell.lblSubMenu.text = items[indexPath.section][indexPath.row].name
        cell.delegate = self
        cell.position = indexPath.row
        cell.section = indexPath.section
        cell.imgSubMenu.image = UIImage(named: "icon_category")
        if(!Constant().listIcon.isEmpty){
                   for i in 0...Constant().listIcon.count - 1{
                       if(Constant().listIcon[i].name == items[indexPath.section][indexPath.row].name ){
                          cell.imgSubMenu.image = UIImage(named: Constant().listIcon[i].linkImage ?? "icon_home")
                       }
                       
                   }
                   
               }
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "MyExpandableTableViewSectionHeader") as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        
        if(listCategotyParent[section].name == "Home"){
            sectionHeader.imgHome.image = UIImage(named: "icon_home")
        } else if(listCategotyParent[section].name == "Settings"){
            sectionHeader.imgHome.image = UIImage(named: "icon_settings")
        } else {
            sectionHeader.imgHome.image = UIImage(named: "icon_category")
        }
        
        sectionHeader.label.text = listCategotyParent[section].name
        if(!Constant().listIcon.isEmpty){
            for i in 0...Constant().listIcon.count - 1{
                if(Constant().listIcon[i].name == listCategotyParent[section].name ){
                    sectionHeader.imgHome.image = UIImage(named: Constant().listIcon[i].linkImage ?? "icon_home")
                }
                
            }
            
        } else {
            if(listCategotyParent[section].name == "Home"){
                sectionHeader.imgHome.image = UIImage(named: "icon_home")
            } else if(listCategotyParent[section].name == "Settings"){
                sectionHeader.imgHome.image = UIImage(named: "icon_settings")
            } else {
                sectionHeader.imgHome.image = UIImage(named: "icon_category")
            }
        }
        if(items[section].isEmpty ){
            sectionHeader.expandCollapseButton.isHidden = true
        } else {
            sectionHeader.expandCollapseButton.isHidden = false
        }
        
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension MenuNewViewController: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 50
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 50
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select section header at section \(section)")
        var isAdd = false
        var position = 0
        if(!Constant().listMenuAdd.isEmpty){
            for i in 0...Constant().listMenuAdd.count - 1{
                if(listCategotyParent[section].name == Constant().listMenuAdd[i].name){
                    isAdd = true
                    position = i;
                    break
                }
            }
        }
        if(listCategotyParent[section].name == "Home"){
            let disController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")  as! HomeVC
            disController.isClickMenu = true
            let newFrontViewController = UINavigationController.init(rootViewController:disController)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        } else if(listCategotyParent[section].name == "Settings"){
            let disController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            let newFrontViewController = UINavigationController.init(rootViewController:disController)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        } else if(isAdd){
            
            let disController = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            disController.typelink = true
            disController.linkURL = Constant().listMenuAdd[position].linkUrl ?? "https://www.youtube.com"
            let newFrontViewController = UINavigationController.init(rootViewController:disController)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
            
        }
        else
        {
            guard let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as? NewsVC else {
                return
            }
            
            let category = listCategotyParent[section]
            newsVC.viewTitle = category.name ?? ""
            newsVC.catId = category.id ?? 0
            newsVC.isRoot = true
            let newFrontViewController = UINavigationController.init(rootViewController: newsVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func expandableTableView(_ expandableTableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

