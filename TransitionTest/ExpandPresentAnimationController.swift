//
//  ExpandPresentAnimationController.swift
//  FiveforFriday
//
//  Created by Aodh O Lionaird on 24/06/2018.
//  Copyright © 2018 5fF. All rights reserved.
//

import UIKit

protocol ExpandPresentAnimationControllerViewProvider {
    func selectedItemCell() -> MyCollectionViewCell
}

let duration = 0.5

class ExpandPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var initialVelocity: CGFloat = 0.0
    
    fileprivate var propertyAnimator: UIViewPropertyAnimator? {
        didSet {
            if #available(iOS 11.0, *) {
                propertyAnimator?.scrubsLinearly = false
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return propertyAnimator?.duration ?? duration
    }
    
    class func propertyAnimator(initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(mass: 4.5, stiffness: 1000, damping: 95, initialVelocity: initialVelocity)
        return UIViewPropertyAnimator(duration: duration, timingParameters:timingParameters)
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        // reset animator because the current transition ended
        self.propertyAnimator = nil
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {

        // as per documentation, we need to return existing animator
        // for ongoing transition
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }

        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? FirstViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? SecondViewController
            else {
                fatalError()
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)

        let toSelectedItemCell = toVC.selectedItemCell()
        
        let toSelectedItemCellSnapshot = toSelectedItemCell.snapshotView(afterScreenUpdates: true) ?? UIView()

        let fromSelectedItemCell = fromVC.selectedItemCell()

        // If the out of stock view is visible, add it to the snapshot else the label text will be scaled
        // upon animating.
        if let outOfStockView = toSelectedItemCell.outOfStockView, outOfStockView.isHidden == false {
            toSelectedItemCellSnapshot.addSubview(outOfStockView)
        }

        containerView.addSubview(toSelectedItemCellSnapshot)

        toSelectedItemCellSnapshot.frame = (fromSelectedItemCell.superview?.convert(fromSelectedItemCell.frame, to: containerView)) ?? .zero

        fromSelectedItemCell.isHidden = true

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 0.4)
        animator.addAnimations {
             toSelectedItemCellSnapshot.frame = toSelectedItemCell.frame
        }
        
        animator.addCompletion { position in
            fromSelectedItemCell.isHidden = false
            toSelectedItemCellSnapshot.removeFromSuperview()

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            // add the out of stock view back if necessary.
            if let outOfStockView = toSelectedItemCell.outOfStockView, outOfStockView.isHidden == false {
                toSelectedItemCell.addSubview(outOfStockView)
            }
        }

        self.propertyAnimator = animator
        return animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
}

// UINavigationControllerDelegate: - This is how the transition delegate is attached.

extension ExpandPresentAnimationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                                       interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

            if operation == .push {
                return self // important: since it's an extension on ExpandPresentAnimationController we can return self here instead of an instance.....unlike below.
            }

        return nil
    }
}

