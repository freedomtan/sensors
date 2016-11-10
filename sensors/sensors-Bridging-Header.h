//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hidsystem/IOHIDEventSystemClient.h>

extern CFDictionaryRef matching(int page, int usage);
extern IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);

extern NSArray* currentArray();
extern NSArray* voltageArray();
extern NSArray* thermalArray();

extern NSArray* returnCurrentValues();
extern NSArray* returnVoltageValues();
extern NSArray* returnThermalValues();
