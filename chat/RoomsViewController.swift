//
//  RoomsViewController.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RoomsViewController: UITableViewController {

    private let user: SenderUser
    private let firestore = Firestore.firestore()
    private let roomCellIdentifier = "roomCellIdentifier"
    private var roomsListener: ListenerRegistration?
    private var rooms: [Room] = []

    init(_ user: SenderUser) {
        self.user = user
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: roomCellIdentifier)

        roomsListener = firestore.collection("rooms").addSnapshotListener({ [weak self] (roomsSnapshot, error) in
            guard let roomsSnapshot = roomsSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard let self = self else { return }
            roomsSnapshot.documentChanges.forEach(self.handleChange)
        })
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoomButtonPressed)),
        ]
    }

    @objc private func addRoomButtonPressed() {
        let alert = UIAlertController(title: "Add room", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let createAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.createRoom(name: "\(Int.random(in: 0..<100_000))")
        })
        alert.addAction(createAction)
        present(alert, animated: true)
    }

    func createRoom(name: String) {
        let room = Room(name: name)
        firestore.collection("rooms").addDocument(data: room.document) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }

    func handleChange(_ change: DocumentChange) {
        guard let room = Room(document: change.document) else { return }
        switch change.type {
        case .added:
            addRoom(room)
        default: break
            // TODO: hanlde all other cases
        }
    }

    func addRoom(_ room: Room) {
        guard !rooms.contains(room) else { return }
        rooms.append(room)
        rooms.sort()
        guard let index = rooms.firstIndex(of: room) else {
          return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func deleteRoom(_ room: Room) {

    }

    func updateRoom(_ room: Room) {

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return rooms.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 70
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: roomCellIdentifier, for: indexPath)
      cell.textLabel?.text = rooms[indexPath.row].name
      return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let room = rooms[indexPath.row]
      let vc = ChatViewController(user: user, room: room)
      navigationController?.pushViewController(vc, animated: true)
    }

}
