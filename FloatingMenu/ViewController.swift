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
    
    private static let buttonSize: CGSize = CGSize(width: 100.0, height: 30.0)
    private let buttonOrigin: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width
                                                - FloatingMenu.buttonSize.width
                                                - FloatingMenu.trailingMargin,
                                                y: UIScreen.main.bounds.size.height
                                                - FloatingMenu.buttonSize.height
                                                - FloatingMenu.bottomMargin)
    private static let leadingMargin = 20.0
    private static let trailingMargin = 20.0
    private static let topMargin = 30.0
    private static let bottomMargin = 20.0
    private var scaleX: CGFloat {
        let expandMenuWidth = UIScreen.main.bounds.width - FloatingMenu.leadingMargin - FloatingMenu.trailingMargin
        return expandMenuWidth/FloatingMenu.buttonSize.width
    }
    private var scaleY: CGFloat {
        let expandMenuHeight = UIScreen.main.bounds.height - FloatingMenu.topMargin - FloatingMenu.bottomMargin
        return expandMenuHeight/FloatingMenu.buttonSize.height
    }
    lazy var menuWindow: UIWindow = {
        guard let keyWindowScene = UIApplication.shared.keyWindowScene else {
            fatalError("Recheck keywindowscene")
        }
        let window = UIWindow(windowScene: keyWindowScene)
        window.frame = CGRect(origin: buttonOrigin,
                              size: FloatingMenu.buttonSize)
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
            let offset = UIOffset(horizontal: -FloatingMenu.buttonSize.width,
                                  vertical: -FloatingMenu.buttonSize.height)
            let scaleTransform = CGAffineTransform(scaleX: self.scaleX, y: self.scaleY)
            let translateTransform = CGAffineTransform(translationX: offset.horizontal,
                                                       y: offset.vertical)
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

