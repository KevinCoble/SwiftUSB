//
//  BridgeLibUSB.m
//  SwiftUSB
//
//  Created by Kevin Coble on 7/17/21.
//

#import <Foundation/Foundation.h>
#import "BridgeLibUSB.h"
#import "libusb.h"

@implementation BridgeLibUSB : NSObject

+ (int)libusb_init {
    return libusb_init(NULL);
}

+ (int)libusb_get_device_list:(NSMutableArray *)devices {
    ssize_t cnt;
    libusb_device **devs;
    cnt = libusb_get_device_list(NULL, &devs);
    
    if (cnt > 0) {
        int i;
        struct libusb_device_descriptor desc;
        libusb_device_handle *handle;
        unsigned char string[256];
        for (i=0; i<cnt; i++) {
            if (libusb_get_device_descriptor(devs[i], &desc) < 0) continue;
            USBDeviceInfo *info = [[USBDeviceInfo alloc] initWithVendorID:desc.idVendor ProductID:desc.idProduct];
            libusb_open(devs[i], &handle);
            int ret;
            if (handle) {
                if (desc.iManufacturer) {
                    ret = libusb_get_string_descriptor_ascii(handle, desc.iManufacturer, string, sizeof(string));
                    if (ret > 0) info.manufacturer = [[NSString alloc] initWithUTF8String:(const char *)string];
                }

                if (desc.iProduct) {
                    ret = libusb_get_string_descriptor_ascii(handle, desc.iProduct, string, sizeof(string));
                    if (ret > 0) info.product = [[NSString alloc] initWithUTF8String:(const char *)string];
                }

                if (desc.iSerialNumber) {
                    ret = libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, string, sizeof(string));
                    if (ret > 0) info.serialNumber = [[NSString alloc] initWithUTF8String:(const char *)string];
                }
                libusb_close(handle);
            }
            [devices addObject: info];
        }
    }
    
    libusb_free_device_list(devs, 1);
    
    return (int)cnt;
}

+ (USBDeviceHandle *)libusb_open_device_with_vid:(int16_t)vendor _pid:(int16_t)product {
    libusb_device_handle *dev_handle;
    
    //  Attempt to open the device
    dev_handle = libusb_open_device_with_vid_pid(NULL, vendor, product);
    if(dev_handle == NULL) {
        return NULL;
    }

    //  Create a USBDeviceHandle, set the device handle, and return
    USBDeviceHandle *usb_device = [[USBDeviceHandle alloc] initWithDevHandle:(void *)dev_handle];
    return usb_device;
}

+ (int)libusb_bulk_transfer:(USBDeviceHandle *)device to:(unsigned char)endpoint withData:(unsigned char *)data ofLength:(int)length actualLength:(int *)actual timeout:(unsigned int)timeout {
    libusb_device_handle *dev_handle = (libusb_device_handle *)device.dev_handle;
    
    //  If the endpoint is an interface, claim it first
    if ((endpoint & 0x01) != 0) {
        libusb_claim_interface(dev_handle, 0); //claim interface 0
    }

    return libusb_bulk_transfer(dev_handle, endpoint, data, length, actual, timeout);
}

+ (USBDeviceInfo *)getDeviceInfo:(USBDeviceHandle *)device {
    libusb_device_handle *dev_handle = (libusb_device_handle *)device.dev_handle;

    //  Get the device
    libusb_device *lib_device = libusb_get_device(dev_handle);
    
    //  Get the descriptor
    struct libusb_device_descriptor desc;
    if (libusb_get_device_descriptor(lib_device, &desc) < 0) return NULL;
    
    //  Create the info structure
    USBDeviceInfo *info = [[USBDeviceInfo alloc] initWithVendorID:desc.idVendor ProductID:desc.idProduct];

    //  Get the strings
    unsigned char string[256];
    int ret;
    if (desc.iManufacturer) {
        ret = libusb_get_string_descriptor_ascii(dev_handle, desc.iManufacturer, string, sizeof(string));
        if (ret > 0) info.manufacturer = [[NSString alloc] initWithUTF8String:(const char *)string];
    }

    if (desc.iProduct) {
        ret = libusb_get_string_descriptor_ascii(dev_handle, desc.iProduct, string, sizeof(string));
        if (ret > 0) info.product = [[NSString alloc] initWithUTF8String:(const char *)string];
    }

    if (desc.iSerialNumber) {
        ret = libusb_get_string_descriptor_ascii(dev_handle, desc.iSerialNumber, string, sizeof(string));
        if (ret > 0) info.serialNumber = [[NSString alloc] initWithUTF8String:(const char *)string];
    }

    return info;
}


@end

@implementation USBDeviceInfo : NSObject
- (id)initWithVendorID:(int16_t)vendor ProductID:(int16_t)product {
    self.vendorID = vendor;
    self.productID = product;
    self.manufacturer = NULL;
    self.product = NULL;
    self.serialNumber = NULL;
    return self;
}

@end


@implementation USBDeviceHandle : NSObject

- (id)initWithDevHandle:(void *)handle {
    self.dev_handle = handle;
    
    return self;
}

- (void)dealloc {
    //  If not already closed, close the device
    if (self.dev_handle != NULL) {
        libusb_close((libusb_device_handle *)self.dev_handle);
    }
}

@end
