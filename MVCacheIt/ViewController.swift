//
//  ViewController.swift
//  MVCacheIt
//
//  Created by Prashant Pandey on 02/08/18.
//  Copyright © 2018 Prashant Pandey. All rights reserved.
//

import UIKit
import Foundation
import CacheAnything


class ViewController: UIViewController, MVURLObserverProtocol {
    
    // MARK: Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    let viewModel = ViewModel(client: PasteBinClient())
    var resourceManager: MVResourceManager!
    let identifierName = "viewControllerIdentifier"
    lazy var photos: NSDictionary = NSDictionary()
    lazy var loadedPhotos: NSMutableDictionary = NSMutableDictionary()
    
    lazy var arrKeys: Array = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Init view model
        viewModel.showLoading = {
            if self.viewModel.isLoading {
                self.activityIndicator.startAnimating()
                self.collectionView.alpha = 0.0
            } else {
                
                self.activityIndicator.stopAnimating()
                self.collectionView.alpha = 1.0
            }
        }
        
        viewModel.showError = { error in
            print(error)
        }
        

        viewModel.reloadData = {
            self.photos = self.viewModel.pinterestPhotos
            self.arrKeys = self.photos.allKeys as! Array<String>
            self.collectionView.reloadData()
        }
       
        viewModel.fetchPhotos()
        resourceManager = MVResourceManager.init(configuration: nil)

    }
    
    
    func didFetchURLData(_ urlString: String, data: Data?, errorMessage: String) {

        
        
        var image : UIImage?
        if let imageData = data {
            image = UIImage(data:imageData)
        }
        else {
            image = #imageLiteral(resourceName: "pinterest")
        }
        DispatchQueue.main.async {
            if self.loadedPhotos[urlString] == nil {
                self.loadedPhotos.setValue(image, forKey: urlString)
            }
        }
        
        let array = photos.allValues as NSArray
        let index = array.index(of: urlString)
        let indexPath = IndexPath.init(row: index, section: 0)

        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell {
                if let fillImage = image {
                    cell.imageViewFeed?.image = fillImage
                }
            }
        }
        
       
    }
}

// MARK: - Flow layout delegate

extension ViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if let val = self.loadedPhotos[self.photos.value(forKey: arrKeys[indexPath.row])!] as? UIImage {
            let height = val.size.height
            return height
        }
        else {
            return 200
        }
    }
}

// MARK: Data source

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let rowKey = self.arrKeys[indexPath.row]
        let url = (photos.value(forKey: rowKey) as? String)!
        
        if let val = self.loadedPhotos[url] {
            cell.imageViewFeed.image = val as? UIImage
            self.resourceManager.cancelDataFor(url, withIdentifier: identifierName)
        }
        else {
            self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
        }
        
        return cell
    }

}

extension ViewController
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
        if let pathsArray = self.collectionView?.indexPathsForVisibleItems {
            for indexpath in pathsArray {
                let rowKey = self.arrKeys[indexpath.row]
                let url = (photos.value(forKey: rowKey) as? String)!
                self.resourceManager.getDataFor(url, withIdentifier: identifierName, withUrlObserver: self)
            }
        }
        
    }
}

