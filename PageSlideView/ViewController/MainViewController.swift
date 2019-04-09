//
//  ViewController.swift
//  SideMenu
//
//  Created by 승윤 on 06/04/2019.
//  Copyright © 2019 김승윤. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, showMainContainerViewDelegate {
    
    @IBOutlet var sideMenuContainerView: UIView!
    @IBOutlet var sideMenuFrameStackView: UIStackView!
    @IBOutlet var mainContainerView: UIView!
    
    var isSideOn: Bool = true
    var originStackViewCGPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    var vcArray: Array<UIViewController> = []

//    var pageVC: UIPageViewController?
    
    fileprivate let SHOW_SIDE_MENU = "show_side_menu"
    fileprivate let SHOW_PAGE_VIEW = "show_page_view"
    
    
    var pageVC: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let firstVC = sb.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController,
            let secondVC = sb.instantiateViewController(withIdentifier: "SecondVC") as? SecondViewController,
        let thirdVC = sb.instantiateViewController(withIdentifier: "ThirdVC") as? ThirdViewController {
            vcArray.append(firstVC)
            vcArray.append(secondVC)
            vcArray.append(thirdVC)
        }
        //container Add first viewcontroller
//        containerViewRemoveAll()
//        containerViewAdd(vcArray[0])
        
        originStackViewCGPoint = sideMenuFrameStackView.center
        
        
        self.pageVC?.setViewControllers([vcArray[0]], direction: .forward, animated: true, completion: nil)
        
    }//viewDidLoad
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case SHOW_SIDE_MENU:
            if let sideMenuVC = segue.destination as? SideMenuViewController {
                sideMenuVC.showMainListDelegate = self
            }
        case SHOW_PAGE_VIEW:
            guard let vc = segue.destination as? UIPageViewController
                else {
                    //todo fail message
                    return
            }
            self.pageVC = vc
            self.pageVC?.dataSource = self
        default:
            break
        }
    }//prepare
    
    @IBAction func showSideMenuBtn(_ sender: UIButton) {
        if sideMenuFrameStackView.isHidden {
            sideMenuFrameStackView.isHidden = false
            sideMenuAnimate(v: sideMenuContainerView, isHidden: false)
            
            isSideOn = false
        } else {
            sideMenuAnimate(v: sideMenuContainerView, isHidden: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.sideMenuFrameStackView.isHidden = true
            }
            isSideOn = true
        }
        originStackViewCGPoint = sideMenuFrameStackView.center
    }//showSideMenuBtn
    
    @IBAction func edgeGesture(_ sender: UIScreenEdgePanGestureRecognizer) {

        if isSideOn {
            self.sideMenuFrameStackView.isHidden = false
            sideMenuAnimate(v: sideMenuContainerView, isHidden: false)
            
            isSideOn = false
        }
    }//edgeGesture
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        
        if !isSideOn {
            sideMenuAnimate(v: sideMenuContainerView, isHidden: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.sideMenuFrameStackView.isHidden = true
            }
            isSideOn = true
        }
    }//tapGesture
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: sideMenuFrameStackView)
        let translation = sender.translation(in: sideMenuFrameStackView)
        let changeX = sideMenuFrameStackView.center.x + translation.x
        
        sender.cancelsTouchesInView = false
        
        if abs(velocity.x) > abs(velocity.y) {
            
            if velocity.x < 0 {
                //left swipe
                sideMenuFrameStackView.center = CGPoint(x:changeX, y: sideMenuFrameStackView.center.y)
            } else if velocity.x > 0 {
                //right swipe
                if sideMenuFrameStackView.center.x < view.center.x {
                    sideMenuFrameStackView.center = CGPoint(x:changeX, y: sideMenuFrameStackView.center.y)
                } else {
                    sideMenuFrameStackView.center = CGPoint(x:view.center.x, y: sideMenuFrameStackView.center.y)
                }
            }
        }//left and right
        sender.setTranslation(CGPoint.zero, in: sideMenuFrameStackView)
        if sender.state == .ended {
            
            if sideMenuFrameStackView.center.x < 0 {
                sideMenuAnimate(v: sideMenuContainerView, isHidden: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.sideMenuFrameStackView.isHidden = true
                }
                isSideOn = true
            }
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: .transitionFlipFromLeft,
                animations: {
                    self.sideMenuFrameStackView.center = self.originStackViewCGPoint
                    self.view.layoutIfNeeded()
            }, completion: nil)
        }//sender.state == .ended
        
    }//panGesture
    
    
    @IBAction func pagingBtn(_ sender: UIButton) {
        
        guard let _pageVC = pageVC
            else {
                //todo fail message
                return
        }
    
        switch sender.tag {
        case 0:
            _pageVC.setViewControllers([vcArray[0]], direction: .reverse, animated: true, completion: nil)
        case 1:
            if _pageVC.viewControllers == [vcArray[0]] {
                _pageVC.setViewControllers([vcArray[1]], direction: .forward, animated: true, completion: nil)
            } else {
                _pageVC.setViewControllers([vcArray[1]], direction: .reverse, animated: true, completion: nil)
            }
        case 2:
            _pageVC.setViewControllers([vcArray[2]], direction: .forward, animated: true, completion: nil)
        default:
            break
        }
    }//pagingBtn
    
    func sideMenuAnimate(v: UIView, isHidden: Bool) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1,
            options: .transitionFlipFromLeft,
            animations: {
                self.sideMenuContainerView.isHidden = isHidden
                self.sideMenuFrameStackView.layoutIfNeeded()
        }, completion: nil)
    }//sideMenuAnimate
    
    func showContainerView(_ num: Int) {
//        containerViewRemoveAll()
//        containerViewAdd(vcArray[num])
        guard let _pageVC = pageVC
            else {
                //todo fail message
                return
        }
        
        switch num {
            case 0:
            _pageVC.setViewControllers([vcArray[0]], direction: .reverse, animated: true, completion: nil)
        case 1:
            if _pageVC.viewControllers == [vcArray[0]] {
                _pageVC.setViewControllers([vcArray[1]], direction: .forward, animated: true, completion: nil)
            } else {
                _pageVC.setViewControllers([vcArray[1]], direction: .reverse, animated: true, completion: nil)
            }
        case 2:
            _pageVC.setViewControllers([vcArray[2]], direction: .forward, animated: true, completion: nil)
        default:
            break
        }
        
        
        //hide sideMenu
        if !isSideOn {
            sideMenuAnimate(v: sideMenuContainerView, isHidden: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.sideMenuFrameStackView.isHidden = true
            }
            isSideOn = true
        }
    }//showContainerView
    
    private func containerViewAdd(_ vc: UIViewController) {
        
        addChild(vc)
        mainContainerView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor)
            ])
        vc.didMove(toParent: self)
    }//containerViewAdd
    
    private func containerViewRemoveAll() {
        for viewController in vcArray {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }//containerViewRemoveAll
    
}//class


extension MainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let curIndex = vcArray.firstIndex(of: viewController) else { return nil }
        
        let prePageIndex = curIndex - 1
        if prePageIndex < 0 {
            return nil
        } else {
            return vcArray[prePageIndex]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let curIndex = vcArray.firstIndex(of: viewController) else { return nil }
        
        let prePageIndex = curIndex + 1
        if prePageIndex >= vcArray.count {
            return nil
        } else {
            return vcArray[prePageIndex]
        }
        
    }
}


extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //하위 제스처 인식 안하게 하기
        return true
    }
    
}//

