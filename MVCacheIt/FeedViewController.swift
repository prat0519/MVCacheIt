//
//  FeedViewController.swift
//  MVCacheIt
//
//  Created by Prashant Pandey on 04/08/18.
//  Copyright © 2018 Prashant Pandey. All rights reserved.
//

import UIKit
import CacheAnything

class FeedViewController: UIViewController , MVURLObserverProtocol, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: - Properties
    
    let viewModel = ViewModel(client: PasteBinClient())
    var resourceManager: MVResourceManager!
    let identifierName = "viewControllerIdentifier"
    
    lazy var photos: NSDictionary = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Init view model
        resourceManager = MVResourceManager.init(configuration: nil)

        viewModel.showLoading = {
            if self.viewModel.isLoading {
                self.activityIndicator.startAnimating()
                self.feedTableView.alpha = 0.0
            } else {
                self.activityIndicator.stopAnimating()
                self.feedTableView.alpha = 1.0

            }
        }
        
        viewModel.showError = { error in
            print(error)
        }
        
        viewModel.reloadData = {
            self.photos = self.viewModel.pinterestPhotos
            self.feedTableView.reloadData()
        }
        viewModel.fetchPhotos()
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        
        let rowKey = photos.allKeys[indexPath.row] as! String
        let url = (photos.value(forKey: rowKey) as? String)!
        
        
        if (!tableView.isDragging && !tableView.isDecelerating) {
            self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
        }
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        indicator.startAnimating()
        
        //cell.imageViewFeed?.image = #imageLiteral(resourceName: "pinterest")
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func didFetchURLData(_ urlString: String, data: Data?, errorMessage: String) {
        
        var image : UIImage?
        if let imageData = data {
            image = UIImage(data:imageData)
        }
        
        let array = photos.allValues as NSArray
        
        let index = array.index(of: urlString)
        
        let indexPath = IndexPath.init(row: index, section: 0)
        
        DispatchQueue.main.async {
            if let cell = self.feedTableView.cellForRow(at: indexPath) {
                let indicator = cell.accessoryView as! UIActivityIndicatorView
                DispatchQueue.main.async {
                    if let fillImage = image {
                        cell.imageView?.image = fillImage
                        //self.feedTableView.reloadData()
                    }
                }
                indicator.stopAnimating()
            }
        }
    }
}


extension FeedViewController
{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        for (_, value) in self.photos {
            self.resourceManager.cancelDataFor((value as? String)!, withIdentifier: identifierName)
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
    }
    
    func loadImagesForOnscreenCells() {
        if let pathsArray = self.feedTableView.indexPathsForVisibleRows {
            for indexpath in pathsArray {
                let rowKey = photos.allKeys[indexpath.row] as! String
                let url = (photos.value(forKey: rowKey) as? String)!
                self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
            }
        }
        
    }
}
