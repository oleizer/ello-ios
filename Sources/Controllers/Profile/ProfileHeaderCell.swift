////
///  ProfileHeaderCell.swift
//

@objc
protocol EditProfileResponder {
    func onEditProfile()
}

@objc
protocol PostsTappedResponder {
    func onPostsTapped()
}

@objc
protocol ProfileHeaderResponder {
    func onCategoryBadgeTapped()
    func onBadgeTapped(_ badge: String)
    func onMoreBadgesTapped()
    func onLovesTapped()
    func onFollowersTapped()
    func onFollowingTapped()
}

class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    let headerView = ProfileHeaderCompactView()
    var calculatedCellHeights: CalculatedCellHeights? {
        didSet {
            headerView.calculatedCellHeights = calculatedCellHeights
        }
    }

    var avatarView: ProfileAvatarView { return headerView.avatarView }
    var namesView: ProfileNamesView { return headerView.namesView }
    var totalCountView: ProfileTotalCountView { return headerView.totalCountView }
    var badgesView: ProfileBadgesView { return headerView.badgesView }
    var statsView: ProfileStatsView { return headerView.statsView }
    var bioView: ProfileBioView { return headerView.bioView }
    var locationView: ProfileLocationView { return headerView.locationView }
    var linksView: ProfileLinksView { return headerView.linksView }

    var user: User?
    var currentUser: User?

    var onHeightMismatch: OnCalculatedCellHeightsMismatch?

    // this little hack prevents constraints from breaking on initial load
    override var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    fileprivate func bindActions() {
        avatarView.onHeightMismatch = { avatarHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileAvatar = avatarHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        totalCountView.onHeightMismatch = { totalCountHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileTotalCount = totalCountHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        bioView.onHeightMismatch = { bioHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileBio = bioHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        linksView.onHeightMismatch = { linkHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileLinks = linkHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        locationView.onHeightMismatch = { linkHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileLocation = linkHeight
            self.recalculateHeight(calculatedCellHeights)
        }
    }

    fileprivate func arrange() {
        contentView.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    override func prepareForReuse() {
        onHeightMismatch = nil

        avatarView.prepareForReuse()
        statsView.prepareForReuse()
        totalCountView.prepareForReuse()
        namesView.prepareForReuse()
        bioView.prepareForReuse()
        locationView.prepareForReuse()
        linksView.prepareForReuse()
    }

    fileprivate func recalculateHeight(_ _calculatedCellHeights: CalculatedCellHeights) {
        var calculatedCellHeights = _calculatedCellHeights
        calculatedCellHeights.oneColumn = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(calculatedCellHeights)
        self.calculatedCellHeights = calculatedCellHeights
        onHeightMismatch?(calculatedCellHeights)
    }
}
