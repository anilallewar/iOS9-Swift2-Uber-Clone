//
//  ExtensionUIViewController.swift
//  Uber
//
//  Created by Anil Allewar on 1/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension UIViewController {
    // Say if are presenting an alert, then this extension allows you to render it on top of the visible view controller in the hierarcy
    // Code courtesy https://gist.github.com/MartinMoizard/6537467
    func presentViewControllerFromVisibleViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if self is UINavigationController {
            let navigationController = self as! UINavigationController
            navigationController.topViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: nil)
        } else if (presentedViewController != nil) {
            presentedViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: nil)
        } else {
            presentViewController(viewControllerToPresent, animated: true, completion: nil)
        }
    }
}