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
    }
    
    private func setupTabBar() {
        let scheduleVC = setupNavigationController(vc: ScheduleViewController(), itemName: "Schedule", image: "calendar.badge.clock")
        let allTasks = setupNavigationController(vc: AllTasksToDoViewController(), itemName: "All tasks", image: "list.clipboard.fill")
        let contactsVC = setupNavigationController(vc: ContactsViewController(), itemName: "Contacts", image: "rectangle.stack.person.crop")
        let userVC = setupNavigationController(vc: UserProfileViewController(), itemName: "User Profile", image: "person.fill")
        
        viewControllers = [scheduleVC, allTasks, contactsVC, userVC]
    }
    
    //настройка таб бара
    private func setupNavigationController(vc: UIViewController,itemName: String,image: String) -> UINavigationController{
        let imageConfig = UIImage(systemName: image)?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0))
        let item = UITabBarItem(title: itemName, image: imageConfig , tag: 0)
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 10)//указание расположение тайтла
        
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
        
    }


}
