//
//  BridgeLibUSB.h
//  SwiftUSB
//
//  Created by Kevin Coble on 7/17/21.
//

#ifndef BridgeLibUSB_h
#define BridgeLibUSB_h

#import <Foundation/Foundation.h>

@interface USBDeviceHandle : NSObject

@property void *dev_handle;

- (id)initWithDevHandle:(void *)handle;
- (void)dealloc;

@end

@interface USBDeviceInfo : NSObject
 
@property int16_t vendorID;
@property int16_t productID;
@property NSString *manufacturer;
@property NSString *product;
@property NSString *serialNumber;

- (id)initWithVendorID:(int16_t)vendor ProductID:(int16_t)product;
 
@end

@interface BridgeLibUSB : NSObject

//  Wrapped libUSB functions
+ (int)libusb_init;
+ (int)libusb_get_device_list:(NSMutableArray *)devices;
+ (USBDeviceHandle *)libusb_open_device_with_vid:(int16_t)vendor _pid:(int16_t)product;
+ (int)libusb_bulk_transfer:(USBDeviceHandle *)device to:(unsigned char)endpoint withData:(unsigned char *)data ofLength:(int)length actualLength:(int *)actual timeout:(unsigned int)timeout;

//  Other functions used for SwiftUSB operations
+ (USBDeviceInfo *)getDeviceInfo:(USBDeviceHandle *)device;

@end

#endif /* BridgeLibUSB_h */
