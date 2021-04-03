//
//  Room.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import Foundation
import FirebaseFirestore

struct Room: Codable {

    let id: String?
    let name: String

    init?(document: QueryDocumentSnapshot) {
      let data = document.data()

      guard let name = data["name"] as? String else {
        return nil
      }

      id = document.documentID
      self.name = name
    }

    init(name: String) {
        self.name = name
        self.id = nil
    }
}

extension Room {

    var document: [String : Any] {
        var result: [String : Any] = [
            "name": name
        ]
        if let id = id {
            result["id"] = id
        }
        return result
    }

}

extension Room: Comparable {

    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Room, rhs: Room) -> Bool {
        return lhs.name < rhs.name
    }

}
