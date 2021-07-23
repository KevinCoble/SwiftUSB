# ``SwiftUSB``

SwiftUSB is a framework that wraps the 'Darwin' portion of the libusb project in a Swift interface for use in Mac and possibly iOS (only tested on Macintosh at this time) applications

## Overview

Currently the framework allows you to get a list of connected devices, connect to a device with a given vendor and product ID, get information about a device, and send and receive bulk data from the device

The ``SwiftUSB`` class has two static methods, one for getting a list of devices, and one to connect to a device.  The connection method returns back a ``SwiftUSB`` class instance.  That instance can then be used to get information about the device, or to send or receive bulk data using the provided instance methods.

The framework has code in C, Objective-C, and Swift.

For the Swift classes to use the Objective-C objects, they had to be made public.  It is not recommended that the Objective-C objects or methods be used directly.  If the class conforms to ObjectiveC.NSObjectProtocol, it is an Objective-C object.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
