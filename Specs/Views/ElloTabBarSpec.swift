////
///  ElloTabBarSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloTabBarSpec: QuickSpec {
    override func spec() {
        describe("ElloTabBar") {
            var subject: ElloTabBar!
            var redDot: UIView!
            let portraitSize = CGSize(width: 320, height: 49)
            let landscapeSize = CGSize(width: 1024, height: 49)

            beforeEach {
                let items = [
                    UITabBarItem.item(.following, insets: ElloTab.following.insets),
                    UITabBarItem.item(.sparkles, insets: ElloTab.discover.insets),
                    UITabBarItem.item(.omni, insets: ElloTab.omnibar.insets),
                    UITabBarItem.item(.bolt, insets: ElloTab.notifications.insets),
                    UITabBarItem.item(.person, insets: ElloTab.profile.insets),
                ]
                subject = ElloTabBar()
                subject.items = items
                redDot = subject.addRedDotFor(tab: ElloTab.notifications)
                redDot.isHidden = false
            }

            context("red dot position") {
                context("portait") {
                    beforeEach {
                        prepareForSnapshot(subject, size: portraitSize)
                    }
                    it("should be in the correct location") {
                        expectValidSnapshot(subject)
                    }
                }
                context("landscape") {
                    beforeEach {
                        prepareForSnapshot(subject, size: landscapeSize)
                    }
                    it("should be in the correct location") {
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
