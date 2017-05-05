////
///  JWT.swift
//

import JWTDecode


public struct JWT {
    public static func refresh() {
        var authToken = AuthToken()
        guard let accessToken = authToken.token else { return }

        do {
            let jwt = try decode(jwt: accessToken)
            guard
                let data = jwt.body["data"] as? [String: Any]
            else { return }

            authToken.isStaff = data["is_staff"] as? Bool ?? false
            authToken.isNabaroo = data["is_nabaroo"] as? Bool ?? false
        }
        catch {
            print("Unable to decode JWT")
        }
    }
}
