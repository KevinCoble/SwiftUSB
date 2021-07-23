SwiftUSB is a framework for working with USB devices on a Macintosh.

The framework wraps the Darwin portion of the libusb project, which can be found at this [repository](https://github.com/libusb/libusb).  Much thanks is due to the people who made that library, as only its' existence makes this work possible.

The framework was last built using XCode 13.0 beta 2

### Features:
* Swift class for managing a USB device
* Static functions to get list of connected USB devices
* Ability to send and receive bulk data transfers from the device
* New DOCC documentation for the framework

#### Important notes
* Note:  The test functions provided in the project were made to be used against a DATAQ 2108 USB data acquisition module.  I have created a framework for interfacing to that device, which uses this framework for the USB communication.  See my [repository list](https://github.com/KevinCoble) for that code.



### Future Work
Only a subset of the libusb functions have been wrapped by this framework - generally those needed to create the interface for the DATAQ 2108 device.  All the other library functions could be wrapped given time.  If there is a libusb function you need to have ported to the Swift language, let me know and I will try to update the framework to include them.

### License
This framework uses code from the libusb project, which is distributed under the GNU Lesser General Public License v2.1.  This derivative work will therefore be bound by the same constraints as that license.

