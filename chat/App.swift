//
//  App.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import Foundation
import Firebase
import FirebaseAuth

final class App {

    static public var shared = App()

    private var window: UIWindow!
    private var rootViewController: UIViewController? {
        didSet {
            if let rootViewController = rootViewController {
                window.rootViewController = rootViewController
            }
        }
    }
    private var handle: AuthStateDidChangeListenerHandle?

    func show(in window: UIWindow) {
        FirebaseApp.configure()
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.handleState(user)
        }
        self.window = window
        window.backgroundColor = .white
        window.tintColor = .red
        window.makeKeyAndVisible()
    }

    private func handleState(_ user: User?) {
        guard let user = user else {
            rootViewController = LoginViewController()
            return
        }
        let senderUser = SenderUser(user: user)
        let rooms = RoomsViewController(senderUser)
        rootViewController = UINavigationController.init(rootViewController: rooms)
    }

}
