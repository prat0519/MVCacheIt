//
//  PasteBinClient.swift
//  MVCacheIt
//
//  Created by Prashant Pandey on 03/08/18.
//  Copyright © 2018 Prashant Pandey. All rights reserved.
//

import Foundation

class PasteBinClient: APIClient {
    static let baseUrl = "https://pastebin.com/raw/wgkJgazE"

    func fetch(completion: @escaping (Either<Photos>) -> Void) {
        let request = URLRequest(url: URL(string: PasteBinClient.baseUrl)!)
        get(with: request, completion: completion)
    }
}
