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
    func selectedItemIndex(_ index: Int)
}


class VaryingCellSizeCollectionView: UICollectionView {
    var wrapperScrollView: UIScrollView!
    var collViewDelegate: VaryingCellSizeCollectionViewDelgate!
    var screenMiddlePoint = UIScreen.main.bounds.width/2 // Used for scaleing
    var cellWidth: CGFloat = 0.0

    func initialSetUp(delegate: VaryingCellSizeCollectionViewDelgate) {
        let cellNib = UINib.init(nibName: "VariableSizeCollectionViewCell", bundle: nil)
        self.register(cellNib, forCellWithReuseIdentifier: "VariableCell")
        self.isScrollEnabled = false
        self.delegate = self
        self.dataSource = self
        self.collViewDelegate = delegate
        self.reloadData()
        self.layoutIfNeeded()
        
        //ADD ScrollView
        wrapperScrollView = UIScrollView(frame: self.frame)
        self.superview?.addSubview(wrapperScrollView)
        let contentHeight = wrapperScrollView.frame.height
        let contentWidth: CGFloat = cellWidth*CGFloat((self.numberOfItems(inSection: 0)))
        wrapperScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
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
        let mainView = collViewDelegate.cellForIndex(self, index: indexPath.row)
        mainView.frame = cell.sizeVaryingView.bounds
        cell.sizeVaryingView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: cell.sizeVaryingView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: cell.sizeVaryingView.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: cell.sizeVaryingView.leadingAnchor, constant: 0).isActive = true
        mainView.trailingAnchor.constraint(equalTo: cell.sizeVaryingView.trailingAnchor, constant: 0).isActive = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = collViewDelegate.itemSizeForIndex(self, index: indexPath.row)
        cellWidth = cellSize.width
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collViewDelegate.selectedItemIndex(indexPath.row)
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
    
    //Used for stopping scrolview at specific position
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.contentOffset = getFinalOffsetOfScrollView(currentOffset: targetContentOffset.pointee)
        scrollView.contentOffset = getFinalOffsetOfScrollView(currentOffset: targetContentOffset.pointee)
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
        
        //Used if only to constarint cell size
        if scale < 0.7 {
            return 0.7
        }
        return scale
    }
}


//Requirement related methods
extension VaryingCellSizeCollectionView {
    func getFinalOffsetOfScrollView(currentOffset: CGPoint) -> CGPoint {
        let mod = Int(currentOffset.x)%Int(cellWidth)
        let multiplier = Int(currentOffset.x)/Int(cellWidth)
        let requiredOffSetX = Int(cellWidth)*multiplier
        if mod == 0 {
            return currentOffset
        } else {
            var newOffSet = currentOffset
            newOffSet.x = CGFloat(requiredOffSetX)
            return newOffSet
        }
        
    }
}
