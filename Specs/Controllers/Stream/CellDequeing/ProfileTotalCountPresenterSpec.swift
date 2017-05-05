////
///  ProfileTotalCountPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileTotalCountPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileTotalCountPresenter") {

            it("assigns posts count") {
                let user = User.stub(["totalViewsCount": 2_401_000])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count) == "2.4M"
            }

            it("renders nothing when no totalViewCount is present") {
                let user = User.stub([:])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count).to(beNil())
            }
        }
    }
}
