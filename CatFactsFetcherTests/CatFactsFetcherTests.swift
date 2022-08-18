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
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_fetch_requestsDataFromURL() {
        let url = URL(string: "http://specific-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.fetch() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_fetch_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let expectedError = NSError(domain: "any error", code: 1)
        let exp = expectation(description: "Waiting for fetch completion")
        sut.fetch { result in
            switch result {
            case .success:
                XCTFail("Expected failure, received \(result) instead)")
            case let .failure(error):
                XCTAssertEqual(error, .connectivity)
            }
            exp.fulfill()
        }
        
        client.complete(withError: expectedError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_fetch_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { (index, code) in
            let exp = expectation(description: "Waiting for fetch completion")
            sut.fetch { result in
                switch result {
                case .success:
                    XCTFail("Expected failure, received \(result) instead)")
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError, .invalidData)
                }
                exp.fulfill()
            }
            
            client.complete(withStatusCode: code, at: index)
            
            wait(for: [exp], timeout: 1.0)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: CatFactsNinjaFetcher, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = CatFactsNinjaFetcher(client: client, url: url)
        
        return (sut, client)
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
    
    func complete(withStatusCode code: Int, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        
        completions[index](.success((Data(), response)))
    }
}
