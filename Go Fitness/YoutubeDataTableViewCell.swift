//
//  YoutubeDataTableViewCell.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-29.
//

import UIKit
import WebKit

class YoutubeDataTableViewCell: UITableViewCell, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        //print("loading")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        //print("finished")
    }
}


