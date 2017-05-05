////
///  ProfileBadgesViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBadgesViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileBadgesView") {
            it("badges featured") {
                let subject = ProfileBadgesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.badges = [.featured]
                expectValidSnapshot(subject)
            }

            it("badges featured, community") {
                let subject = ProfileBadgesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.badges = [.featured, .community]
                expectValidSnapshot(subject)
            }

            it("badges featured, community, experimental") {
                let subject = ProfileBadgesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.badges = [.featured, .community, .experimental]
                expectValidSnapshot(subject)
            }

            it("badges featured, community, experimental, staff") {
                let subject = ProfileBadgesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.badges = [.featured, .community, .experimental, .staff]
                expectValidSnapshot(subject)
            }
        }
    }
}
