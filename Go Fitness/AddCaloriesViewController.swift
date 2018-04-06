//
//  AddCaloriesViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-04-05.
//

import UIKit
import Firebase

class AddCaloriesViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private let NUM_COMPONENTS = 1
    private var food:Food?
    private let mealType = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    @IBOutlet weak var mealPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.caloriesTextField.delegate = self;
        self.nameTextField.delegate = self;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getFood()->Food?{
        return food
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func textFieldFinishedEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
        enableDisableSaveButton()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        caloriesTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        enableDisableSaveButton()
    }
    
    public func enableDisableSaveButton(){
        if (nameTextField.text == "" || caloriesTextField.text == ""){
            saveButton.isEnabled = false
        }else{
            saveButton.isEnabled = true
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return NUM_COMPONENTS
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return mealType[row]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let name = nameTextField.text!
        let calories = Int(caloriesTextField.text!)
        let row = mealPickerView.selectedRow(inComponent: 0)
        let mealType = self.mealType[row]
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM, yyyy"
        let date = Date()
        dateFormatterGet.date(from: String(describing: date))

        let key: String = dateFormatterPrint.string(from: date)
        food = Food(myType: mealType, myName: name, myCalorie: calories!, myDate: key)

        return

    }

}
