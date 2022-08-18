//
//  CatFactsNinjaFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func fetch(from url: URL, _ completion: @escaping (Result) -> Void)
}

public final class CatFactsNinjaFetcher {
    let client: HTTPClient
    let url: URL
    
    public typealias Result = Swift.Result<CatFact, Error>

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func fetch(_ completion: @escaping((Result) -> Void)) {
        client.fetch(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    completion(.failure(.invalidData))
                    return
                }
                
                guard let decoded = try? JSONDecoder().decode(ApiFact.self, from: data) else {
                    completion(.failure(.invalidData))
                    return
                }
                    
                completion(.success(decoded.toModel()))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct ApiFact: Decodable {
    let fact: String
    let length: Int
    
    func toModel() -> CatFact {
        return CatFact(text: fact)
    }
}
