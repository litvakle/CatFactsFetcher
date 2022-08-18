//
//  CatFactsNinjaFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

/// A service for fetching random facts about cats using free 'Ninja' API https://catfact.ninja
/// The service uses default URL or required URL can be passed as a parameter to init()
public final class CatFactsNinjaFetcher: CatFactsFetcher {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = CatFactsFetcher.Result
    
    private let defaultURL = URL(string: "https://catfact.ninja/fact")!
    
    public init(client: HTTPClient, url: URL? = nil) {
        self.client = client
        self.url = url ?? defaultURL
    }
    
    public func fetch(_ completion: @escaping((Result) -> Void)) {
        client.fetch(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                completion(self.map(from: data, with: response))
            case .failure:
                completion(.failure(Error.connectivity))
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
