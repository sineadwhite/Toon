//
//  NewsModal.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import Foundation
import ObjectMapper

class NewsData: Mappable{
    var title : String? // = Title()
    var category_arr = [CategoryArray]()
    var content : String?
    var id: Int?
    var date: String?
    var dateString: String?
    var link: String?
    var featured_image_link: String?
    var img : UIImage?
    var cateId = 0
    
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    var slug: String{
        if API_VERSION_V1{
            var slug = ""
            if category_arr.count > 1{
                slug = category_arr[1].slug ?? ""
            }else if category_arr.count > 0{
                slug = category_arr[0].slug ?? ""
            }
            
            return slug
        }else{
            guard let cate = Constant().getCategory(width: cateId) else {
                return ""
            }
            
            return cate.slug ?? ""
        }
    }
    
    var categoryName: String{
        if API_VERSION_V1{
            var name = ""
            if category_arr.count > 1{
                name = category_arr[1].name ?? ""
            }else if category_arr.count > 0{
                name = category_arr[0].name ?? ""
            }
            
            return name
        }else{
            guard let cate = Constant().getCategory(width: cateId) else {
                return ""
            }
            
            return cate.name ?? ""
        }
    }
    
    
    func mapping(map: Map) {
        if let titel = map.JSON["title"] as? NSDictionary{
            title = titel["rendered"] as? String ?? ""
        }
        
        link <- map["link"]
        id <- map["id"]
        
        if let dateStr = map.JSON["date"] as? String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            if let d = dateFormatter.date(from: dateStr){
                dateFormatter.dateFormat = "MMMM dd yyy"
                dateString = dateFormatter.string(from: d)
                date = dateFormatter.string(from: d)
            }
        }
        
        if let c = map.JSON["content"] as? NSDictionary{
            content = c["rendered"] as? String ?? ""
        }
        
        if let i = map.JSON["better_featured_image"] as? NSDictionary{
            featured_image_link = i["post_thumbnail"] as? String
        }
        
        if let a = map.JSON["_embedded"] as? [String: Any], let media = a["wp:featuredmedia"] as? [[String: Any]], media.count > 0{
            let mData = media[0]
            featured_image_link = mData["source_url"] as? String
        }
        
        category_arr <- map["categories_detail"]
        
        if let c = map.JSON["categories"] as? [Int]{
            if c.count > 1{
                cateId = c[1]
            }else if c.count > 0{
                cateId = c[0]
            }
        }else if category_arr.count > 0{
            cateId = Int(category_arr[0].id ?? "") ?? 0
        }
    }
}



//extension NewsData : JSONParsable{
//    init?(json: JSONType?) {
//        let titel = json?["title"] as? NSDictionary
//        self.title = titel!["rendered"] as? String
//        let categoryArray = json?["category_arr"] as! [JSONType]
//        let pics = categoryArray.flatMap(CategoryArray.init)
//        self.category_arr.append(contentsOf: pics)
//        let content = json?["content"] as? NSDictionary
//        self.content = content!["rendered"] as? String
//
//        self.link = json?["link"]  as? String
//        self.id = json?["id"] as? Int
//        self.date = json?["date"] as? String
//        self.dateString = json?["dateString"] as? String
//        self.featured_image_link = json?["featured_image_link"] as? String
//    }
//}

struct Title{
    var rendered: String?
}

struct Content{
    var rendered: String?
    //    var protected: Bool?
}

class CategoryArray: Mappable {
    var id: String?
    var name: String?
    var slug: String?
    var parent: Int?
    
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        slug <- map["slug"]
        parent <- map["parent"]
    }
}

class NewsNameData: Mappable {
    var id: Int?
    var name: String?
    var parent: Int?
    var isSelect: Bool?
    var subCat: String?
    var slug: String?
    var count = 0
    var isHaveSub: Bool?
    var linkUrl: String?
    var position: Int?
    required init?(map: Map){
        
    }
    init() {
    }
    
    init(id: Int?,name: String?,parent: Int?,isSelect: Bool?,subCat: String?,slug: String?,isHaveSub: Bool?) {
        self.id = id
        self.name = name
        self.parent = parent
        self.isSelect = isSelect
        self.subCat = subCat
        self.slug = slug
        self.isHaveSub = isHaveSub
    }
    
    init(name: String?,linkUrl: String?) {
        self.name = name
        self.linkUrl = linkUrl
    }
    init(name: String?,linkUrl: String?,position: Int?) {
           self.name = name
           self.linkUrl = linkUrl
           self.position = position
       }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        parent <- map["parent"]
        isSelect <- map["isSelect"]
        subCat <- map["subCat"]
        count <- map["count"]
        slug <- map["slug"]
    }
}

struct ViewComments {
    var author_name: String?
    var content = CommentContent()
    var date: String?
    var dateString: String?
    var status: String?
}

struct CommentContent {
    var rendered: String?
}

class News{
    func getPostDetail(_ postId: Int,_ complet: @escaping ((NewsData?)->())){
        Webservice.web_news.webserviceFetchObjGetNew(parameters: API_VERSION_V1 ? "/\(postId)" : "/\(postId)?_embed") { (json) in
            guard let j = json, let newData = Mapper<NewsData>.init().map(JSON: j) else{
                complet(nil)
                return
            }
            
            complet(newData)
        }
        //
        //        Webservice.web_news.webserviceFetchObjGet(parameters: "/\(postId)") { (parsedData) in
        //            var newsData = NewsData()
        //            guard let dict = parsedData else{
        //                return
        //            }
        //
        //            let dateString = dict["date"] as? String ?? ""
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //
        //            if let date = dateFormatter.date(from: dateString){
        //                dateFormatter.dateFormat = "MMMM dd yyy"
        //                newsData.dateString = dateFormatter.string(from: date)
        //                newsData.date = dateFormatter.string(from: date)
        //            }
        //
        //            if let titel = dict["title"] as? NSDictionary{
        //                newsData.title = titel["rendered"] as? String ?? ""
        //            }
        //
        //            if let categoryArray = dict["categories_detail"] as? [JSONType]{
        //                let pics = categoryArray.compactMap({ return CategoryArray.init(JSON: $0) })
        //                newsData.category_arr.append(contentsOf: pics)
        //            }
        //
        //            if let content = dict["content"] as? NSDictionary{
        //                newsData.content = content["rendered"] as? String ?? ""
        //            }
        //
        //            newsData.link = dict["link"]  as? String
        //            newsData.id = dict["id"] as? Int
        //
        //            if let imageData = dict["better_featured_image"] as? NSDictionary{
        //                newsData.featured_image_link = imageData["post_thumbnail"] as? String
        //            }
        //
        //            complet(newsData)
        //        }
    }
    
    func getAllNews(parameter : String ,completion:(([NewsData],(Bool),(String))->())?){
        Webservice.web_news.webserviceFetchGetNew(parameters: parameter) { (json) in
            guard let j = json else{
                completion?([NewsData](), false,"No more data")
                return
            }
            
            let listNewData = Mapper<NewsData>.init().mapArray(JSONArray: j)
            if listNewData.count == 0{
                completion?([NewsData](), false,"No more data")
            }else{
                completion?(listNewData, true,"Success")
            }
        }
        //
        //        var newsList = [NewsData]()
        //        Webservice.web_news.webserviceFetchGet(parameters: parameter)
        //        { (parsedData,error,httpResponse) in
        //            if(error){
        //                completion!(newsList, false,Constant().NETWORKMESSAGE)
        //            }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
        //                if let parsedData = parsedData{
        //                    for info in parsedData{
        //                        var newsData = NewsData()
        //                        if let dict = info as? NSDictionary{
        //                            let dateString = dict["date"] as? String ?? ""
        //                            let dateFormatter = DateFormatter()
        //                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //
        //                            if let date = dateFormatter.date(from: dateString){
        //                                dateFormatter.dateFormat = "MMMM dd yyy"
        //                                newsData.dateString = dateFormatter.string(from: date)
        //                                newsData.date = dateFormatter.string(from: date)
        //                            }
        //
        //                            if let titel = dict["title"] as? NSDictionary{
        //                                newsData.title = titel["rendered"] as? String ?? ""
        //                            }
        //
        //                            if let categoryArray = dict["categories_detail"] as? [JSONType]{
        //                                let pics = categoryArray.compactMap { (dic) -> CategoryArray in
        //                                    let cate = CategoryArray()
        //                                    cate.mapping(map: Map.init(mappingType: .fromJSON, JSON: dic))
        //                                    return cate
        //                                }
        //                                newsData.category_arr.append(contentsOf: pics)
        //                            }
        //
        //                            if let content = dict["content"] as? NSDictionary{
        //                                newsData.content = content["rendered"] as? String ?? ""
        //                            }
        //
        //                            newsData.link = dict["link"]  as? String
        //                            newsData.id = dict["id"] as? Int
        //
        //                            if let imageData = dict["better_featured_image"] as? NSDictionary{
        //                                newsData.featured_image_link = imageData["post_thumbnail"] as? String
        //                            }
        //
        //                            newsList.append(newsData)
        //                        }
        //                    }
        //                }
        //
        //                completion!(newsList, true,"Success")
        //            }else if httpResponse.statusCode == 401{
        //                completion!(newsList, false,"Page not found")
        //            }else if httpResponse.statusCode == 400{
        //                //            self.flagLoad = false
        //                completion!(newsList, false,"No more data")
        //            }
        //        }
    }
}
