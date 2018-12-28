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
    func numberOfItemFor(collectionView: VaryingCellSizeCollectionView) -> Int {
        return 10
    }
    
    func cellForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> UIView {
        return UIView()
    }
    
    func itemSizeForIndex(_ collectionView: VaryingCellSizeCollectionView, index: Int) -> CGSize {
        return CGSize(width: 160, height: 160)
    }
}
 

