////
///  MessengerService.swift
//

import Moya
import SwiftyJSON

public typealias CreateConversationSuccessCompletion = (conversation: Conversation) -> Void

public struct MessengerService {

    public init(){}

    public func createConversation(
        users: [User],
        success: CreateConversationSuccessCompletion,
        failure: ElloFailureCompletion? = nil) {
        let endpoint: ElloAPI = .CreateConversation(users: users)

        ElloProvider.shared.elloRequest(
            endpoint,
            success: { (data, responseConfig) in
                guard let
                    conversation = data as? Conversation
                else {
                    if let failure = failure {
                        ElloProvider.unCastableJSONAble(failure)
                    }
                    return
                }
                success(conversation: conversation)
                print("successfully created a conversation")
            },
            failure: { (error, statusCode) in
                print("FAILED to creat a conversation")
                failure?(error: error, statusCode: statusCode)
            })
    }
}
