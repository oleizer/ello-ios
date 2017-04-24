////
///  User.swift
//

import SwiftyJSON


// version 1: initial
let BadgeVersion: Int = 1

@objc
final class Badge: JSONAble {
    let profileBadge: ProfileBadge
    let categories: [Category]?

    init(profileBadge: ProfileBadge, categories: [Category]?) {
        self.profileBadge = profileBadge
        self.categories = categories
        super.init(version: BadgeVersion)
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func encode(with encoder: NSCoder) {
        super.encode(with: encoder)
    }
}
