//
//  SenderUser.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import Foundation
import MessageKit
import FirebaseAuth

struct SenderUser: SenderType {

    let senderId: String
    let displayName: String

    init(user: User) {
        self.senderId = user.uid
        self.displayName = user.displayName ?? "anon"
    }

    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
