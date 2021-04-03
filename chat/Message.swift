//
//  Message.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import Foundation
import MessageKit
import FirebaseAuth
import FirebaseFirestore

struct Message: MessageType {

    var sender: SenderType
    var messageId: String
    var kind: MessageKind
    var sentDate: Date

    init(sender: SenderUser, text: String) {
        self.sender = sender
        sentDate = Date()
        messageId = UUID().uuidString
        kind = .text(text)
    }

    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        let time = data["sentDate"] as! Timestamp
        sentDate = time.dateValue()
        sender = SenderUser(senderId: data["senderId"] as! String, displayName: data["displayName"] as! String)
        messageId = document.documentID
        kind = .text(data["text"] as! String)
    }
}

extension Message {

    var document: [String : Any] {
        var result: [String : Any] = [
            "sentDate": sentDate,
            "messageId": messageId,
            "senderId": sender.senderId,
            "displayName": sender.displayName,
        ]
        switch kind {
        case let .text(text):
            result["text"] = text
        default:
            break
        }
        return result
    }

}

extension Message: Comparable {

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }

}
