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
        
        if let url = news.featuredMediaURL {
            self.bannerImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
            self.bannerImageView.image = UIImage(named: "placeholder")
        }
        
        let htmlData = NSString(string: news.content!).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)

        self.contentTextView.attributedText = attributedString
        
    }
    
    @IBAction func subscribeButtonClicked(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Subscribe to Newsletter", message: "Enter a email for subscription.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "john.doe@gmail.com"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default, handler: { [weak alert] (_) in
            let email = alert?.textFields![0].text! // Force unwrapping because we know it exists.
            
            let alert = UIAlertController(title: "Got it.", message: "Thank you for your subscription.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No worries!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // TODO: Send the captured email to remote.
            print("Subscriber Email Captured: \(String(describing: email))")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}
