//
//  NewsDetailViewController.swift
//  iOS-Ass3
//
//  Created by SongXujie on 4/6/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import UIKit
import WPAPI
import SVProgressHUD
import SDWebImage

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var news: SKNews! = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = news.title
        
        self.bannerImageView.sd_setImage(with: URL(string: news.featuredMediaURL!), placeholderImage: UIImage(named: "placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
        
        let htmlData = NSString(string: news.content!).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)

        self.contentTextView.attributedText = attributedString
        
    }
    
    @IBAction func subscribeButtonClicked(_ sender: Any) {
        
    }
    
}
