//
//  UnsplashImages.swift
//  MVCacheIt
//
//  Created by Prashant Pandey on 03/08/18.
//  Copyright © 2018 Prashant Pandey. All rights reserved.
//
import Foundation

typealias Photos = [Photo]

struct Photo: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let raw: URL
    let full: URL
    let regular: URL
    let small: URL
    let thumb: URL
}
