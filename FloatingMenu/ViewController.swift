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

final class FloatingMenu {
    static let shared = FloatingMenu()
    func show() {
        menuWindow.makeKeyAndVisible()
    }
    lazy var menuWindow: UIWindow = {
        let window = UIWindow(windowScene: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.windowScene!)
        window.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.size.width - 120, y: UIScreen.main.bounds.size.height - 50),
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
}

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FloatingMenu.shared.show()
    }

    

}

