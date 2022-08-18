//
//  CatFactsFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

public protocol CatFactsFetcher {
    typealias Result = Swift.Result<CatFact, Error>
    func fetch(_ completion: @escaping((Result) -> Void))
}
