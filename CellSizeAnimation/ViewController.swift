//
//  ViewController.swift
//  CellSizeAnimation
//
//  Created by Manas Mishra on 27/12/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: VaryingCellSizeCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.initialSetUp(delegate: self)
    }
}

extension ViewController: VaryingCellSizeCollectionViewDelgate {
    func focusedCellIndex(_ index: Int) {
        print(index)
    }
    
    func numberOfItemFor(collectionView: VaryingCellSizeCollectionView) -> Int {
        return 10
    }
    
    func cellForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> UIView {
        let newView = UILabel(frame: CGRect.zero)
        newView.text = "\(index)"
        newView.backgroundColor = .red
        return newView
    }
    
    func itemSizeForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> CGSize {
        let width = UIScreen.main.bounds.width/3
        return CGSize(width: width, height: 160)
    }
    func selectedItemIndex(_ index: Int) {
        
    }
}

 

