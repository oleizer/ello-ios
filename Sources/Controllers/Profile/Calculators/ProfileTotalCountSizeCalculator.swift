////
///  ProfileTotalCountSizeCalculator.swift
//

import FutureKit


struct ProfileTotalCountSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
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
