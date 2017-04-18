////
///  ProfileBadgesSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBadgesSizeCalculatorSpec: QuickSpec {
    override func spec() {

        describe("ProfileBadgesSizeCalculator") {

            it("returns 0 if badge count is 0") {
                let user: User = stub([:])
                let calc = ProfileBadgesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .onSuccess { h in height = h }
                    .onFail { _ in }
                expect(height) == 0
            }

            it("greater than 0 if badge count > 0") {
                let user: User = stub([:])
                let calc = ProfileBadgesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .onSuccess { h in height = h }
                    .onFail { _ in }
                expect(height) > 0
            }
        }
    }
}

