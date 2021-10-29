//
//  ViewController.swift
//  FloatingMenu
//
//  Created by Nguyễn Đức Thọ on 30/10/2021.
//

import UIKit

class MenuViewController: UIViewController {
    var setExpand: ((Bool)->())?
    private var isExpand = false
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
        setExpand?(isExpand)
    }
}

extension UIApplication {
    var keyWindowScene: UIWindowScene? {
        if #available(iOS 15, *) {
            return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        } else {
            return UIApplication
                .shared
                .windows
                .filter {$0.isKeyWindow}
                .first?
                .windowScene
        }
    }
}

final class FloatingMenu {
    static let shared = FloatingMenu()
    func show() {
        menuWindow.makeKeyAndVisible()
    }
    
    private let buttonSize: CGSize = CGSize(width: 100.0, height: 30.0)
    private let buttonOrigin: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width - 120,
                                                y: UIScreen.main.bounds.size.height - 50)
    lazy var menuWindow: UIWindow = {
        guard let keyWindowScene = UIApplication.shared.keyWindowScene else {
            fatalError("Recheck keywindowscene")
        }
        let window = UIWindow(windowScene: keyWindowScene)
        window.frame = CGRect(origin: buttonOrigin,
                              size: buttonSize)
        let menuVC = MenuViewController()
        menuVC.setExpand = {[weak self] isExpand in
            guard let self = self else {return}
            isExpand ?
            self.expandAnimation() :
            self.collapseAnimation()
        }
        window.rootViewController = menuVC
        window.windowLevel = UIWindow.Level.alert
        window.isHidden = false
        return window
    }()
    
    private func expandAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {[weak self] in
            guard let self = self else {return}
            let offset = UIOffset(horizontal: -self.buttonSize.width/2.0,
                                  vertical: -self.buttonSize.height/2.0)
            let scaleTransform = CGAffineTransform(scaleX: 2, y: 2)
            let translateTransform = CGAffineTransform(translationX: offset.horizontal, y: offset.vertical)
            self.menuWindow.transform = scaleTransform.concatenating(translateTransform)
        }
    }
    
    private func collapseAnimation() {
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            guard let self = self else {return}
            self.menuWindow.transform = CGAffineTransform.identity
        })
    }
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

