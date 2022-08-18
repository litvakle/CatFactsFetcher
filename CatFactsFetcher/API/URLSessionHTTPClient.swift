//
//  URLSessionHTTPClient.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public init() {}
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func fetch(from url: URL, _ completion: @escaping (HTTPClient.Result) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        .resume()
    }
}
