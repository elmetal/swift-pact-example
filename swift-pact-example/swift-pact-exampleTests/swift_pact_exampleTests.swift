//
//  swift_pact_exampleTests.swift
//  swift-pact-exampleTests
//  
//  Created by elmetal on 2022/03/01
//  
//

import XCTest
import PactSwift
@testable import swift_pact_example

final class swift_pact_exampleTests: XCTestCase {

    static var mockService: MockService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        Self.mockService = MockService(consumer: "swift-packt-exampleApp", provider: "example-api-server")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // MARK: expectation
        Self.mockService
            .uponReceiving("A request for a list of users")
            .given(ProviderState(description: "users exist",
                                 params: ["first_name": "John", "last_name": "Tester"]))
            .withRequest(method: .GET,
                         path: "/api/users")
            .willRespondWith(status: 200,
                             headers: nil,
                             body: [
                                "page": Matcher.SomethingLike(1)
                             ])


        Self.mockService.run(timeout: 1) { mockServiceURL, done in
            Task {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "\(mockServiceURL)/api/users")!)
                let actual = try JSONDecoder().decode(ExampleResponse.self, from: data)

                XCTAssertEqual(actual.page, 1)

                done()
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

struct ExampleResponse: Decodable {
    let page: Int
}
