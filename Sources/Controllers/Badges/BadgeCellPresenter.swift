////
///  BadgeCellPresenter.swift
//

struct BadgeCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? BadgeCell,
            let badge = (streamCellItem.jsonable as? Badge)?.badge
        else { return }

        cell.title = badge.name
        cell.image = badge.image.normalImage
    }

}
