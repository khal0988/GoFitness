//
//  ProfileViewController.swift
//  Go Fitness
//
//  Created by Akanksha Malik on 2018-03-22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let LoginControllerIdentifier = "LoginControllerIdentifier"
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var bmiField: UILabel! //populate once user enters weight, height, gender
    @IBOutlet weak var calorieTextField: UILabel! //populate once user enters weight, height, gender
    
    @IBOutlet weak var genderPicker: UIPickerView!
    
    private let NUM_COMPONENTS = 1
    private let genders = ["", "Male", "Female"]
    private var profile_image_url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        
        loadUserProfileFromFirebase()
        _ = Steps()
        Steps.sharedSteps.setUp()
        Steps.sharedSteps.startUpdating()
        
    } // viewDidLoad
    
    func loadUserProfileFromFirebase() {
        let userID = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            
            self.userName.text = value?["name"] as? String ?? ""
            self.ageTextField.text = value?["age"] as? String ?? ""
            self.weightTextField.text = value?["weight"] as? String ?? ""
            self.heightTextField.text = value?["height"] as? String ?? ""
            self.bmiField.text = value?["bmi"] as? String ?? ""
            self.calorieTextField.text = value?["calories"] as? String ?? ""
            let row = self.genders.index(of: value?["gender"] as? String ?? "")
            
            self.genderPicker.selectRow(row!, inComponent: 0, animated: true)
            
            if let imageURL = value?["imageUrl"] as? String{
                let url = NSURL(string: imageURL)
                URLSession.shared.dataTask(with: url! as URL, completionHandler: {(data, response, error) in
                    if error != nil{
                        print(error?.localizedDescription as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data:data!)
                    }
                }).resume()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("logged out successfullty")
            // jump to login view
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: LoginControllerIdentifier)
            present(loginViewController!, animated: true, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    @IBAction func LogoutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Logout", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.handleLogout()
        }))
        
        alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Update Profile", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            self.updateUserProfile()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Discard", style: .cancel, handler: { _ in
            self.discardUpdateUserProfile()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func discardUpdateUserProfile() {
        loadUserProfileFromFirebase()
    }
    
    // Mark: - data Picker delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return NUM_COMPONENTS
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return genders[row]
    }
    
    // Mark: - Update user profile methods
    
    private func updateUserProfile() {
        let pendingSavingAlert = displayActivityIndicator(message: "Saving...")
        
        let userID = Auth.auth().currentUser?.uid
        let row = genderPicker.selectedRow(inComponent: 0)
        let gender = genders[row]
        
        if (row == 0) {
            let message:String = "All fields are required to perfrom calculations"
            self.displayAlert(myTitle: "Error", myMessage: message)
            return
        }
        
        guard let weight = weightTextField.text,
            let height = heightTextField.text, let age = ageTextField.text else {
                let message:String = "All fields are required to perfrom calculations"
                self.displayAlert(myTitle: "Error", myMessage: message)
                return
        }
        let cm = CalculateBMI(weight: weight, height: height)
        let bmi = cm.calcBmi()
        
        bmiField.text = String(format: "%.1f", bmi)
        
        let calorie = CalculateCalorie(weight: weight, height: height, age: age, gender: gender)
        let cal = calorie.calcCal()
        calorieTextField.text = "\(cal)"
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM, yyyy"
        let date = Date()
        dateFormatterGet.date(from: String(describing: date))
        let key: String = dateFormatterPrint.string(from: date)
        
        Database.database().reference().child("users").child(userID!).child("weight").setValue(weight)
        Database.database().reference().child("weights").child(userID!).child(key).setValue(Double(weight))
        Database.database().reference().child("users").child(userID!).child("height").setValue(height)
        Database.database().reference().child("users").child(userID!).child("age").setValue(age)
        Database.database().reference().child("users").child(userID!).child("gender").setValue(gender)
        Database.database().reference().child("users").child(userID!).child("bmi").setValue(String(format: "%.1f", bmi))
        Database.database().reference().child("users").child(userID!).child("calories").setValue(String(format: "%d", cal))
        
        self.uploadProfilePictureToFireBase(userID: userID!, myAlert: pendingSavingAlert)
        
    }
    
    private func uploadProfilePictureToFireBase(userID: String, myAlert: UIAlertController) {
        let storageRef = Storage.storage().reference().child(userID + ".png")
        if let imageData = UIImagePNGRepresentation(profileImageView.image!){
            storageRef.putData(imageData, metadata: nil, completion: { (UserMetadata, error) in
                
                if error != nil{
                    print(error as Any)
                    return
                }
                
                let imageUrl = UserMetadata?.downloadURL()?.absoluteString
                Database.database().reference().child("users").child(userID).child("imageUrl").setValue(imageUrl, withCompletionBlock: { (error, ref) in
                    print("Completed")
                    self.stopActivityIndicator(myAlert: myAlert)
                })
            })
        }
    }
    
    private func stopActivityIndicator(myAlert: UIAlertController) {
        myAlert.dismiss(animated: true, completion: nil)
    }
    
    private func displayActivityIndicator(message: String) -> UIAlertController {
        let pendingSavingAlert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = self.view.center
        
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = true
        pendingSavingAlert.view.addSubview(myActivityIndicator)
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        self.present(pendingSavingAlert, animated: true, completion: nil)
        
        return pendingSavingAlert
    }
    
    private func displayAlert(myTitle: String, myMessage: String) {
        let myAlert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert,animated:true,completion: nil)
    }
    
    // MARK: - Image picker delegate methods
    
    @IBAction func profileImageTap(_ sender: UIImageView) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openPhotoLibrary () {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let imagePickerController = UIImagePickerController()
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
            
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        profileImageView.image = selectedImage
        UIImageWriteToSavedPhotosAlbum(profileImageView.image!,nil, nil,nil)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backgroundTap(_ sender: UIControl) {
        ageTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
