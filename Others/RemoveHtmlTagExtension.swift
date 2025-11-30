//
//  RemoveHtmlTagExtension.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        self.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "default"), options: SDWebImageOptions.retryFailed, completed: nil)
//
//        self.image = nil
//
//        // check cached image
//        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
//            self.image = cachedImage
//            return
//        }else{
//            self.image = #imageLiteral(resourceName: "default")
//        }
//
//        // if not, download image from url
//        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//
//            if error != nil {
//                print(error!)
//                return
//            }
//
//            DispatchQueue.main.async {
//                if let image = UIImage(data: data!) {
//                    imageCache.setObject(image, forKey: urlString as NSString)
//                    self.image = image
//                }
//            }
//        }).resume()
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
