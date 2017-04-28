////
///  BadgesService.swift
//

import Alamofire
import SwiftyJSON


class BadgesService {
    static var badges: [String: ProfileBadge] = [:]
    static func loadStaticBadges() {
        Alamofire.request("\(ElloURI.baseURL)/api/v2/badges.json")
            .responseJSON { response in
                guard
                    let jsonObject = response.result.value as? [String: Any],
                    let badgesJson = jsonObject["badges"] as? [[String: Any]]
                else { return }

                let badges: [Int] = badgesJson.map { badge in
                    print("badge: \(badge)")
                    return 1
                }
            }
    }
}
