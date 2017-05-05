////
///  StreamImageCellSizeCalculator.swift
//

class StreamImageCellSizeCalculator {
    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var screenWidth: CGFloat = 0.0
    fileprivate var columnCount: Int = 1
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var completion: ElloEmptyCompletion = {}

// MARK: Static

    static func aspectRatioForImageRegion(_ imageRegion: ImageRegion) -> CGFloat {
        guard let asset = imageRegion.asset else { return 4/3 }
        return asset.aspectRatio
    }

// MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: @escaping ElloEmptyCompletion) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

// MARK: Private

    fileprivate func processJob(_ job: CellJob) {
        self.completion = {
            if self.cellJobs.count > 0 {
                self.cellJobs.remove(at: 0)
            }
            job.completion()
            if let nextJob = self.cellJobs.safeValue(0) {
                self.processJob(nextJob)
            }
        }
        self.cellItems = job.cellItems
        self.screenWidth = job.width
        self.columnCount = job.columnCount
        loadNext()
    }

    fileprivate func loadNext() {
        guard !self.cellItems.isEmpty else {
            completion()
            return
        }

        let item = cellItems.remove(at: 0)
        let margin: CGFloat
        if (item.type.data as? Regionable)?.isRepost == true {
            margin = StreamTextCell.Size.repostMargin
        }
        else if item.jsonable is ElloComment {
            margin = StreamTextCell.Size.commentMargin
        }
        else {
            margin = 0
        }

        if let imageRegion = item.type.data as? ImageRegion {
            let oneColumnHeight = StreamImageCell.Size.bottomMargin + oneColumnImageHeight(imageRegion, margin: margin)
            let multiColumnHeight = StreamImageCell.Size.bottomMargin + multiColumnImageHeight(imageRegion, margin: margin)
            item.calculatedCellHeights.oneColumn = oneColumnHeight
            item.calculatedCellHeights.multiColumn = multiColumnHeight
        }
        else if let embedRegion = item.type.data as? EmbedRegion {
            var ratio: CGFloat
            if embedRegion.isAudioEmbed || embedRegion.service == .uStream {
                ratio = 1
            }
            else {
                ratio = 16 / 9
            }
            let multiWidth = calculateColumnWidth(frameWidth: screenWidth, columnCount: columnCount) - margin
            item.calculatedCellHeights.oneColumn = StreamImageCell.Size.bottomMargin + (screenWidth - margin) / ratio
            item.calculatedCellHeights.multiColumn = StreamImageCell.Size.bottomMargin + multiWidth / ratio
        }
        loadNext()
    }

    fileprivate func oneColumnImageHeight(_ imageRegion: ImageRegion, margin: CGFloat) -> CGFloat {
        var imageWidth = screenWidth - margin
        if let assetWidth = imageRegion.asset?.oneColumnAttachment?.width {
            imageWidth = min(imageWidth, CGFloat(assetWidth))
        }
        return ceil(imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion))
    }

    fileprivate func multiColumnImageHeight(_ imageRegion: ImageRegion, margin: CGFloat) -> CGFloat {
        var imageWidth = calculateColumnWidth(frameWidth: screenWidth, columnCount: columnCount) - margin
        if let assetWidth = imageRegion.asset?.gridLayoutAttachment?.width {
            imageWidth = min(imageWidth, CGFloat(assetWidth))
        }
        return ceil(imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion))
    }

}
