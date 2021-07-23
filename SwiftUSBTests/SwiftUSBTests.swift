//
//  SwiftUSBTests.swift
//  SwiftUSBTests
//
//  Created by Kevin Coble on 7/17/21.
//

import XCTest
@testable import SwiftUSB

class SwiftUSBTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetAllDevices() throws {
        let response = SwiftUSB.ListAllDevices()
        print("\(response.count) devices found")
    }

    func testGetDeviceInfo() throws {
        let device = SwiftUSB.OpenDevice(vendorID: 0x0683, productID: 0x2108)
        if let info = device?.GetDeviceInfo() {
            print("\(info.serialNumber ?? "not read")")
        }
    }
    
    func testBulkTransfer() throws {
        //  NOTE:   This test was written for use with a DATAQ 2108 USB data interface
        
        let device = SwiftUSB.OpenDevice(vendorID: 0x0683, productID: 0x2108)
        if (device == nil) { return }

        //  Get the command 'info 0\n' as a byte array
        let command = Data([0x69, 0x6E, 0x66, 0x6F, 0x20, 0x30, 0x0D])
        
        device!.SendBulkData(to: .Interface, data: command)

        if let response = device!.GetBulkData(from: .Interface, maxLength: 128) {
            let string = String(decoding: response, as: UTF8.self)
            print("response was: '\(string)'");
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
