//
//  CodeViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/11/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit
import WebKit

class CodeViewController: UIViewController {
    
    private var webView: UIWebView = UIWebView(frame: CGRectZero)
    private let baseUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
    
    var codeTitle: String = NSLocalizedString("Code", comment: "Code")
    var language: String = "nohighlight"
    var snippet: String = ""
    var theme: String = "github-gist"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = codeTitle

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        setCodeViewWithLanguage(language, theme: theme, lineNumber: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CodeViewController {
    
    func setCodeViewWithLanguage(language:String, theme:String, lineNumber: Bool) {
        
        let codehtmlPath = NSBundle.mainBundle().pathForResource("code", ofType: "html")
        let codehtml = try? NSString(contentsOfFile: codehtmlPath!, encoding: NSUTF8StringEncoding)
        
        let codeCssPath = NSBundle.mainBundle().pathForResource("code", ofType: "css")
        let highlightJsPath = NSBundle.mainBundle().pathForResource("highlight.pack", ofType: "js")
        let themeCssPath = NSBundle.mainBundle().pathForResource(theme, ofType: "css")
        let hasLineNumber = lineNumber ? "true" : "false"
        
        let transformedSnippet = snippet.stringByReplacingOccurrencesOfString("<", withString: "&lt;").stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        
        let finalCodeHtml = NSString(format: codehtml!, themeCssPath!, codeCssPath!, highlightJsPath!, hasLineNumber, language, transformedSnippet) as String
        
        webView.loadHTMLString(finalCodeHtml, baseURL: baseUrl)
    }
    
}
