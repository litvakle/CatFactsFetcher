//
//  CatFactsNinjaFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public protocol HTTPClient {
    func fetch(from url: URL)
}

public final class CatFactsNinjaFetcher {
    let client: HTTPClient
    let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func fetch() {
        client.fetch(from: url)
    }
}
