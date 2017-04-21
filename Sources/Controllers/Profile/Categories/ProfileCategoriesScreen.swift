////
///  ProfileCategoriesScreen.swift
//

import SnapKit


class ProfileCategoriesScreen: Screen, ProfileCategoriesProtocol {

    struct Size {
        static let textInset: CGFloat = 15
        static let learnMoreSpacing: CGFloat = 20
    }

    weak var delegate: ProfileCategoriesDelegate?
    let categories: [Category]

    fileprivate let textView = ElloTextView()
    fileprivate let learnMoreButton = StyledButton(style: .grayUnderlined)

    init(categories: [Category]) {
        self.categories = categories
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("use init(categories:)")
    }

    override func style() {
        backgroundColor = .clear
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.allowsEditingTextAttributes = false
        textView.isSelectable = false
        textView.textColor = .white
    }

    override func bindActions() {
        textView.textViewDelegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(gesture)
    }

    override func setText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        var featuredIn = NSAttributedString(string: InterfaceString.Profile.FeaturedIn, attributes: attrs([
                NSParagraphStyleAttributeName: paragraphStyle
            ]))

        let count = categories.count
        for (index, category) in categories.enumerated() {
            let prefix: NSAttributedString
            if index == count - 1 && count > 1 {
                prefix = NSAttributedString(string: " & ", attributes: attrs())
            }
            else if index > 0 {
                prefix = NSAttributedString(string: ", ", attributes: attrs())
            }
            else {
                prefix = NSAttributedString(string: " ", attributes: attrs())
            }
            featuredIn = featuredIn.appending(prefix)
                .appending(styleCategory(category))
        }

        textView.attributedText = featuredIn
        textView.sizeToFit()

        learnMoreButton.setTitle(InterfaceString.Badges.LearnMore, for: .normal)
    }

    override func arrange() {
        super.arrange()

        addSubview(textView)
        addSubview(learnMoreButton)

        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.textInset)
            make.centerY.equalTo(self)
        }

        learnMoreButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(textView.snp.bottom).offset(Size.learnMoreSpacing)
        }
    }

    func dismiss() {
        delegate?.dismiss()
    }
}

extension ProfileCategoriesScreen: ElloTextViewDelegate {

    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        switch object {
        case let .attributedCategory(category):
            delegate?.categoryTapped(category)
        default: break
        }
    }

    func textViewTappedDefault() {
        // no-op
    }
}

private extension ProfileCategoriesScreen {

    func styleCategory(_ category: Category) -> NSAttributedString {
        return NSAttributedString(string: category.name, attributes: attrs([
            ElloAttributedText.Link: "category" as AnyObject,
            ElloAttributedText.Object: category,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
        ]))
    }

    func attrs(_ addlAttrs: [String : AnyObject] = [:]) -> [String : AnyObject] {
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(18),
            NSForegroundColorAttributeName: UIColor.white,
        ]
        return attrs + addlAttrs
    }
}
