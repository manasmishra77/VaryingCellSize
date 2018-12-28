//
//  VaryingCellSizeCollectionView.swift
//  CellSizeAnimation
//
//  Created by Manas Mishra on 28/12/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

protocol VaryingCellSizeCollectionViewDelgate {
    func numberOfItemFor(collectionView: VaryingCellSizeCollectionView) -> Int
    func cellForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> UIView
    func itemSizeForIndex(_ collectionView: VaryingCellSizeCollectionView,  index: Int) -> CGSize
}


class VaryingCellSizeCollectionView: UICollectionView {
    var wrapperScrollView: UIScrollView!
    var collViewDelegate: VaryingCellSizeCollectionViewDelgate!
    var screenMiddlePoint = UIScreen.main.bounds.width/2 // Used for scaleing

    func initialSetUp(delegate: VaryingCellSizeCollectionViewDelgate) {
        let cellNib = UINib.init(nibName: "VariableSizeCollectionViewCell", bundle: nil)
        self.register(cellNib, forCellWithReuseIdentifier: "VariableCell")
        self.isScrollEnabled = false
        self.delegate = self
        self.dataSource = self
        self.reloadData()
        self.layoutIfNeeded()
        
        //ADD ScrollView
        wrapperScrollView = UIScrollView(frame: self.bounds)
        self.addSubview(wrapperScrollView)
        //let contentHeight = wrapperScrollView.frame.height
        //let contentWidth: CGFloat =
        wrapperScrollView.contentSize = contentSize
        wrapperScrollView.delegate = self
    }
}
extension VaryingCellSizeCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collViewDelegate.numberOfItemFor(collectionView: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VariableCell", for: indexPath) as? VariableSizeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.sizeVaryingView.addSubview(collViewDelegate.cellForIndex(self, index: indexPath.row))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collViewDelegate.itemSizeForIndex(self, index: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.contentOffset = scrollView.contentOffset
        for cell in self.visibleCells {
            if let cell = cell as? VariableSizeCollectionViewCell {
                let scale = getScale(offSet: scrollView.contentOffset.x, cellX: cell.frame.origin.x)
                let affineIdentity = CGAffineTransform.identity
                cell.sizeVaryingView.transform = affineIdentity.scaledBy(x: scale, y: scale)
            }
        }
    }  
}

//Used to calculate scale
extension VaryingCellSizeCollectionView {
    func getScale(offSet: CGFloat, cellX: CGFloat) -> CGFloat {
        let actualX = cellX - offSet
        var scale: CGFloat = 0
        if actualX > (screenMiddlePoint) {
            scale = (1 - ((actualX - screenMiddlePoint)/screenMiddlePoint))
        } else {
            scale = actualX / screenMiddlePoint
        }
        scale = (scale < 0) ? -scale : scale
        //print("Scale: \(scale)")
        return scale
    }
}