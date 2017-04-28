////
///  ProfileBadge.swift
//

enum ProfileBadge {
    struct Info {
        let slug: String
        let name: String
        let learnMoreCaption: String
        let learnMoreUrl: URL
        let imageURL: URL
    }

    case featured
    case community
    case experimental
    case staff
    case spam
    case nsfw
    case other(Info)

    var slug: String {
        switch self {
        case .featured: return "featured"
        case .community: return "community"
        case .experimental: return "experimental"
        case .staff: return "staff"
        case .spam: return "spam"
        case .nsfw: return "nsfw"
        case let .other(info):
            return info.slug
        }
    }

    var name: String {
        switch self {
        case .featured:
            return InterfaceString.Badges.Featured
        case .community:
            return InterfaceString.Badges.Community
        case .experimental:
            return InterfaceString.Badges.Experimental
        case .staff:
            return InterfaceString.Badges.Staff
        case .spam:
            return InterfaceString.Badges.Spam
        case .nsfw:
            return InterfaceString.Badges.Nsfw
        case let .other(info):
            return info.name
        }
    }

    var link: String {
        switch self {
        case .staff:
            return InterfaceString.Badges.StaffLink
        case let .other(info):
            return info.learnMoreCaption
        default:
            return InterfaceString.Badges.LearnMore
        }
    }

    var url: URL? {
        switch self {
        case .spam, .nsfw:
            return nil
        case let .other(info):
            return info.learnMoreUrl
        default:
            return URL(string: "https://ello.co/wtf/help/badges/")
        }
    }

    var image: InterfaceImage? {
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
        case .other:
            return nil
        }
    }

    var imageURL: URL? {
        switch self {
        case let .other(info):
            return info.imageURL
        default:
            return nil
        }
    }
}
