//
//  SharedTestHelpers.swift
//  CatFactsFetcherTests
//
//  Created by Lev Litvak on 18.08.2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
