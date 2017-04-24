////
///  ProfileHeaderCompactView.swift
//

import SnapKit


class ProfileHeaderCompactView: ProfileHeaderLayoutView {
    fileprivate var totalCountFullConstraint: Constraint!
    fileprivate var totalCountHalfConstraint: Constraint!
    fileprivate let totalCountVerticalGreyLine = UIView()
    fileprivate let totalCountHorizontalGreyLine = UIView()

    override var calculatedCellHeights: CalculatedCellHeights? {
        didSet {
            guard
                let badgesHeight = calculatedCellHeights?.profileBadges
            else { return }

            if badgesHeight == 0 {
                totalCountFullConstraint.activate()
                totalCountHalfConstraint.deactivate()
                totalCountVerticalGreyLine.isHidden = true
                badgesView.isHidden = true
            }
            else {
                totalCountFullConstraint.deactivate()
                totalCountHalfConstraint.activate()
                totalCountVerticalGreyLine.isHidden = false
                badgesView.isHidden = false
            }
        }
    }

    override func style() {
        backgroundColor = .clear
        totalCountVerticalGreyLine.backgroundColor = .greyE5()
        totalCountHorizontalGreyLine.backgroundColor = .greyE5()
    }

    override func bindActions() {}

    override func setText() {}

    override func arrange() {
        super.arrange()

        addSubview(avatarView)
        addSubview(namesView)
        addSubview(totalCountView)
        addSubview(badgesView)
        addSubview(totalCountVerticalGreyLine)
        addSubview(totalCountHorizontalGreyLine)
        addSubview(statsView)
        addSubview(bioView)
        addSubview(locationView)
        addSubview(linksView)

        avatarView.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(self)
            avatarHeightConstraint = make.height.equalTo(0).constraint
        }

        namesView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.bottom)
            make.width.centerX.equalTo(self)
            namesHeightConstraint = make.height.equalTo(0).constraint
        }

        totalCountView.snp.makeConstraints { make in
            make.top.equalTo(self.namesView.snp.bottom)
            make.leading.equalTo(totalCountHorizontalGreyLine)
            totalCountFullConstraint = make.trailing.equalTo(totalCountHorizontalGreyLine.snp.trailing).constraint
            totalCountHalfConstraint = make.trailing.equalTo(totalCountVerticalGreyLine.snp.leading).constraint
            totalCountHeightConstraint = make.height.equalTo(0).constraint
        }
        totalCountHalfConstraint.deactivate()

        totalCountVerticalGreyLine.snp.makeConstraints { make in
            make.top.bottom.equalTo(totalCountView)
            make.centerX.equalTo(self)
            make.width.equalTo(1)
        }

        totalCountHorizontalGreyLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(totalCountView)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
        }

        badgesView.snp.makeConstraints { make in
            make.top.bottom.equalTo(totalCountView)
            make.leading.equalTo(totalCountVerticalGreyLine.snp.trailing)
            make.trailing.equalTo(totalCountHorizontalGreyLine)
        }

        statsView.snp.makeConstraints { make in
            make.top.equalTo(self.totalCountView.snp.bottom)
            make.width.centerX.equalTo(self)
            make.height.equalTo(ProfileStatsView.Size.height)
        }

        bioView.snp.makeConstraints { make in
            make.top.equalTo(self.statsView.snp.bottom)
            make.width.centerX.equalTo(self)
            bioHeightConstraint = make.height.equalTo(0).constraint
        }

        locationView.snp.makeConstraints { make in
            make.top.equalTo(self.bioView.snp.bottom)
            make.width.centerX.equalTo(self)
            locationHeightConstraint = make.height.equalTo(0).constraint
        }

        linksView.snp.makeConstraints { make in
            make.top.equalTo(self.locationView.snp.bottom)
            make.width.centerX.equalTo(self)
            linksHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
