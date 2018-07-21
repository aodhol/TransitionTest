//
//  ViewController.swift
//  TransitionTest
//
//  Created by A O Lionaird on 20/07/2018.
//  Copyright © 2018 A O Lionaird. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Gestures

    @objc
    @IBAction func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {

        let translation = gestureRecognizer.translation(in: collectionView)
        let height = gestureRecognizer.view?.frame.height ?? 0.0

        var progress = translation.y / height
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

        guard let animationController = (navigationController?.delegate as? ExpandPresentAnimationController) else { return }

        switch gestureRecognizer.state {

        case .began:

            animationController.interactionController = UIPercentDrivenInteractiveTransition()

            self.performSegue(withIdentifier: "show_details", sender: self)

        case .changed:
            
            let d = translation.y / gestureRecognizer.view!.bounds.height * -1
            animationController.interactionController?.update(d)

        case .cancelled, .ended:

            let vel = panGestureRecognizer.velocity(in: view)

            if vel.y < 0 {
                animationController.interactionController?.finish()
            } else {
                animationController.interactionController?.cancel()
            }
            animationController.interactionController = nil

        default:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FirstViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
    }
}

// MARK: - ExpandPresentAnimationControllerViewProvider

extension FirstViewController: ExpandPresentAnimationControllerViewProvider {
    func selectedItemCell() -> MyCollectionViewCell {
        let indexPath = collectionView.centerCellIndexPath ?? IndexPath(item: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        return cell
    }
}

// MARK: - Conveniences

extension UICollectionView {
    var centerPoint : CGPoint {
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    var centerCellIndexPath: IndexPath? {
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}
