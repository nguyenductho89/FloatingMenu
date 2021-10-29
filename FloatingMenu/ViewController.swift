//
//  ViewController.swift
//  FloatingMenu
//
//  Created by Nguyễn Đức Thọ on 30/10/2021.
//

import UIKit

class MenuViewController: UIViewController {
    var didShow: ((Bool)->())?
    var isExpand = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        let button = UIButton.init(frame: self.view.frame)
        button.backgroundColor = .green
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(showMenu), for: .allEvents)
    }
    
    @objc func showMenu() {
        isExpand.toggle()
        didShow?(isExpand)
    }
}

class ViewController: UIViewController {
    var coveringWindow: UIWindow?
        
        func coverEverything() {
            coveringWindow = UIWindow.init(windowScene: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.windowScene!)
            
            if let coveringWindow = coveringWindow {
                coveringWindow.windowLevel = UIWindow.Level.alert + 1
                coveringWindow.isHidden = false
            }
        }
    lazy var menuWindow: UIWindow = {
        let window = UIWindow(windowScene: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.windowScene!)
        window.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width - 120, y: self.view.frame.size.height - 50),
                              size: CGSize(width: 100, height: 30))
        let menuVC = MenuViewController()
        menuVC.didShow = {[weak self] isExpand in
            guard let self = self else {return}
            guard isExpand else {
                UIView.animate(withDuration: 0.5, animations: {
                            window.transform = CGAffineTransform.identity
                        }, completion: { (finished) in
                        })
                return
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                let offset = UIOffset(horizontal: -50, vertical: -15)
                let scaleTransform = CGAffineTransform(scaleX: 2, y: 2)
                let translateTransform = CGAffineTransform(translationX: offset.horizontal, y: offset.vertical)
                window.transform = scaleTransform.concatenating(translateTransform)
            } completion: { _ in
                
                
            }

            
        }
        window.rootViewController = menuVC
        window.windowLevel = UIWindow.Level.alert
        window.isHidden = false
        return window
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        menuWindow.makeKeyAndVisible()
    }

    

}

