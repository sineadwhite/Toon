//
//  GlobalConstant.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper

let API_VERSION_V1 = false

class Constant{

    var THEMECOLOR = UIColor().hexStringToUIColor(hex: "ff0081")
    
    var NETWORKMESSAGE = "No Network available"
    

    var ADBOTTOMBANNER = "ca-app-pub-2974739507750700/2026082674"
    var ADFULLBANNER = "ca-app-pub-2974739507750700/2026082674"

    var ADAPPKEY = "ca-app-pub-2974739507750700~4871737864"
    var ADNATIVE = "ca-app-pub-2974739507750700/3422924822"

    var ONESIGNALAPPID = "b6d66679-1757-47bc-9c36-bb7ebd8e35ec"
    
    var NUMBER_NEWS_SHOW_ADS = 5
    var listCategoryNotShow = ["featured","politics","uncategorized","test2","test3"]
    
    // use default menu
//     var listMenuAdd = [] as [NewsNameData]
    
    //add menu items to Left Menu
    var listMenuAdd = [NewsNameData(name: "Map Search", linkUrl: "https://www.intolerablegluten.com/map-search-worldwide",position: 2), NewsNameData(name: "Book NY Walking Food Tour", linkUrl: "https://www.viator.com/tours/New-York-City/Walking-Gluten-Free-Food-Tour-of-New-York-City/d687-287023P1", position: 1)]
    
    //use default icon for menu items
//    var listIcon = [] as [ModelImage]
    
    //mapping icon to menu items, "name" is case-sensitive
    var listIcon = [ModelImage(linkImage: "money",name: "Business"), ModelImage(linkImage: "splash",name: "Entertainment"), ModelImage(linkImage: "headphones",name: "Music"), ModelImage(linkImage: "computer",name: "Technology"), ModelImage(linkImage: "running",name: "Sports"), ModelImage(linkImage: "basketball",name: "Basketball"), ModelImage(linkImage: "soccer",name: "Football"), ModelImage(linkImage: "blockchain",name: "Blockchain"), ModelImage(linkImage: "mobile",name: "Mobile"), ModelImage(linkImage: "software",name: "Software"), ModelImage(linkImage: "youtube",name: "Youtube"), ModelImage(linkImage: "google",name: "Google")]
    
    var user = "admin"
    var pass = "AGgQ 5cRT 9Yiw W0dS 6J6n kTWL"
    
    var navigationTitle = "Gluten Free Traveling Toon"
    var isShowComment = true
    var HOME_ANDROID = true
    var FORCE_RTL = false
    var DEVICE_TOKEN = "device_token"
    var emble = API_VERSION_V1 ? "" : "_embed"
    var LIVETVURL = "https://www.youtube.com/channel/UCn1P8pwDRwBqcvcJd8oYB5A"
    
    func cacheListCategory(_ list: [NewsNameData]) {
        UserDefaults.standard.set(list.toJSONString() ?? "", forKey: "CATEGORY")
        UserDefaults.standard.synchronize()
    }
    
    func getListCacheCategory() -> [NewsNameData]{
        guard let str = UserDefaults.standard.value(forKey: "CATEGORY") as? String, let list = Mapper<NewsNameData>().mapArray(JSONString: str) else {
            return [NewsNameData]()
        }
        
        return list
    }
    
    func getCategory(width cateId: Int) -> NewsNameData?{
        let listFilter = self.getListCacheCategory().filter({ return ($0.id ?? 0) == cateId })
        if listFilter.count == 0{
            return nil
        }
        
        return listFilter[0]
    }
}


extension UIFont{
    static var boldFontName = "Roboto-Bold"
    static var mediumFontName = "Roboto-Medium"
    
    static func customBold(_ size: CGFloat) -> UIFont{
        guard let font = UIFont.init(name: boldFontName, size: size) else {
            return boldSystemFont(ofSize: size)
        }
        
        return font
    }
    
    static func customMedium(_ size: CGFloat) -> UIFont{
        guard let font = UIFont.init(name: mediumFontName, size: size) else {
            return boldSystemFont(ofSize: size)
        }
        
        return font
    }
}
