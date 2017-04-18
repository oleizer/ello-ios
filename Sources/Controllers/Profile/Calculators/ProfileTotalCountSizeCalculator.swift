////
///  ProfileTotalCountSizeCalculator.swift
//

import FutureKit


struct ProfileTotalCountSizeCalculator {
    let promise = Promise<CGFloat>()

    func calculate(_ item: StreamCellItem) -> Future<CGFloat> {
        guard
            let user = item.jsonable as? User,
            let count = user.totalViewsCount,
            count > 0
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileTotalCountView.Size.height)
        return promise.future
    }
}

private extension ProfileTotalCountSizeCalculator {}
