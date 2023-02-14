//
//  FullVersionViewController.swift
//  NewsApp
//
//  Created by Илья Казначеев on 04.02.2023.
//

import UIKit
import WebKit

class FullVersionViewController: UIViewController, WKNavigationDelegate {
    
    private let webview: WKWebView = WKWebView()
    public var link: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        webview.frame = view.bounds;
        webview.navigationDelegate = self
        view.addSubview(webview)
        let url = URL(string: link)
        let request = URLRequest(url: url!)
        
        DispatchQueue.main.async {
            self.webview.load(request)
        }
    }
}
