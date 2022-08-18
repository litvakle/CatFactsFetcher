//
//  HTTPClient.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func fetch(from url: URL, _ completion: @escaping (Result) -> Void)
}
