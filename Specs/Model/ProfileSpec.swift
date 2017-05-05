////
///  ProfileSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileSpec: QuickSpec {
    override func spec() {
        describe("Profile") {
            describe("+fromJSON:") {
                it("parses correctly") {
                    let data = stubbedJSONData("profile", "users")
                    let profile = Profile.fromJSON(data) as! Profile

                    expect(profile.shortBio) == "Have been **spying** for a while now."
                    expect(profile.email) == "sterling@isisagency.com"
                    expect(profile.gaUniqueId) == "eb62f1c48ff87127c3120e4b5eee7a78a00cb42c"
                    expect(profile.isPublic) == false
                    expect(profile.isCommunity) == true
                    expect(profile.hasSharingEnabled) == true
                    expect(profile.hasAdNotificationsEnabled) == false
                    expect(profile.allowsAnalytics) == true
                    expect(profile.notifyOfAnnouncementsViaPush) == false
                    expect(profile.notifyOfCommentsViaEmail) == true
                    expect(profile.notifyOfMentionsViaEmail) == true
                    expect(profile.notifyOfNewFollowersViaEmail) == true
                    expect(profile.notifyOfInvitationAcceptancesViaEmail) == true
                    expect(profile.notifyOfWatchesViaEmail) == false
                    expect(profile.notifyOfCommentsOnPostWatchViaEmail) == false
                    expect(profile.subscribeToUsersEmailList) == true
                }
            }
        }
    }
}
