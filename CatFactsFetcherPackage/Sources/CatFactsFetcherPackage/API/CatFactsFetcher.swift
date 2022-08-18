//
//  CatFactsFetcher.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

/// A protocol, describing interface of services for fetching random facts about cats
public protocol CatFactsFetcher {
    typealias Result = Swift.Result<CatFact, Error>
    
    /// 
    func fetch(_ completion: @escaping((Result) -> Void))
}
