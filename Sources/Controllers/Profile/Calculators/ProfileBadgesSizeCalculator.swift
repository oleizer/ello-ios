////
///  ProfileBadgesSizeCalculator.swift
//

import FutureKit


struct ProfileBadgesSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
        guard
            let user = item.jsonable as? User,
            user.badges.count > 0
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileBadgesView.Size.height)
        return promise.future
    }
}
