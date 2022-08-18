//
//  CatFactsFetcherTests.swift
//  CatFactsFetcherTests
//
//  Created by Lev Litvak on 18.08.2022.
//

import XCTest
import Foundation

class CatFactsFetcherTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
}

private class HTTPClientSpy {
    var requestedURLs = [URL]()
}
