////
///  VideoCache.swift
//

import PINCache
import PINRemoteImage
import Alamofire
import FutureKit
import NSGIF

public enum VideoCacheType {
    case cache
    case network
}

public typealias VideoCacheResult = (FLAnimatedImage, VideoCacheType)

public struct VideoCache {

    static let failToLoadMessage = "Fail to Load Video"

    public func loadVideo(url: URL) -> Future<VideoCacheResult>  {
        let promise = Promise<VideoCacheResult>()
        let pinCache = PINRemoteImageManager.shared().pinCache
        let key = url.absoluteString

        pinCache?.object(forKeyAsync: key) { (cache, key, object) in
            guard
                let object = object as? Data,
                let animatedImage = FLAnimatedImage(animatedGIFData: object)
            else {
                self.loadVideoFromNetwork(url: url, promise: promise)
                return
            }
            inForeground {
                promise.completeWithSuccess((animatedImage, VideoCacheType.cache))
            }

        }
         return promise.future
    }

    private func loadVideoFromNetwork(url: URL, promise: Promise<VideoCacheResult>) {
        let start = Date()
        let id = url.lastPathComponent
        print("-------------")
        print("start - \(id)")
        let key = url.absoluteString
        guard let pinCache = PINRemoteImageManager.shared().pinCache else {
            promise.completeWithFail(VideoCache.failToLoadMessage)
            return
        }

        inBackground {
            NSGIF.optimalGIFfromURL(url, loopCount: 0) { gifURL in
                guard let gifURL = gifURL, FileManager.default.fileExists(atPath: gifURL.path) else {
                    promise.completeWithFail(VideoCache.failToLoadMessage)
                    return
                }
                print("transcoded - \(id) in \(Date().timeIntervalSince(start)) seconds")
                do {
                    let gif = try Data(contentsOf: gifURL)
                    pinCache.setObjectAsync(gif, forKey: key) { (cache, key, object) in
                        do { try FileManager.default.removeItem(at: gifURL) }
                        catch { print("unable to delete nsgif") }

                        guard
                            let object = object as? Data,
                            let animatedImage = FLAnimatedImage(animatedGIFData: object)
                        else {
                            promise.completeWithFail(VideoCache.failToLoadMessage)
                            return
                        }
                        inForeground {
                            promise.completeWithSuccess((animatedImage, VideoCacheType.network))
                        }
                    }
                }
                catch {
                    promise.completeWithFail(VideoCache.failToLoadMessage)
                }
            }
        }
    }
}
