////
///  ProfileBadgeViewController.swift
//

final class ProfileBadgeViewController: BaseElloViewController {

    var presentingVC: UIViewController?
    let badge: ProfileBadge

    init(badge: ProfileBadge) {
        self.badge = badge
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _mockScreen: ProfileBadgeScreenProtocol?
    var screen: ProfileBadgeScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? (self.view as! ProfileBadgeScreen) }
    }

    override func loadView() {
        let screen = ProfileBadgeScreen(title: badge.name, link: badge.link)
        screen.delegate = self
        self.view = screen
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension ProfileBadgeViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented == self
            else { return .none }

        return DarkModalPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundColor: .modalBackground())
    }
}

extension ProfileBadgeViewController: ProfileBadgeScreenDelegate {

    func learnMoreTapped() {
        Tracker.shared.badgeOpened(badge.rawValue)
        // let presentingVC = self.presentingVC
        self.dismiss(animated: true) {
            // presentingVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func dismiss() {
        self.dismiss(animated: true, completion: .none)
    }
}
