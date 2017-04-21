////
///  BadgeCell.swift
//

import SnapKit


class BadgeCell: UICollectionViewCell {
    static let reuseIdentifier = "BadgeCell"

    struct Size {
        static let imageInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 0)
        static let grayInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        static let labelMargin: CGFloat = 20
    }

    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }

    fileprivate let label = StyledLabel(style: .black)
    fileprivate let imageView = UIImageView()
    fileprivate let grayLine = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
    }

    fileprivate func style() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        grayLine.backgroundColor = .greyE5()
    }

    fileprivate func arrange() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(grayLine)

        imageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(contentView).inset(Size.imageInsets)
        }
        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(imageView.snp.trailing).offset(Size.labelMargin)
        }
        grayLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView).inset(Size.grayInsets)
            make.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.layer.cornerRadius = max(imageView.frame.width / 2, imageView.frame.height / 2)
    }
}
