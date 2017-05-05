////
///  ProfileBadgesPresenter.swift
//

struct ProfileBadgesPresenter {

    static func configure(
        _ view: ProfileBadgesView,
        user: User,
        currentUser: User?)
    {
        view.badges = user.badges
    }
}
