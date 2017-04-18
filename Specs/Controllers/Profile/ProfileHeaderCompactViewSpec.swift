////
///  ProfileHeaderCompactViewSpec
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderCompactViewSpec: QuickSpec {

    override func spec() {
        describe("ProfileHeaderCompactView") {
            let width: CGFloat = 375
            let avatarHeight: CGFloat = ProfileAvatarSizeCalculator.calculateHeight(maxWidth: width)
            let statsHeight: CGFloat = ProfileStatsView.Size.height
            let namesHeight: CGFloat = 75

            let defaultBioHeight: CGFloat = 50
            let defaultLocationHeight: CGFloat = ProfileLocationView.Size.height
            let defaultLinksHeight: CGFloat = 100
            let defaultCountHeight: CGFloat = ProfileTotalCountView.Size.height

            let expectations: [(String, bioHeight: CGFloat, locationHeight: CGFloat, linksHeight: CGFloat, hasBadges: Bool)] = [
                ("no bio", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: defaultLinksHeight, hasBadges: true),
                ("no links", bioHeight: defaultBioHeight, locationHeight: defaultLocationHeight, linksHeight: 0, hasBadges: true),
                ("no location", bioHeight: defaultBioHeight, locationHeight: 0, linksHeight: defaultLinksHeight, hasBadges: true),
                ("no badges", bioHeight: defaultBioHeight, locationHeight: 0, linksHeight: defaultLinksHeight, hasBadges: false),
                ("no bio, no links", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: 0, hasBadges: true),
                ("no bio, no links, no location", bioHeight: 0, locationHeight: 0, linksHeight: 0, hasBadges: true),
                ("no bio, no links, no location, no badges", bioHeight: 0, locationHeight: 0, linksHeight: 0, hasBadges: false),
                ("no bio, no location", bioHeight: 0, locationHeight: 0, linksHeight: defaultLinksHeight, hasBadges: true)
            ]

            for (desc, bioHeight, locationHeight, linksHeight, hasBadges) in expectations {
                it("\(desc) profile header renders correctly") {
                    let user: User = stub([
                        "name" : "bob",
                        "username" : "bill",
                        "postsCount" : 20,
                        "followingCount" : 123,
                        "followersCount" : 444,
                        "lovesCount" : 89,
                        "formattedShortBio" : "This is a bio",
                        "location" : locationHeight > 0 ? "Denver" : "",
                        "totalViewsCount" : 1,
                        "externalLinksList" : linksHeight > 0 ? [["url" : "http://google.com", "text" : "google"]] : [],
                    ])

                    if hasBadges {
                        user.badges = [.featured, .community, .experimental]
                    }

                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .profileHeader)
                    item.calculatedCellHeights.profileAvatar = avatarHeight
                    item.calculatedCellHeights.profileTotalCount = defaultCountHeight
                    item.calculatedCellHeights.profileBadges = hasBadges ? defaultCountHeight : 0
                    item.calculatedCellHeights.profileNames = namesHeight
                    item.calculatedCellHeights.profileStats = statsHeight
                    item.calculatedCellHeights.profileBio = bioHeight
                    item.calculatedCellHeights.profileLocation = locationHeight
                    item.calculatedCellHeights.profileLinks = linksHeight

                    let totalHeight = avatarHeight + namesHeight + statsHeight + bioHeight + locationHeight + linksHeight + defaultCountHeight
                    let size = CGSize(width: width, height: totalHeight)
                    cell.frame.size = size
                    // we need to force the cell to layout so that view bounds are calculated before configure is called
                    // (ProfileLinksView needs bounds.width > 0)
                    prepareForSnapshot(cell, size: size)

                    ProfileHeaderCellPresenter.configure(cell,
                        streamCellItem: item,
                        streamKind: .currentUserStream,
                        indexPath: IndexPath(item: 0, section: 0),
                        currentUser: nil
                        )

                    expectValidSnapshot(cell, named: "ProfileHeaderCompactView-\(desc)")
                }
            }
        }
    }
}
