////
///  VideoLoopView.swift
//
// Heavily inspired by https://github.com/liaujianjie/VideoLoopView/blob/master/VideoLoopView/VideoLoopView.swift

import UIKit
import AVFoundation
import FutureKit
import PINRemoteImage
import PINCache
import Alamofire

let assetPool = AVAssetPool()

class AssetWithThumbnail {
    let asset: AVURLAsset
    var thumbnail: UIImage?
    init(asset: AVURLAsset){
        self.asset = asset
    }
}

class AVAssetPool: NSObject {
    var assets: [String : AssetWithThumbnail] = [:]
    var memoryObserver: NotificationObserver?

    override init() {
        super.init()
        setupObservers()
    }

    func setupObservers() {
        self.memoryObserver = NotificationObserver(notification: Application.Notifications.DidReceiveMemoryWarning) { [weak self] _ in
            self?.assets = [:]
        }
    }

    deinit {
        memoryObserver?.removeObserver()
    }

    func itemFor(url: URL) -> AssetWithThumbnail {
        let key = url.absoluteString
        guard let assetWithThumbnail = assets[key] else {
            let newAsset = AVURLAsset(url: url)
            let newAssetWithThumbnail = AssetWithThumbnail(asset: newAsset)
            assets[key] = newAssetWithThumbnail
            generateThumbnailFor(asset: newAsset, key: key)
            return newAssetWithThumbnail
        }
        return assetWithThumbnail
    }

    func generateThumbnailFor(asset: AVURLAsset, key: String) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage: CGImage = try imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            assetPool.assets[key]?.thumbnail = image
        }
        catch {
            print("unable to generate thumbnail")
        }
    }
}

public class VideoLoopView: UIView {
    private var isObserving = false
    private var shouldPlay = true
    private var promise = Promise<VideoCacheType>()
    private var cacheType: VideoCacheType!
    private var videoObserver: NSObjectProtocol?
    private var foregroundObserver: NotificationObserver?
    private var backgroundObserver: NotificationObserver?
    private let playerLayer: AVPlayerLayer = AVPlayerLayer()
    private var player = AVPlayer(playerItem: nil)
    private var playerItem: AVPlayerItem?
    private var playerAsset: AVURLAsset?
    private var thumbnailView: UIImageView?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = bounds
        CATransaction.commit()
    }

    deinit {
        removeObservers()
    }

    public func loadVideo(url: URL) -> Future<VideoCacheType>  {
        promise = Promise<VideoCacheType>()
        let cache = VideoCache()
        cache.loadVideo(url: url)
            .onSuccess { [weak self] (url, type) in
                guard let `self` = self else { return }
                self.cacheType = type
                inForeground {
                    if let image = assetPool.assets[url.absoluteString]?.thumbnail
                    {
                        let thumbnail = UIImageView(image: image)
                        self.thumbnailView?.removeFromSuperview()
                        self.thumbnailView = thumbnail
                        self.thumbnailView?.contentMode = .scaleAspectFit
                        self.thumbnailView?.frame = self.bounds
                        self.thumbnailView?.alpha = 0.5
                        self.addSubview(thumbnail)
                    }
                    self.setupPlayer(url: url)
                }
            }
            .onFail { _ in
                self.promise.completeWithFail("Unable to Load")
        }
        return promise.future
    }

    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        guard keyPath == #keyPath(AVPlayerItem.status) else { return }

        let status: AVPlayerItemStatus

        if let statusNumber = change?[.newKey] as? NSNumber {
            status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
        } else {
            status = .unknown
        }

        switch status {
        case .readyToPlay:
            completeSuccessfully()
        case .failed:
            print(playerItem?.error?.localizedDescription ?? "failed, unknown error")
            promise.completeWithFail("Failed To Load")
        case .unknown:
            break
        }
    }

    private func completeSuccessfully() {
        thumbnailView?.removeFromSuperview()
        thumbnailView = nil
        promise.completeWithSuccess(cacheType)
    }

    public func reset() {
        thumbnailView?.removeFromSuperview()
        thumbnailView = nil
    }

    public func playVideo() {
        shouldPlay = true
        play()
    }

    public func pauseVideo() {
        shouldPlay = false
        player.pause()
    }

    private func setup() {
        player.actionAtItemEnd = .none
        player.isMuted = true
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)
        playerLayer.player = player
    }

    private func setupPlayer(url: URL) {

        let asset = assetPool.itemFor(url: url).asset


        guard asset != playerAsset else {
            self.play()
            self.promise.completeWithSuccess(self.cacheType)
            return
        }

        removeObservers()
        playerAsset = asset
        playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        addObservers()

        play()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func addObservers() {
        isObserving = true
        playerItem?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
            context: nil
        )

        if playerItem?.status == .readyToPlay {
            completeSuccessfully()
        }

        videoObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [weak self] _ in
            guard let `self` = self, self.shouldPlay else { return }

            inForeground {
                self.player.seek(to: kCMTimeZero)
            }
        }

        foregroundObserver = NotificationObserver(notification: Application.Notifications.WillEnterForeground) { [weak self] _ in
            guard let `self` = self, self.shouldPlay else { return }

            inForeground {
                self.play()
            }
        }

        backgroundObserver = NotificationObserver(notification: Application.Notifications.DidEnterBackground) { [weak self] _ in
            guard let `self` = self, self.shouldPlay else { return }

            inForeground {
                self.player.pause()
            }
        }
    }

    private func removeObservers() {
        guard isObserving else { return }
        isObserving = false
        NotificationCenter.default.removeObserver(self)
        if let observer = videoObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        foregroundObserver?.removeObserver()
        backgroundObserver?.removeObserver()
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }

    private func play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let error as NSError {
            print(error)
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        if playerItem?.status == .readyToPlay {
            thumbnailView?.removeFromSuperview()
            thumbnailView = nil
        }
        player.play()
    }
}
