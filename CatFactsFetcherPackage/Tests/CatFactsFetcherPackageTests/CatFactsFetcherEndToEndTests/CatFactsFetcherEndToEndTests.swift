//
//  CatFactsFetcherEndToEndTests.swift
//  CatFactsFetcherEndToEndTests
//
//  Created by Lev Litvak on 18.08.2022.
//

import XCTest
import CatFactsFetcher

class CatFactsFetcherEndToEndTests: XCTestCase {

    func test_fetch_deliversNonEmptyFact() {
        let client = URLSessionHTTPClient()
        let sut = CatFactsNinjaFetcher(client: client)
        
        let exp = expectation(description: "Waiting for fetching")
        
        sut.fetch { result in
            switch result {
            case let .success(fact):
                XCTAssertFalse(fact.text.isEmpty, "Expected to fetch non empty fact, got empty instead")
            case .failure:
                XCTFail("Expected success result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 15.0)
    }

}
