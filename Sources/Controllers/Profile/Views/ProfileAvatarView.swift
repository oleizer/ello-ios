////
///  ProfileAvatarView.swift
//

class ProfileAvatarView: ProfileBaseView {

    struct Size {
        static let avatarSize: CGFloat = 180
        static let whiteBarHeight: CGFloat = 60
    }

    var avatarImage: UIImage? {
        get { return avatarImageView.image }
        set { avatarImageView.image = newValue }
    }

    var avatarURL: URL? {
        get { return _avatarURL }
        set {
            _avatarURL = newValue
            avatarImageView.pin_setImage(from: _avatarURL) { _ in
                // we may need to notify the cell of this
                // previously we hid the loader here
            }
        }
    }

    fileprivate let avatarImageView = FLAnimatedImageView()
    fileprivate let whiteBar = UIView()
    fileprivate var _avatarURL: URL?

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileAvatarView {

    override func style() {
        backgroundColor = .clear
        avatarImageView.backgroundColor = .greyF2()
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        whiteBar.backgroundColor = .white
    }

    override func setText() {}

    override func arrange() {
        super.arrange()

        addSubview(whiteBar)
        addSubview(avatarImageView)

        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Size.avatarSize)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }

        whiteBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.whiteBarHeight)
            make.bottom.equalTo(self.snp.bottom)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = Size.avatarSize / 2

        let desiredHeight = ProfileAvatarSizeCalculator.calculateHeight(maxWidth: frame.width)
        if desiredHeight != frame.height {
            onHeightMismatch?(desiredHeight)
        }
    }

    func prepareForReuse() {
        avatarImageView.pin_cancelImageDownload()
        avatarImageView.image = nil
        _avatarURL = nil
    }
}

extension ProfileAvatarView: ProfileViewProtocol {}
