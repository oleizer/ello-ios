//
//  ExperienceUpdate.swift
//  Ello
//
//  Created by Sean on 4/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public let CommentChangedNotification = TypedNotification<(Comment, ContentChange)>(name: "commentChangedNotification")
public let PostChangedNotification = TypedNotification<(Post, ContentChange)>(name: "postChangedNotification")
public let LoveChangedNotification = TypedNotification<(Love, ContentChange)>(name: "loveChangedNotification")
public let RelationshipChangedNotification = TypedNotification<User>(name: "relationshipChangedNotification")
public let SettingChangedNotification = TypedNotification<User>(name: "settingChangedNotification")

public enum ContentChange {
    case Create
    case Read
    case Update
    case Delete
}
