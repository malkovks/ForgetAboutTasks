//
//  TabBarViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
/*
 Controller which display tab bar and some settings of it
 */

import UIKit

///Tab bar custom class which display customised UITabBar 
class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTabBar()
        settingsTabBar()
        setTabBarAppearance()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        animateImageItem(item: item)
        setupHapticMotion(style: .heavy)
    }
    
    private func settingsTabBar(){
       tabBar.itemPositioning = .centered
        tabBar.itemSpacing = 10
        tabBar.items?.forEach({ item in
            item.imageInsets = UIEdgeInsets(top: -5, left: -5, bottom: 0, right: 5)
        })
    }
    
    private func setupTabBar() {
        let schedule = tabbarsetup(vc: ScheduleViewController(), title: "Schedule".localized(), image: "calendar.badge.clock")
        let tasks = tabbarsetup(vc: AllTasksToDoViewController(), title: "All Tasks".localized(), image: "list.clipboard.fill")
        let contact = tabbarsetup(vc: ContactsViewController(), title: "Contacts".localized(), image: "rectangle.stack.person.crop")
        let user = tabbarsetup(vc: UserProfileViewController(), title: "Profile".localized(), image: "gear")
        setViewControllers([schedule,tasks,contact,user], animated: isViewAnimated)
    }
    
    
    private func setTabBarAppearance(){
        let positionX: CGFloat = 10.0
        let positionY: CGFloat = 14.0
        let width = tabBar.bounds.width - positionX*2
        let height = tabBar.bounds.height + positionY*2
        
        let roundedLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: positionX, y: tabBar.bounds.minY-positionY, width: width, height: height), cornerRadius: height/2)
        roundedLayer.path = bezierPath.cgPath
        tabBar.layer.insertSublayer(roundedLayer, at: 0)
        tabBar.itemWidth = width / 5
        
        
        roundedLayer.fillColor = UIColor(named: "tabBarBackgroundColor")?.cgColor
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = UIColor(named: "calendarHeaderColor")
        tabBar.isTranslucent = true
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.unselectedItemTintColor = .black
        
        
    }
    
    
    private func animateImageItem(item: UITabBarItem) {
        guard let item = item.value(forKey: "view") as? UIView else { return }
        
        let timeInterval: TimeInterval = 0.5
        let animator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.5) {
            item.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }
        animator.addAnimations({
            item.transform = .identity
        }, delayFactor: CGFloat(timeInterval))
        animator.startAnimation()
    }
    
    //настройка таб бара
    private func setupNavigationController(vc: UIViewController,itemName: String,image: String) -> UINavigationController{
        let imageConfig = UIImage(systemName: image)?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0))
        let item = UITabBarItem(title: itemName, image: imageConfig , tag: 0)
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 10)//указание расположение тайтла
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        navController.hidesBottomBarWhenPushed = true
        return navController
    }
    
    private func tabbarsetup(vc: UIViewController,title: String, image: String) -> UINavigationController{
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: image)
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    private func setupNavWithoutNavBarEdgeAppearance(vc: UIViewController,itemName: String,image: String) -> UINavigationController {
        let imageConfig = UIImage(systemName: image)?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0))
        let item = UITabBarItem(title: itemName, image: imageConfig , tag: 0)
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 10)//указание расположение тайтла
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
    }
}
