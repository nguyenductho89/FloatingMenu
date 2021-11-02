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
    static let leadingMargin = 50.0
    static let trailingMargin = 20.0
    static let topMargin = 100.0
    static let bottomMargin = 50.0
    private var scaleX: CGFloat {
        let expandMenuWidth = UIScreen.main.bounds.width - FloatingMenu.leadingMargin - FloatingMenu.trailingMargin
        return expandMenuWidth/FloatingMenu.buttonSize.width
    }
    private var scaleY: CGFloat {
        let expandMenuHeight = UIScreen.main.bounds.height - FloatingMenu.topMargin - FloatingMenu.bottomMargin
        return expandMenuHeight/FloatingMenu.buttonSize.height
    }
    lazy var menuWindow: FloatingUIWindow = {
        guard let keyWindowScene = UIApplication.shared.keyWindowScene else {
            fatalError("Recheck keywindowscene")
        }
        let window = FloatingUIWindow(windowScene: keyWindowScene)
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
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseInOut) {[weak self] in
            guard let self = self else {return}
            let offset = UIOffset(horizontal: -FloatingMenu.buttonSize.width*(self.scaleX-1)/2.0,
                                  vertical: -FloatingMenu.buttonSize.height*(self.scaleY-1)/2.0)
            let scaleTransform = CGAffineTransform(scaleX: self.scaleX, y: self.scaleY)
            let translateTransform = CGAffineTransform(translationX: offset.horizontal,
                                                       y: offset.vertical)
            self.menuWindow.transform = scaleTransform
                .concatenating(translateTransform)
        } completion: { _ in
            print(self.menuWindow.frame)
        }
    }
    
    private func collapseAnimation() {
        UIView.animate(withDuration: 1, animations: {[weak self] in
            guard let self = self else {return}
            self.menuWindow.transform = CGAffineTransform.identity
        }) { _ in
            print(self.menuWindow.frame)
        }
    }
}

/// Floating Window
//class ViewController: UIViewController {
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        FloatingMenu.shared.show()
//    }
//}

class ViewController: UIViewController {

    let floatView: FloatingView = {
        let view = FloatingView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(floatView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
}



class FloatingUIWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

//        for subview in subviews.reversed() {
//
//            let convertedPoint = subview.convert(point, from: self)
//
//            if let candidate = subview.hitTest(convertedPoint, with: event) {
//
//                return candidate
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//            self.resignKey()
//            self.isHidden = true
//        })
//        return self
        
        let hitView = super.hitTest(point, with: event)
        guard hitView == nil else {
            return hitView
        }
//                DispatchQueue.main.async {[weak self] in
//                    guard let self = self else {return}
//                    self.resignKey()
//                    self.isHidden = true
//                }
        return nil
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

final class FloatingHomeButton: UIButton {

    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: FloatingView.Constant.collapseFrame.size))
        self.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        self.setTitle("Menu", for: .normal)
        self.backgroundColor = .systemBlue
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: FloatingView.Constant.defaultRoundCorner.corners,
                     radius: FloatingView.Constant.defaultRoundCorner.radius)
    }
}

final class FloatingView: UIView {
    
    struct Constant {
        static let animationDuration: CGFloat = 0.4
        static let widthCollapseView: CGFloat = 100.0
        static let heightCollapseView: CGFloat = 30.0
        static var leadingMargin = 100.0
        static let trailingMargin = 20.0
        static let topMargin = 200.0
        static let bottomMargin = 100.0
        
        private static let sizeCollapseView: CGSize = CGSize(width: Constant.widthCollapseView, height: Constant.heightCollapseView)
        private static let originCollapseView: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width
                                                    - Constant.widthCollapseView
                                                    - Constant.trailingMargin,
                                                    y: UIScreen.main.bounds.size.height
                                                    - Constant.heightCollapseView
                                                    - Constant.bottomMargin)
        static let defaultRoundCorner: (corners: UIRectCorner, radius: CGFloat) = (corners: [.topLeft, .bottomLeft],
                                         radius: FloatingView.Constant.heightCollapseView/2.0)
        
        static var expandFrame: CGRect {
            let origin = CGPoint(x: FloatingView.Constant.leadingMargin, y: FloatingView.Constant.topMargin)
            let width = UIScreen.main.bounds.width - FloatingView.Constant.leadingMargin - FloatingView.Constant.trailingMargin
            let height = UIScreen.main.bounds.height - FloatingView.Constant.topMargin - FloatingView.Constant.bottomMargin
            return CGRect(origin: origin,
                               size: CGSize(width: width, height: height))
        }
        
        static var collapseFrame: CGRect {
            return CGRect(origin: originCollapseView, size: sizeCollapseView)
        }
    }
    
    private let collapseMenuView: FloatingHomeButton = {
        let button = FloatingHomeButton()
        return button
    }()
    
    private let expandMenuView: ExpandMenuView = {
        let menu = ExpandMenuView()
        menu.backgroundColor = .systemBlue
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.isHidden = true
        return menu
    }()
    
    var expandMenu: (()->())?
    var collapseMenu: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.addSubview(expandMenuView)
        self.addSubview(collapseMenuView)
        collapseMenuView.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        expandMenuView.didTapCloseButton = {[weak self] in
                self?.didCollapseMenu()
        }
        collapseMenuView.frame.origin = CGPoint(x: self.frame.size.width - Constant.widthCollapseView,
                                              y: self.frame.size.height - Constant.heightCollapseView)
        expandMenuView.frame.origin = CGPoint(x: self.frame.size.width - Constant.widthCollapseView,
                                              y: self.frame.size.height - Constant.heightCollapseView)
    }
    
    convenience init() {
        self.init(frame: Constant.expandFrame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapMenuButton() {
        didExpandMenu()
    }
    
    private func didExpandMenu() {
        expandMenu?()
        expandAnimation()
    }
    
    private func didCollapseMenu() {
        collapseMenu?()
        collapseAnimation()
    }
    
    private func collapseAnimation() {
        UIView.animate(withDuration: Constant.animationDuration, animations: {[weak self] in
            guard let self = self else {return}
            self.expandMenuView.transform = CGAffineTransform.identity
        }) {[weak self] _ in
            guard let self = self else {return}
            self.collapseMenuView.isHidden = false
            self.expandMenuView.isHidden = true
        }
    }

    private func expandAnimation() {
        self.collapseMenuView.isHidden = true
        self.expandMenuView.isHidden = false
        UIView.animate(withDuration: Constant.animationDuration, delay: 0, options: .curveEaseIn) {[weak self] in
            guard let self = self else {
                return
            }
            self.expandMenuView.transform = CGAffineTransform(translationX: Constant.expandFrame.origin.x - Constant.collapseFrame.origin.x,
                                                              y: Constant.expandFrame.origin.y - Constant.collapseFrame.origin.y)
        }
    }
    
    /// Pass through view:  Allow user touches views behind this view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        return false
    }
}

final class ExpandMenuView: UIView {
    
    private struct Constant {
        static let collectionLeadingMargin = 3.0
        static let collectionTopMargin = 30.0
        static let collectionTrailingMargin = 3.0
        static let collectionBottomMargin = 3.0
        static let defaultRoundCorner: (corners: UIRectCorner, radius: CGFloat) = (corners: [.bottomLeft],
                                         radius: FloatingView.Constant.heightCollapseView/2.0)
        static let closeButtonSize: CGSize = CGSize(width: 30.0, height: 30.0)
        static let tralingCloseButtonMargin: CGFloat = 10.0
        static let topCloseButtonMargin: CGFloat = 0.0
    }
    
    private lazy var collectionView: UIView = {
        let view =  UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton(type: .close)
        return button
    }()
    
    var didTapCloseButton: (()->())?
    
    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: FloatingView.Constant.expandFrame.size))
        self.roundCorners(corners: FloatingView.Constant.defaultRoundCorner.corners,
                          radius: FloatingView.Constant.defaultRoundCorner.radius)
        self.addSubview(collectionView)
        self.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        closeButton.frame = CGRect(origin: CGPoint(x: self.frame.width - Constant.closeButtonSize.width - Constant.tralingCloseButtonMargin,
                                                   y: Constant.topCloseButtonMargin),
                                   size: Constant.closeButtonSize)
        collectionView.frame = CGRect(origin: CGPoint(x: Constant.collectionLeadingMargin,
                                                      y: Constant.collectionTopMargin),
                                      size: CGSize(width: self.frame.width - Constant.collectionLeadingMargin - Constant.collectionTrailingMargin,
                                                   height: self.frame.height - Constant.collectionTopMargin - Constant.collectionBottomMargin))
        collectionView.roundCorners(corners: Constant.defaultRoundCorner.corners,
                                    radius: Constant.defaultRoundCorner.radius)
    }
    
    @objc private func didTapClose() {
        didTapCloseButton?()
    }
}
