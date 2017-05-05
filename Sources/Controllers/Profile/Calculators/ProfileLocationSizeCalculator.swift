////
///  ProfileLocationSizeCalculator.swift
//

import FutureKit


struct ProfileLocationSizeCalculator {

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
        guard
            let user = item.jsonable as? User,
            let location = user.location, !location.isEmpty
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileLocationView.Size.height)
        return promise.future
    }
}
