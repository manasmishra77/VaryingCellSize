//
//  VaryingCellSizeCollectionView.swift
//  CellSizeAnimation
//
//  Created by Manas Mishra on 28/12/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

struct VaryingCellCVContants {
    static var screenMiddlePoint: CGFloat {
        return UIScreen.main.bounds.width/2 + screenMiddlePointPatch
    }  // Used for scaling
    
    //Patch Constants
    static let screenMiddlePointPatch: CGFloat = -68
    static let wapperScrollViewContentWidthPatch: CGFloat = 0
    
    static let minimumScaleValue: CGFloat = 0.7
}

protocol VaryingCellSizeCollectionViewDelgate {
    func numberOfItemFor(collectionView: VaryingCellSizeCollectionView) -> Int
    func cellForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> UIView
    func itemSizeForIndex(_ collectionView: VaryingCellSizeCollectionView,  index: Int) -> CGSize
    func selectedItemIndex(_ index: Int)
}


class VaryingCellSizeCollectionView: UICollectionView {
    fileprivate var wrapperScrollView: UIScrollView!
    fileprivate var collViewDelegate: VaryingCellSizeCollectionViewDelgate!
    fileprivate var cellWidth: CGFloat = 0.0
    fileprivate var scrollingDirection: ScrollingDirection?
    fileprivate let affineIdentity = CGAffineTransform.identity

    func initialSetUp(delegate: VaryingCellSizeCollectionViewDelgate) {
        let cellNib = UINib.init(nibName: "VariableSizeCollectionViewCell", bundle: nil)
        self.register(cellNib, forCellWithReuseIdentifier: "VariableCell")
        self.isScrollEnabled = false
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.delegate = self
        self.dataSource = self
        self.collViewDelegate = delegate
        self.reloadData()
        self.layoutIfNeeded()
        
        //Add ScrollView
        let wrapperScrollViewFrame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        wrapperScrollView = UIScrollView(frame: wrapperScrollViewFrame)
        self.superview?.addSubview(wrapperScrollView)
        let contentHeight = wrapperScrollView.frame.height
        let contentWidth: CGFloat = cellWidth*CGFloat((self.numberOfItems(inSection: 0))) + VaryingCellCVContants.wapperScrollViewContentWidthPatch
        wrapperScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        wrapperScrollView.delegate = self
//        wrapperScrollView.backgroundColor = .black
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
                cell.sizeVaryingView.transform = affineIdentity.scaledBy(x: scale, y: scale)
                cell.sizeVaryingView.alpha = scale
            }
        }
    }
    
    //Used for stopping scrolview at specific position
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollingDirection = (velocity.x>0) ? .left : .right
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            //adjustContentOffSetFor3Views(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustContentOffSetFor3Views(scrollView)
    }
}

//Used to calculate scale
extension VaryingCellSizeCollectionView {
    func getScale(offSet: CGFloat, cellX: CGFloat) -> CGFloat {
        let actualX = cellX - offSet
        var scale: CGFloat = 0
        let mP = VaryingCellCVContants.screenMiddlePoint
        if (actualX > mP), (actualX < UIScreen.main.bounds.width) {
            scale = (1 - ((actualX - mP)/mP))
        } else if (actualX > 0) {
            scale = actualX / mP
        }
        scale = (scale < 0) ? -scale : scale
        //print("Scale: \(scale)")
        
        if scale < VaryingCellCVContants.minimumScaleValue {
            return VaryingCellCVContants.minimumScaleValue
        }
        return scale
    }
}


//Requirement related methods
extension VaryingCellSizeCollectionView {
    func getFinalOffsetOfScrollView(currentOffset: CGPoint) -> CGPoint {
        let mod = Int(currentOffset.x)%Int(cellWidth)
        let multiplierAddition = (scrollingDirection == .left) ? -1: 1
        let multiplier = (mod > Int(cellWidth/2)) ? (Int(currentOffset.x)/Int(cellWidth)) + multiplierAddition: (Int(currentOffset.x)/Int(cellWidth))
        let requiredOffSetX = Int(cellWidth)*multiplier
        if mod == 0 {
            return currentOffset
        } else {
            var newOffSet = currentOffset
            newOffSet.x = CGFloat(requiredOffSetX)
            return newOffSet
        }
    }
    func adjustContentOffSetFor3Views(_ scrollView: UIScrollView) {
        
        let cellArray = self.indexPathsForVisibleItems
        let middleCell = Int(cellArray.count/2)
        let indexPath = cellArray[middleCell]
        let scrollPositionX = indexPath.row * Int(UIScreen.main.bounds.width/3) + Int(UIScreen.main.bounds.width/6)
//        self.contentOffset = getFinalOffsetOfScrollView(currentOffset: scrollView.contentOffset)
        DispatchQueue.main.async {
            self.wrapperScrollView.contentOffset.x = CGFloat(scrollPositionX)
            self.scrollingDirection = nil
        }
    }
    enum ScrollingDirection {
        case left
        case right
    }
}
