//
//  ViewController.swift
//  Go Fitness
//
//  Created by Akanksha Malik on 2018-03-21.
//

import UIKit
import Firebase
import FBSDKLoginKit


class SignInViewController: UIViewController, UITextFieldDelegate {
    let loginViewToProfileViewSegueIdentifier: String = "loginViewToProfileViewSegueIdentifier"

    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.emailTextField.delegate = self;
        self.passwordTextField.delegate = self;
        let akankshasColor = UIColor(red: CGFloat(0.053), green: CGFloat(0.069), blue: CGFloat(0.095), alpha: 1);
        self.view.backgroundColor = akankshasColor;
        self.emailTextField.backgroundColor = akankshasColor;
        self.passwordTextField.backgroundColor = akankshasColor;
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        let cyan = UIColor(red: CGFloat(0), green: CGFloat(0.6), blue: CGFloat(0.4), alpha: 1);
        let teal = UIColor(red: CGFloat(0), green: CGFloat(0.4), blue: CGFloat(0.5), alpha: 1);
        self.signinButton.applyGradient(colours: [cyan, teal])
        self.signinButton.layer.cornerRadius = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (fbuser, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return

                }
                if let userID = Auth.auth().currentUser?.uid {
                    let dbReference = Database.database().reference()
                    dbReference.child("users").child(userID).child("name").setValue(fbuser?.displayName!)
                    dbReference.child("users").child(userID).child("email").setValue(fbuser?.email!)
                    dbReference.child("users").child(userID).child("imageUrl").setValue(fbuser?.photoURL?.absoluteString)
                    self.performSegue(withIdentifier: self.loginViewToProfileViewSegueIdentifier, sender: self)
                }
            })
        }
    }
    

    @IBAction func loginButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        // [START headless_email_auth]
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // [START_EXCLUDE]
                if let error = error {
                    let message:String = error.localizedDescription
                    self.displayAlert(myTitle: "Error", myMessage: message)
                    return
                }
            print("successfully logged in")
            // jump to profile view
            self.performSegue(withIdentifier: self.loginViewToProfileViewSegueIdentifier, sender: self)
            // [END_EXCLUDE]
        }
        // [END headless_email_auth]
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func textFieldFinishedEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    private func displayAlert(myTitle: String, myMessage: String) {
        let myAlert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert,animated:true,completion: nil)
    }
}

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}
