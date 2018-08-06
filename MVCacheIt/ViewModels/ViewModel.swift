//
//  ViewModel.swift
//  MVCacheIt
//
//  Created by Prashant Pandey on 03/08/18.
//  Copyright © 2018 Prashant Pandey. All rights reserved.
//

import UIKit

class ViewModel {
    // MARK: Properties
    private let client: APIClient
    private var photos: Photos = []
    {
        didSet {
            self.fetchPhoto()
        }
    }
    
    var pinterestPhotos: NSMutableDictionary = [:]

    // MARK: UI
    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    var showLoading: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    
    init(client: APIClient) {
        self.client = client
    }
    
    func fetchPhotos() {
        if let client = client as? PasteBinClient {
            self.isLoading = true
            client.fetch() { (either) in
                switch either {
                case .success(let photos):
                    self.photos = photos
                case .error(let error):
                    self.showError?(error)
                }
            }
        }
    }
    
    private func fetchPhoto() {
        self.photos.forEach { (photo) in
            let object = photo.urls.regular.relativeString
            let name = "\(object.hashValue)"
            let url  = object
            pinterestPhotos.setValue(url, forKey: name)
            
        }
        self.isLoading = false
        self.reloadData?()
    }
}
