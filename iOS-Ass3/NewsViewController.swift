//
//  NewsViewController.swift
//  iOS-Ass3
//
//  Created by SongXujie on 4/6/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import UIKit
import WPAPI
import SVProgressHUD
import SDWebImage

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    var resultSearchController = UISearchController()
    
    var category: SKCategory! = nil
    
    var newsArray: [SKNews] = []
    var searchString: String?
    var currentPage = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = category.name
        
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(reloadNews), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        reloadNews()
        
        // set up searchbar
        self.resultSearchController = UISearchController(searchResultsController:nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.placeholder = "Search..."
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        resultSearchController.searchBar.delegate = self
        
    }
    
    @objc func reloadNews() {
        // Reset Search
        self.searchString = nil
        // Reset currentPage to 1
        self.currentPage = 1
        // Reset adsArray to empty
        self.newsArray = []
        // Download News again
        downloadNews()
    }
    
    func loadMoreNews() {
        // Increase currentPage by 1
        self.currentPage += 1
        // Download News again
        downloadNews()
    }
    
    func downloadNews() {
        
        // End Pull to refresh & begin loading
        self.refreshControl.endRefreshing()
        SVProgressHUD.show(withStatus: "Loading News...")
        
        SKNews.list(page: self.currentPage,
                    perPage: AppDelegate.PER_PAGE,
                    search: self.searchString,
                    categories: [category.id!]) { (response: Result<[SKNews]>) in
            switch response {
            case .success(let downloadedNews):
                
                DispatchQueue.main.async(execute: {
                    self.newsArray += downloadedNews
                    self.tableView.reloadData()
                })
                
                SVProgressHUD.dismiss()
            case .failure(let error):
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Oops", message: "Error Loading News...", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
                        self.downloadNews()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in
                        self.newsArray = []
                        self.searchString = nil
                        self.currentPage = 1
                        self.downloadNews()
                    }))
                    
                    print("Error: \(error.localizedDescription)")
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    SVProgressHUD.dismiss()
                    
                })
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Reset Values
        self.newsArray = []
        self.currentPage = 1
        
        // Perform Search
        downloadNews()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // Reset Search
        self.searchString = nil
        
        // Reset Values
        self.newsArray = []
        self.currentPage = 1
        
        // Perform Search
        downloadNews()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Update Search
        self.searchString = resultSearchController.searchBar.text!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as! BannerTableViewCell
        
        let news = newsArray[indexPath.row]
        
        if let id = news.featuredMedia {
            if let url = news.featuredMediaURL {
                cell.bannerImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
            } else {
                Media.get(id: id) { (response: Result<Media>) in
                    switch response {
                    case .success(let downloadedMedia):
                        
                        DispatchQueue.main.async(execute: {
                            news.featuredMediaURL = downloadedMedia.sourceUrl
                            cell.bannerImageView.sd_setImage(with: URL(string: downloadedMedia.sourceUrl!), placeholderImage: UIImage(named: "placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
                        })
                        
                    case .failure(let error):
                        print("Media error: \(error.localizedDescription)")
                        DispatchQueue.main.async(execute: {
                            cell.bannerImageView.image = UIImage(named: "placeholder")
                        })
                    }
                }
            }
        }
        cell.titleLabel.text = news.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultSearchController.dismiss(animated: true, completion: nil)
        
        let news = newsArray[indexPath.row]
        self.performSegue(withIdentifier: "segueToDetailVC", sender: news)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetailVC" {
            if let destinationVC = segue.destination as? NewsDetailViewController {
                destinationVC.news = sender as? SKNews
            }
        }
    }
    
    @IBAction func rightNavButtonClicked(_ sender: Any) {
        if WP.currentUser?.roles != nil && (WP.currentUser?.roles?.contains("administrator"))! {
            self.performSegue(withIdentifier: "segueToNewPost", sender: nil)
        } else {
            self.performSegue(withIdentifier: "segueToMemberBlog", sender: nil)
        }
    }
    
}
