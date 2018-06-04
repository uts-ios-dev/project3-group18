//
//  CategoryViewController.swift
//  iOS-Ass3
//
//  Created by SongXujie on 4/6/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import UIKit
import WPAPI
import SVProgressHUD
import SDWebImage

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
//    let refreshControl = UIRefreshControl()
    var resultSearchController = UISearchController()
    
    var categoriesArray: [SKCategory] = []
    var searchString: String?
    var currentPage = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        refreshControl.tintColor = UIColor.gray
//        refreshControl.addTarget(self, action: #selector(reloadCategories), for: UIControlEvents.valueChanged)
//        tableView.addSubview(refreshControl)
        
        reloadCategories()
        
        // set up searchbar
        self.resultSearchController = UISearchController(searchResultsController:nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.placeholder = "Search..."
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        resultSearchController.searchBar.delegate = self
        
    }
    
    @objc func reloadCategories() {
        // Reset Search
        self.searchString = nil
        // Reset currentPage to 1
        self.currentPage = 1
        // Reset adsArray to empty
        self.categoriesArray = []
        // Download Categories again
        downloadCategories()
    }
    
    func loadMoreCategories() {
        // Increase currentPage by 1
        self.currentPage += 1
        // Download Categories again
        downloadCategories()
    }
    
    func downloadCategories() {
        
        // End Pull to refresh & begin loading
//        self.refreshControl.endRefreshing()
        SVProgressHUD.show(withStatus: "Loading Categories...")
        
        let sampleCategories = [
            4444,
            2226,
            4441,
            1
        ]
        
        SKCategory.list(page: self.currentPage,
                        perPage: AppDelegate.PER_PAGE,
                        search: self.searchString,
                        include: sampleCategories) { (response: Result<[SKCategory]>) in
            switch response {
            case .success(let downloadedCategories):
                
                DispatchQueue.main.async(execute: {
                    self.categoriesArray += downloadedCategories
                    self.tableView.reloadData()
                })
                
                SVProgressHUD.dismiss()
            case .failure( _):
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Oops", message: "Error Loading Categories...", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
                        self.downloadCategories()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in
                        self.categoriesArray = []
                        self.searchString = nil
                        self.currentPage = 1
                        self.downloadCategories()
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    SVProgressHUD.dismiss()
                    
                })
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Reset Values
        self.categoriesArray = []
        self.currentPage = 1
        
        // Perform Search
        downloadCategories()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // Reset Search
        self.searchString = nil
        
        // Reset Values
        self.categoriesArray = []
        self.currentPage = 1
        
        // Perform Search
        downloadCategories()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Update Search
        self.searchString = resultSearchController.searchBar.text!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! BannerTableViewCell
        
        let category = categoriesArray[indexPath.row]
        let categoryImageName = String(category.id!)
        
        cell.bannerImageView.image = UIImage(named: categoryImageName)
        cell.titleLabel.text = category.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultSearchController.dismiss(animated: true, completion: nil)
        
        let category = categoriesArray[indexPath.row]
        self.performSegue(withIdentifier: "segueToNewsVC", sender: category)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNewsVC" {
            if let destinationVC = segue.destination as? NewsViewController {
                destinationVC.category = sender as? SKCategory
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
