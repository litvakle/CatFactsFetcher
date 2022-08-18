//
//  CatFactsFetcherTests.swift
//  CatFactsFetcherTests
//
//  Created by Lev Litvak on 18.08.2022.
//

import XCTest
import Foundation
import CatFactsFetcher

class CatFactsFetcherTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_fetch_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://any-url.com")!
        let sut = CatFactsNinjaFetcher(client: client, url: url)
        
        sut.fetch()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
}

private class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    
    func fetch(from url: URL) {
        requestedURLs.append(url)
    }
}
