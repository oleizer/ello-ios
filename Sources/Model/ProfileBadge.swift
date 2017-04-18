////
///  ProfileBadge.swift
//

enum ProfileBadge: String {
    case featured
    case community
    case experimental
    case staff
    case spam
    case nsfw

    var image: InterfaceImage {
        switch self {
        case .featured:
            return .badgeFeatured
        case .community:
            return .badgeCommunity
        case .experimental:
            return .badgeExperimental
        case .staff:
            return .badgeStaff
        case .spam:
            return .badgeSpam
        case .nsfw:
            return .badgeNsfw
        }
    }
}
