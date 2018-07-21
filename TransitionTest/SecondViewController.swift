//
//  SecondViewController.swift
//  TransitionTest
//
//  Created by A O Lionaird on 20/07/2018.
//  Copyright © 2018 A O Lionaird. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }

}

extension SecondViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
    }
}

extension SecondViewController: ExpandPresentAnimationControllerViewProvider {
    func selectedItemCell() -> MyCollectionViewCell {
        let indexPath = collectionView.centerCellIndexPath ?? IndexPath(item: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        return cell
    }
}
