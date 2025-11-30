//
//  WebserviceManager.swift
//  ENS
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import ObjectMapper
extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(URLRequest(url: URL(string: BASEURL)!))
        }
    }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
//BaseUrl

var BASEURL = "https://www.intolerablegluten.com/"

var VERSION = "wp-json/wp/v2/"
var VERSIONPOST = "api/"

enum Webservice : String{
        case web_category_all =      "categories"               //category_button
        case web_news =              "posts"                    // News
        case web_view_comment =      "comments"
        case web_contactUs =         "contact_us.php"
        case web_give_comment =      "comment.php"
        case web_sub_category =      "categories?per_page=100"
    
    func webserviceFetch(parameters: String, completion: (([String:Any],(Bool),(HTTPURLResponse))->())?) {
        URLCache.shared.removeAllCachedResponses()
        let urlPath =  BASEURL.appending(VERSION).appending(self.rawValue)
        let url = NSURL(string:urlPath as String)
        print(url!)
        var request = URLRequest(url: url! as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let username = Constant().user
        let password = Constant().pass
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            print("error \(String(describing: httpResponse?.statusCode))")
            if error != nil {
                DispatchQueue.main.async {
                    let parsedData:[String:Any] = [  // ["b": 12]
                        "A":"A",
                        ]
                    completion?(parsedData,true,HTTPURLResponse())
                }
            }
            guard let data = data, error == nil else {
                print(error!)                                 // some fundamental network error
                return
            }
            do {
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
                    DispatchQueue.main.async {
                        completion?(parsedData, false,httpResponse!)
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Get Method
    func webserviceFetchGet( parameters: String, completion: ((NSArray?,(Bool),(HTTPURLResponse))->())?) {
        URLCache.shared.removeAllCachedResponses()
        let param = parameters.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        let urlPath = BASEURL.appending(VERSION).appending(self.rawValue).appending(param)
        
        guard let url = NSURL(string:urlPath as String) else {
            return
        }
        
        print(url)
        var request = URLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let username = Constant().user
        let password = Constant().pass
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            print("error \(String(describing: httpResponse?.statusCode))")
            if error != nil {
                DispatchQueue.main.async {
                    let parsedData = NSArray()
                    completion?(parsedData , true, HTTPURLResponse())
                }
            }
            guard let data = data, error == nil else {                                                                                                                                                                                                                                  
                print(error!)                                 // some fundamental network error
                return
            }
            do {
                print(data)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as? NSArray {
                    DispatchQueue.main.async {
                        completion?((parsedData), false,httpResponse!)
                    }
                }
            }
        }
        task.resume()
    }
    
    func webserviceFetchGetNew(parameters: String, completion: (([[String: Any]]?) -> Void)?) {
        URLCache.shared.removeAllCachedResponses()
        let param = parameters.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        let urlPath = BASEURL.appending(VERSION).appending(self.rawValue).appending(param)
        
        let username = Constant().user
        let password = Constant().pass
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        
        let header = ["Authorization": "Basic \(base64LoginString)"]
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (reponse) in
            guard let data = reponse.value as? [[String: Any]] else{
                completion?(nil)
                return
            }
            
            completion?(data)
        }
    }
    
    
//    //MARK:- Get Method
//    func webserviceFetchObjGet( parameters: String, completion: (([String: Any]?) -> Void)?) {
//        let urlPath = BASEURL.appending(VERSION).appending(self.rawValue).appending(parameters)
//
//        let url = NSURL(string:urlPath as String)
//        var request = URLRequest(url: url! as URL)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        let username = Constant().user
//        let password = Constant().pass
//        let loginString = "\(username):\(password)"
//
//        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
//            return
//        }
//
//        let base64LoginString = loginData.base64EncodedString()
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            let httpResponse = response as? HTTPURLResponse
//
//            if error != nil {
//                DispatchQueue.main.async {
//                    completion?(nil)
//                }
//            }
//
//            guard let data = data, error == nil else {
//                completion?(nil)
//                return
//            }
//
//            do {
//                if let parsedData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                    DispatchQueue.main.async {
//                        completion?(parsedData)
//                    }
//                }
//            }catch{
//                completion?(nil)
//            }
//        }
//        task.resume()
//    }
    
    
    func webserviceFetchObjGetNew(parameters: String, completion: (([String: Any]?) -> Void)?) {
        URLCache.shared.removeAllCachedResponses()
        let urlPath = BASEURL.appending(VERSION).appending(self.rawValue).appending(parameters)
        
        let username = Constant().user
        let password = Constant().pass
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        
        let header = ["Authorization": "Basic \(base64LoginString)"]
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (reponse) in
            guard let data = reponse.value as? [String: Any] else{
                completion?(nil)
                return
            }
            
            completion?(data)
        }
    }
    
    
}

