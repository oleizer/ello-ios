////
///  ProfileTotalCountViewSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ProfileTotalCountViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileTotalCountView") {
            it("snapshots") {
                let subject = ProfileTotalCountView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileTotalCountView")
            }

            it("half-width") {
                let subject = ProfileTotalCountView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileTotalCountView_halfwidth")
            }
        }
    }
}
