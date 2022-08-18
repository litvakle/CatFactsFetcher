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
    
    public enum FetchError: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = Swift.Result<CatFact, Error>
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func fetch(_ completion: @escaping((Result) -> Void)) {
        client.fetch(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                completion(self.map(from: data, with: response))
            case .failure:
                completion(.failure(FetchError.connectivity))
            }
        }
    }
    
    private func map(from data: Data, with response: HTTPURLResponse) -> Result {
        do {
            let fact = try CatFactsMapper.map(from: data, with: response)
            return .success(fact.toModel())
        } catch(let error) {
            return .failure(error)
        }
    }
}

struct ApiFact: Decodable {
    let fact: String
    let length: Int
    
    func toModel() -> CatFact {
        return CatFact(text: fact)
    }
}
