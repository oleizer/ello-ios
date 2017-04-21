////
///  User.swift
//

import SwiftyJSON


// version 1: initial
let BadgeVersion: Int = 1

@objc
final class Badge: JSONAble {
    let badge: ProfileBadge

    init(badge: ProfileBadge) {
        self.badge = badge
        super.init(version: BadgeVersion)
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        self.badge = .featured
        super.init(coder: aDecoder)
    }

    override func encode(with encoder: NSCoder) {
        super.encode(with: encoder)
    }
}
