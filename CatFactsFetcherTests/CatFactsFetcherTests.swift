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
        
        sut.fetch() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_fetch_deliversErrorOnClientError() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://any-url.com")!
        let sut = CatFactsNinjaFetcher(client: client, url: url)
        
        let expectedError = NSError(domain: "any error", code: 1)
        let exp = expectation(description: "Waiting for fetch completion")
        sut.fetch { result in
            switch result {
            case .success:
                XCTFail("Expected filure, received \(result) instead)")
            case let .failure(error as NSError):
                XCTAssertEqual(error.code, expectedError.code)
                XCTAssertEqual(error.domain, expectedError.domain)
            }
            exp.fulfill()
        }
        
        client.complete(withError: expectedError)
        
        wait(for: [exp], timeout: 1.0)
    }
}

private class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    var completions = [(HTTPClient.Result) -> Void]()
    
    func fetch(from url: URL, _ completion: @escaping (HTTPClient.Result) -> Void) {
        requestedURLs.append(url)
        completions.append(completion)
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}
