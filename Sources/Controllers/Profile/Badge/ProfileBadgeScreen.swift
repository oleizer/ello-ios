////
///  ProfileBadgeScreen.swift
//

import SnapKit


class ProfileBadgeScreen: Screen, ProfileBadgeScreenProtocol {
    struct Size {
        static let learnMoreSpacing: CGFloat = 20
    }

    weak var delegate: ProfileBadgeScreenDelegate?
    let title: String
    let link: String

    fileprivate let titleLabel = StyledLabel(style: .largeWhite)
    fileprivate let learnMoreButton = StyledButton(style: .grayUnderlined)

    init(title: String, link: String) {
        self.title = title
        self.link = link
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("use init(title:)")
    }

    override func style() {
        backgroundColor = .clear
    }

    override func bindActions() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(gesture)
    }

    override func setText() {
        titleLabel.text = title
        learnMoreButton.setTitle(link, for: .normal)
    }

    override func arrange() {
        super.arrange()

        addSubview(titleLabel)
        addSubview(learnMoreButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self)
        }

        learnMoreButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.learnMoreSpacing)
        }
    }

    func dismiss() {
        delegate?.dismiss()
    }
}
