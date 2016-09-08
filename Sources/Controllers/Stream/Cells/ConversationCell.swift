////
///  ConversationCell.swift
//

import SnapKit

public class ConversationCell: UICollectionViewCell {
    static let reuseIdentifier = "ConversationCell"

    struct Size {
        static let sideMargins: CGFloat = 15
        static let padding: CGFloat = 5
        static let lineHeight: CGFloat = 1
    }

    var title: String {
        set { titleLabel.text = newValue }
        get { return titleLabel.text ?? "" }
    }

    var subTitle: String {
        set { subTitleLabel.text = newValue }
        get { return subTitleLabel.text ?? "" }
    }

    private let titleLabel = ElloLabel()
    private let subTitleLabel = ElloLabel()
    override public init(frame: CGRect) {
        super.init(frame: frame)

        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrange() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)

        titleLabel.snp_makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(Size.sideMargins)
        }

        subTitleLabel.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(Size.padding)
            make.left.equalTo(contentView).offset(Size.sideMargins)
        }
    }
}
