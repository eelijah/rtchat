//
//  ChatViewController.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    private let user: SenderUser
    private let room: Room
    private let firestore = Firestore.firestore()
    private var messages: [Message] = []
    private var messagesRef: CollectionReference?
    private var messageListener: ListenerRegistration?

    init(user: SenderUser, room: Room) {
        self.user = user
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirestore()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        maintainPositionOnKeyboardFrameChanged = true
    }

    private func setupFirestore() {
        guard let roomId = room.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        messagesRef = firestore.collection("rooms/\(roomId)/messages")
        messageListener = messagesRef?.addSnapshotListener({ [weak self] (messagesSnapshot, error) in
            guard let messagesSnapshot = messagesSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard let self = self else { return }
            messagesSnapshot.documentChanges.forEach(self.handleChange)
        })
    }

    private func handleChange(_ change: DocumentChange) {
        let message = Message(document: change.document)
        switch change.type {
        case .added:
            showMessage(message)
        default:
            break
        }
    }

    private func saveMessage(_ message: Message) {
        messagesRef?.addDocument(data: message.document)
    }

    private func showMessage(_ message: Message) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        messagesCollectionView.reloadData()
    }

}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return user
    }

    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}

extension ChatViewController: MessagesLayoutDelegate {

}

extension ChatViewController: MessagesDisplayDelegate {

}

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(sender: user, text: text)
        saveMessage(message)
        inputBar.inputTextView.text = ""
    }

}
