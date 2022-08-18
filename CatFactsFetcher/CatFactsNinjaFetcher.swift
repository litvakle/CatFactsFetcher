//
//  CatFactsNinjaFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<Data, Error>
    
    func fetch(from url: URL, _ completion: @escaping (Result) -> Void)
}

public final class CatFactsNinjaFetcher {
    let client: HTTPClient
    let url: URL
    
    public typealias Result = Swift.Result<Data, Error>
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func fetch(_ completion: @escaping((Result) -> Void)) {
        client.fetch(from: url) { result in
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        }
    }
}
