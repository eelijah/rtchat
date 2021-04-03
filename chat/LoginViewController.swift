//
//  LoginViewController.swift
//  chat
//
//  Created by Eli Gutovsky on 03/04/2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    @IBAction func login(_ sender: Any) {
        guard let name = nameTextField.text else {
            return
        }
        nameTextField.resignFirstResponder()
        Auth.auth().signInAnonymously { (authResult, error) in
            guard let user = authResult?.user else { return }
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges(completion: nil)
        }
    }


}
