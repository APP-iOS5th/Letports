//
//  GatheringUploadVMTests.swift
//  LetportsTests
//
//  Created by Chung Wussup on 8/13/24.
//

import XCTest
import Combine
@testable import Letports

final class GatheringUploadVMTests: XCTestCase {

    var viewModel: GatheringUploadVM!
    var cancellables: Set<AnyCancellable>!
    
    
    override func setUp() {
        super.setUp()
        viewModel = GatheringUploadVM()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testAddButtonEnableWhenAllFieldsSet() {
           // Given - 초기화
           let expectation = XCTestExpectation(description: "모든 입력 필드가 설정되어 true")
           
           // When - 설정
           viewModel.selectedImage = UIImage()
           viewModel.writeGatherInfo(content: "Info")
           viewModel.writeGatherQuestion(content: "Question")
           viewModel.writeGatehrName(content: "Test Name")
           
           // Then - 예상결과
           viewModel.$addButtonEnable
               .sink { isEnabled in
                   if isEnabled {
                       expectation.fulfill()
                   }
               }
               .store(in: &cancellables)
           
           wait(for: [expectation], timeout: 1.0)
           XCTAssertTrue(viewModel.addButtonEnable)
       }

    
    func testAddButtonDisableWhenFieldsAreNotSet() {
        // Given - 초기화
        let expectation = XCTestExpectation(description: "일부 입력 필드가 설정되지 않아 false")
        
        // When - 설정
        viewModel.selectedImage = UIImage()
        viewModel.writeGatherInfo(content: "Test Info")
        viewModel.writeGatherQuestion(content: "")
        viewModel.writeGatehrName(content: "Test Name")
        
        // Then - 예상결과
        viewModel.$addButtonEnable
            .sink { isEnabled in
                if !isEnabled {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.addButtonEnable)
    }
}
