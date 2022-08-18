//
//  CatFactsMapper.swift
//  CatFactsFetcher
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

final class CatFactsMapper {
    static var OK_200: Int { return 200 }
    
    static func map(from data: Data, with response: HTTPURLResponse) throws -> ApiFact {
        guard response.statusCode == OK_200,
              let decoded = try? JSONDecoder().decode(ApiFact.self, from: data) else {
            throw CatFactsNinjaFetcher.FetchError.invalidData
        }
        
        return decoded
    }
}
