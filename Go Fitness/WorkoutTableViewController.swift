//
//  WorkoutViewControllerTableViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-29.
//

import UIKit
import Firebase

class WorkoutTableViewController: UITableViewController {
    
    @IBOutlet weak var workoutTableView: UITableView!

    let workoutTableIdentifier = "workoutTableIdentifier"
    let LoginControllerIdentifier = "LoginControllerIdentifier"
    let workoutSelectionSegue = "workoutSelectionSegue"
    var videoUrls = [[String]]()
    let workoutParts = ["Back", "Abs", "Legs", "Shoulders", "Chest", "Arms"]
    let images = ["back.png", "abs.png","leg.png", "shoulders.png","chest.png","bicep.png"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerHeight = CGFloat(57)
        let footerHeight = CGFloat(57)
        let windowHeight = self.view.frame.height
        let cellHeight = (windowHeight - (footerHeight + headerHeight)) / CGFloat(workoutParts.count)
        
        self.workoutTableView.alwaysBounceVertical = false
        self.workoutTableView.tableFooterView = UIView()
        self.workoutTableView.rowHeight = cellHeight
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        for i in 0..<workoutParts.count{
            Database.database().reference().child("urls").child(workoutParts[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                self.videoUrls.append(snapshot.value as! [String])

        }) { (error) in
            print(error.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - Firebase Log Out

    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Logout", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.handleLogout()
        }))
        
        alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workoutParts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = workoutTableView?.dequeueReusableCell(withIdentifier: workoutTableIdentifier, for: indexPath)
        // Configure the cell...
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: workoutTableIdentifier)
        }

        cell?.textLabel?.text = workoutParts[indexPath.row]
        cell?.imageView?.image = UIImage(named: images[indexPath.row])

        return cell!
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == workoutSelectionSegue {
            //get the index of the row selected in the table
            let indexPath = workoutTableView.indexPath(for: sender as! UITableViewCell)!

            //segue to the details screen
            let videosTableVC = segue.destination as! VideosTableViewController
            videosTableVC.urls = videoUrls[indexPath.row]
        }
    }
}
