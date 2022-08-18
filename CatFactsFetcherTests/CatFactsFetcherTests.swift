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
        
        expect(sut, toCompleteWith: .failure(CatFactsNinjaFetcher.Error.connectivity), when: {
            client.complete(withError: anyNSError())
        })
    }
    
    func test_fetch_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: .failure(CatFactsNinjaFetcher.Error.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_fetch_deliversErrorOn200HTTPURLResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(CatFactsNinjaFetcher.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    
    func test_fetch_deliversFactOn200HTTPURLResponseWithValidData() {
        let (sut, client) = makeSUT()

        let expectedFact = makeFact(text: "Some cat fact")
        
        expect(sut, toCompleteWith: .success(expectedFact.model), when: {
            client.complete(withStatusCode: 200, data: expectedFact.data)
        })
    }
    
    func test_fetch_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: CatFactsNinjaFetcher? = CatFactsNinjaFetcher(client: client, url: anyURL())
        
        var receivedResult: CatFactsNinjaFetcher.Result?
        
        sut?.fetch { result in
            receivedResult = result
        }
        
        sut = nil
        client.complete(withError: anyNSError())
        
        XCTAssertNil(receivedResult, "Expected not to fetch result")
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: CatFactsNinjaFetcher, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = CatFactsNinjaFetcher(client: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeFact(text: String) -> (model: CatFact, data: Data) {
        let fact = CatFact(text: text)
        
        let json = [
            "fact": fact.text,
            "length": fact.text.count
        ].compactMapValues { $0 }
        
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        return (fact, data)
    }
    
    private func expect(_ sut: CatFactsNinjaFetcher, toCompleteWith expectedResult: CatFactsNinjaFetcher.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for fetch completion")
        
        sut.fetch { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFact), .success(expectedFact)):
                XCTAssertEqual(receivedFact, expectedFact, file: file, line: line)
            case let (.failure(receivedError as CatFactsNinjaFetcher.Error), .failure(expectedError as CatFactsNinjaFetcher.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
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
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        
        completions[index](.success((data, response)))
    }
}
