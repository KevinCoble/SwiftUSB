//
//  SwiftUSB.swift
//  SwiftUSB
//
//  Created by Kevin Coble on 7/17/21.
//

import Foundation

///  The type of USB request being made
public enum USBRequestType: UInt8 {
    ///  Standard request - common to all devices
    case Standard = 0x00
    ///  Class request - common to classes of drivers
    case Class    = 0x20
    ///  Vendor specific request - implemented by a particular device
    case Vendor   = 0x40
    ///  Reserved - do not use
    case Reserved = 0x60
}

///  The recipient for a data transfer
public enum USBRequestRecipient: UInt8 {
    ///  The request is for the device
    case Device    = 0x00
    ///  The request is for a specified interface
    case Interface = 0x01
    ///  The request is for a specified endpoint
    case Endpoint  = 0x02
    ///  The request is for some other recipient
    case Other     = 0x03
}

///  Structure returned when information about a device is requested
public struct SwiftUSBDeviceInfo {
    ///  The vendor ID of the device
    public let vendorID : Int16
    ///  The product ID of the device
    public let productID : Int16
    ///  The manufacturer string from the device, if available
    public let manufacturer : String?
    ///  The product string from the device, if available
    public let product : String?
    ///  The serial number string from the device, if available
    public let serialNumber : String?

    init(fromInfo: USBDeviceInfo) {
        vendorID = fromInfo.vendorID
        productID = fromInfo.productID
        if (fromInfo.manufacturer == nil) {
            manufacturer = nil
        }
        else {
            manufacturer = fromInfo.manufacturer
        }
        if (fromInfo.product == nil) {
            product = nil
        }
        else {
            product = fromInfo.product
        }
        if (fromInfo.serialNumber == nil) {
            serialNumber = nil
        }
        else {
            serialNumber = fromInfo.serialNumber
        }
    }
}

let lib_usb_initialize: () = { BridgeLibUSB.libusb_init() }()

///  Class that represents a single USB device connection.  Also has static methods for getting the device list and opening a device connection
open class SwiftUSB {
    ///  Get a list of all connected devices
    ///
    /// - Returns: An array of  ``SwiftUSBDeviceInfo`` structures, one for each connected device
    public static func ListAllDevices() -> [SwiftUSBDeviceInfo] {
        _ = lib_usb_initialize  //  Initialize libUSB if it has not been done yet
        
        let array = NSMutableArray()
        let count = BridgeLibUSB.libusb_get_device_list(array)
        
        if (count > 0) {
            var returnArray : [SwiftUSBDeviceInfo] = []
            
            for i in 0..<count {
                let deviceInfo = array[Int(i)] as! USBDeviceInfo
                returnArray.append(SwiftUSBDeviceInfo(fromInfo: deviceInfo))
            }
            
            return returnArray
        }
        
        return []
    }
    
    ///  Open the first instance of a device with the given vendor and product IDs
    ///
    ///   - parameter vendorID: The vendor ID of the device
    ///   - parameter productID: The product ID of the device
    ///
    /// - Returns: A ``SwiftUSB`` instance with a connection to the device, or nil of the connection fails
    public static func OpenDevice(vendorID: Int16, productID: Int16) -> SwiftUSB? {
        _ = lib_usb_initialize  //  Initialize libUSB if it has not been done yet
        
        //  Attempt to open the device
        if let device = BridgeLibUSB.libusb_open_device_(with_vid: vendorID, _pid: productID) {
            return SwiftUSB(device: device)
        }
        
        return nil
    }
    
    let device : USBDeviceHandle
    
    private init(device: USBDeviceHandle) {
        self.device = device
    }
    
    ///  Returns the information for the connected device
    ///
    /// - Returns: An instance of  ``SwiftUSBDeviceInfo`` structure for the connected device, or nil if the operation fails
    open func GetDeviceInfo() -> SwiftUSBDeviceInfo? {
        if let deviceInfo = BridgeLibUSB.getDeviceInfo(device) {
            return SwiftUSBDeviceInfo(fromInfo: deviceInfo)
        }
        return nil
    }
    
    ///  Sends a set of bytes to the specified recipient as a bulk data transfer
    ///
    ///   - parameter to: The intended recipient of the data
    ///   - parameter data: A Data object with the bytes to be sent
    open func SendBulkData(to: USBRequestRecipient, data: Data) {
        //  Create the endpoint
        let endpoint : UInt8 = to.rawValue  //  Assume standard request type, host to device (both zeros)
        
        //  Get the data as a byte array
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        data.copyBytes(to: ptr, count: data.count)
        
        //  Call the libusb bulk transfer function
        let length = Int32(data.count)
        var actualBytesSent : Int32 = 0
        let _ = BridgeLibUSB.libusb_bulk_transfer(device, to: endpoint, withData: ptr, ofLength: length, actualLength: &actualBytesSent, timeout: 5)
        
        //  Deallocate the contiguious memory
        ptr.deallocate()
    }
    
    ///  Read a bulk data packet from the specified recipient
    ///
    ///   - parameter from: The source of the data
    ///   - parameter maxLength: The maximum number of bytes expected from the device
    ///   - parameter timeout:  The timout for the read, in milliseconds
    /// - Returns: A Data object with the read bytes, or nil of the read fails or times out
    open func GetBulkData(from: USBRequestRecipient, maxLength : Int, timeout : Int = 5) -> Data? {
        //  Create the endpoint
        let endpoint : UInt8 = from.rawValue | 0x80  //  Assume standard request type (zero), device to host (0x80)
        
        //  Allocate room for the data
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: maxLength)
        
        //  Call the libusb bulk transfer function
        let length = Int32(maxLength)
        var actualBytesRead : Int32 = 0
        let _ = BridgeLibUSB.libusb_bulk_transfer(device, to: endpoint, withData: ptr, ofLength: length, actualLength: &actualBytesRead, timeout: UInt32(timeout))

        //  Put the data into a data object
        let rptr = UnsafeRawPointer(ptr)
        let data = Data(bytes: rptr, count: Int(actualBytesRead))

        //  Free the buffer
        ptr.deallocate()

        return data
    }
}
