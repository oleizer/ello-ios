////
///  BadgesViewController.swift
//

class BadgesViewController: StreamableViewController, BadgesScreenDelegate {
    let user: User

    var _mockScreen: BadgesScreenProtocol?
    var screen: BadgesScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! BadgesScreen }
    }

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.Profile.Badges
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = BadgesScreen()
        screen.navigationItem = elloNavigationItem
        screen.delegate = self
        self.view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.streamKind = .unknown
        streamViewController.initialLoadClosure = {}
        streamViewController.reloadClosure = {}
        streamViewController.toggleClosure = { _ in }
        streamViewController.pullToRefreshEnabled = false
        streamViewController.pagingEnabled = false

        let items: [StreamCellItem] = user.badges.map { badge in
            let badgeJSONAble = Badge(profileBadge: badge, categories: user.categories)
            let item = StreamCellItem(jsonable: badgeJSONAble, type: .badge)
            return item
        }
        streamViewController.appendStreamCellItems(items)

        setupNavigationItems()
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

}

extension BadgesViewController {

    fileprivate func setupNavigationItems() {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()
    }

}
