//
//  TabBarViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
/*
 Controller which display tab bar and some settings of it
 */

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        settingsTabBar()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        animateImageItem(item: item)
    }
    
    private func settingsTabBar(){
        self.tabBar.layer.masksToBounds = true
        self.tabBar.isTranslucent = true
        self.tabBar.layer.cornerRadius = 30
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
//        self.tabBar.backgroundColor = UIColor(named: "calendarHeaderColor")
        self.tabBar.selectedImageTintColor = UIColor(named: "calendarHeaderColor")
        self.tabBar.unselectedItemTintColor = .red
    }
    
    private func setupTabBar() {
        let scheduleVC = setupNavigationController(vc: ScheduleViewController(), itemName: "Schedule", image: "calendar.badge.clock")
        let allTasks = setupNavigationController(vc: AllTasksToDoViewController(), itemName: "All Tasks", image: "list.clipboard.fill")
        let contactsVC = setupNavigationController(vc: ContactsViewController(), itemName: "Contacts", image: "rectangle.stack.person.crop")
        let userVC = setupNavWithoutNavBarEdgeAppearance(vc: UserProfileViewController(), itemName: "Settings", image: "gear")
     
        setViewControllers([scheduleVC,allTasks,contactsVC,userVC], animated: true)
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
        navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
        return navController
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
