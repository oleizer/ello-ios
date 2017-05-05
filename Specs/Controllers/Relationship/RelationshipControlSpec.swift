////
///  RelationshipControlSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class FakeResponder: UIWindow {
    var relationshipController: RelationshipController?
    override var next: UIResponder? {
        return relationshipController
    }
}

class RelationshipControlSpec: QuickSpec {
    override func spec() {
        describe("RelationshipControl") {
            var subject: RelationshipControl!
            var presentingController: StreamableViewController!
            var relationshipController: RelationshipController!
            let viewContainer = UIView()

            beforeEach {
                subject = RelationshipControl()
                presentingController = StreamableViewController()
                presentingController.viewContainer = viewContainer
                presentingController.view.addSubview(subject) // <-- super ghetto
                relationshipController = presentingController.relationshipController
                showController(presentingController)
            }

            describe("snapshots") {
                let relationships: [(RelationshipControlStyle, RelationshipPriority)] = [
                    (.default, .following),
                    (.default, .mute),
                    (.default, .none),
                    (.profileView, .following),
                    (.profileView, .mute),
                    (.profileView, .none),
                ]
                for (style, relationship) in relationships {
                    it("setting style to \(style) and relationshipPriority to \(relationship)") {
                        subject.style = style
                        subject.relationshipPriority = relationship
                        subject.frame.size = subject.intrinsicContentSize
                        expectValidSnapshot(subject, named: "style_\(style)_relationshipPriority_\(relationship)")
                    }
                }
            }

            describe("intrinsicContentSize()") {
                it("should calculate correctly") {
                    let expectedSize = CGSize(width: 105, height: 30)
                    expect(subject.intrinsicContentSize) == expectedSize
                    subject.frame.size = expectedSize
                    subject.layoutIfNeeded()
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
            }

            describe("button targets") {
                beforeEach {
                    relationshipController.currentUser = User.stub([:])
                }

                context("not muted") {

                    describe("tapping the following button") {

                        for relationshipPriority in [RelationshipPriority.inactive, RelationshipPriority.none, RelationshipPriority.null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("unfollows the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.followingButton.sendActions(for: .touchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.following
                                }
                            }
                        }

                        context("RelationshipPriority.following") {

                            it("unfollows the user") {
                                subject.relationshipPriority = .following
                                subject.followingButton.sendActions(for: .touchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.inactive
                            }
                        }
                    }

                }

                context("muted") {

                    describe("tapping the main button") {

                        it("launches the block modal") {
                            subject.relationshipPriority = .mute
                            subject.followingButton.sendActions(for: .touchUpInside)
                            let presentedVC = relationshipController.responderChainable?.controller?.presentedViewController as? BlockUserModalViewController
                            expect(presentedVC).notTo(beNil())
                        }
                    }
                }
            }
        }
    }
}
