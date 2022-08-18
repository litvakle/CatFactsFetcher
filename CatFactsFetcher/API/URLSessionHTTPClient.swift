//
//  URLSessionHTTPClient.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public init() {}
    
    public func fetch(from url: URL, _ completion: @escaping (HTTPClient.Result) -> Void) {
        URLSession.shared.dataTask(with: url) { _, _, _ in
            
        }
        .resume()
    }
}
