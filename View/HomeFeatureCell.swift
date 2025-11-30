//
//  HomeFeatureCell.swift
//  Ontin
//
//  Created by liemkk on 11/14/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class HomeFeatureCell: UITableViewCell {
    @IBOutlet weak var collectionFeatureNews: UICollectionView!
    @IBOutlet weak var collectionFeatureButton: UICollectionView!
    
    fileprivate var listNews = [NewsData]()
    fileprivate var listCategory = [NewsNameData]()
    
    var selectCategory: ((Bool, Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellNib = UINib(nibName: "HomeScreenCell", bundle: nil)
        collectionFeatureNews.register(cellNib, forCellWithReuseIdentifier: "cell")
        
        let cellNibButton = UINib(nibName: "HomeScreenButtonCell", bundle: nil)
        collectionFeatureButton.register(cellNibButton, forCellWithReuseIdentifier: "cellForButton")
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindingData(listNews: [NewsData], listCategory: [NewsNameData]) {
        self.listNews = listNews
        self.listCategory = listCategory
        
        self.collectionFeatureNews.reloadData()
        self.collectionFeatureButton.reloadData()
    }
    
}


extension HomeFeatureCell: UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.collectionFeatureNews){
            return listNews.count
        }
        else{
            return listCategory.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.collectionFeatureNews){
            let cell = collectionFeatureNews.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeScreenCell
            let new = self.listNews[indexPath.row]
            
            cell.imgFeatureNews.loadImageUsingCache(withUrl: new.featured_image_link ?? "")
            cell.lblNameFeatureNews.text = "   \(new.categoryName.uppercased())   "
            cell.lblDescFeatureNews.text = new.title?.htmlDecoded
            cell.lblDateFeatureNews.text = new.dateString
            return cell
        }else{
            let cell = collectionFeatureButton.dequeueReusableCell(withReuseIdentifier: "cellForButton", for: indexPath) as! HomeScreenButtonCell
            cell.lblFeatureNewsName.text = listCategory[indexPath.row].name
            
            if listCategory[indexPath.row].isSelect!{
                cell.lblFeatureNewsName.alpha = 1.0
            }else{
                cell.lblFeatureNewsName.alpha = 0.5
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.collectionFeatureNews {
            for (index, cate) in listCategory.enumerated() {
                if (cate.isSelect ?? false) {
                    cate.isSelect = false
                    listCategory[index] = cate
                    self.collectionFeatureButton.reloadItems(at: [IndexPath(row: index, section: 0)])
                }
                
                if index == indexPath.row {
                    cate.isSelect = true
                    listCategory[index] = cate
                    self.collectionFeatureButton.reloadItems(at: [indexPath])
                }
            }
        }
        
        selectCategory?(collectionView == self.collectionFeatureNews, indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.collectionFeatureButton){
            let size: CGSize = listCategory[indexPath.row].name!.size(withAttributes: nil)
            return CGSize(width: size.width + 60.0, height: collectionFeatureButton.frame.size.height)
        }else{
            return CGSize(width:357, height: 282)
        }
    }
}
