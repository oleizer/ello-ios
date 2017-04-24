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

    var name: String {
        switch profileBadge {
        case .featured:
            if let categories = categories {
                return ElloAttributedString.featuredIn(categories: categories).string
            }
            else {
                return profileBadge.name
            }
        default:
            return profileBadge.name
        }
    }

    var image: InterfaceImage {
        return profileBadge.image
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func encode(with encoder: NSCoder) {
        super.encode(with: encoder)
    }
}
