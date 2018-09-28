//
//  SecondViewController.swift
//  rutgersMap
//
//  Created by Wahhaj Zahedi on 9/27/18.
//  Copyright © 2018 Wahhaj Zahedi. All rights reserved.
//

import UIKit
import WebKit
import DynamicButton


class SecondViewController: UIViewController{
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: DynamicButton!
    @IBOutlet weak var forwardButton: DynamicButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forwardButton.style = .arrowRight
        forwardButton.setStyle(.arrowRight, animated: true)
        forwardButton.lineWidth           = 3
        forwardButton.strokeColor         = .black
        forwardButton.highlightStokeColor = .gray
        
        backButton.style = .arrowLeft
        backButton.setStyle(.arrowLeft, animated: true)
        backButton.lineWidth           = 3
        backButton.strokeColor         = .black
        backButton.highlightStokeColor = .gray
        let myURL = URL(string:"https://sakai.rutgers.edu/portal")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
    @IBAction func back(_ sender: Any) {
        if(webView.canGoBack){
            webView.goBack()
        }
    }
    @IBAction func forward(_ sender: Any) {
        if(webView.canGoForward){
            webView.goForward()
        }
    }
    

}

