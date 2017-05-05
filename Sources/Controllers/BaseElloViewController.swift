////
///  BaseElloViewController.swift
//

@objc
protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

class BaseElloViewController: UIViewController, HasAppController, ControllerThatMightHaveTheCurrentUser {
    var statusBarShouldHide = false
    fileprivate var statusBarShouldHideObserver: NotificationObserver?

    func hideStatusBar(_ hide: Bool) {
        statusBarShouldHide = hide
        animate {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldHide
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }


    var elloNavigationItem = UINavigationItem()

    override var title: String? {
        didSet {
            elloNavigationItem.title = title ?? ""
        }
    }

    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var appViewController: AppViewController? {
        return findViewController { vc in vc is AppViewController } as? AppViewController
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as? ElloTabBarController
    }

    var bottomBarController: BottomBarController? {
        return findViewController { vc in vc is BottomBarController } as? BottomBarController
    }

    // This is an odd one, `super.next` is not accessible in a closure that
    // captures self so we stuff it in a computed variable
    var superNext: UIResponder? {
        return super.next
    }

    var relationshipController: RelationshipController?

    override var next: UIResponder? {
        return relationshipController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.fixNavBarItemPadding()
        setupRelationshipController()
        setupStatusBarObservers()
    }

    fileprivate func setupStatusBarObservers() {
        statusBarShouldHideObserver = NotificationObserver(notification: StatusBarNotifications.statusBarShouldHide) { [weak self] (hide) in
            self?.hideStatusBar(hide)
        }
    }

    deinit {
        statusBarShouldHideObserver?.removeObserver()
    }

    private func setupRelationshipController() {
        let chainableController = ResponderChainableController(
            controller: self,
            next: { [weak self] in
                return self?.superNext
            }
        )

        let relationshipController = RelationshipController()
        relationshipController.responderChainable = chainableController
        relationshipController.currentUser = self.currentUser
        self.relationshipController = relationshipController
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenAppeared()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func trackScreenAppeared() {
        super.trackScreenAppeared()

        if currentUser == nil {
            Tracker.shared.loggedOutScreenAppeared(self)
        }
    }

    func didSetCurrentUser() {
        relationshipController?.currentUser = currentUser
    }

    @IBAction
    func backTapped() {
        guard
            let navigationController = navigationController, navigationController.childViewControllers.count > 1
        else { return }

        _ = navigationController.popViewController(animated: true)
    }

    @IBAction
    func closeTapped() {
        dismiss(animated: true, completion: .none)
    }

    func showShareActivity(sender: UIView, url shareURL: URL) {
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = sender
            present(activityVC, animated: true) { }
        }
    }

    func isRootViewController() -> Bool {
        return navigationController?.viewControllers.first == self
    }
}

// MARK: Search
extension BaseElloViewController {
    func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }
}
