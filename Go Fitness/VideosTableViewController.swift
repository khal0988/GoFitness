//
//  VideosViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-29.
//

import UIKit

class VideosTableViewController: UITableViewController {
    
    let videoCellIdentifier = "videoCellIdentifier"
    var urls = [String]()
    
    @IBOutlet weak var videoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoTableView.rowHeight = 200

   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return urls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = videoTableView.dequeueReusableCell(withIdentifier: videoCellIdentifier, for: indexPath) as! YoutubeDataTableViewCell

        
        let videoUrl = NSURL(string: urls[indexPath.row] )
        URLSession.shared.dataTask(with: videoUrl! as URL, completionHandler: {(data, response, error) in

            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }

            DispatchQueue.main.async {
                let requestObj = URLRequest(url: videoUrl! as URL)
                _ = cell.webView.load(requestObj)
            }
        }).resume()

        return cell
    }

}
