#include <IOKit/hidsystem/IOHIDEventSystemClient.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

// Declarations from other IOKit source code

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
int IOHIDEventSystemClientSetMatchingMultiple(IOHIDEventSystemClientRef client, CFArrayRef match);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t , int32_t, int64_t);
CFStringRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service, CFStringRef property);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

CFDictionaryRef matching(int page, int usage)
{
    CFNumberRef nums[2];
    CFStringRef keys[2];
    
    keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
    keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
    nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
    nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);
    
    CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return dict;
}

CFArrayRef getProductNames(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);
    
    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        CFStringRef name = IOHIDServiceClientCopyProperty(sc, CFSTR("Product"));
        if (name) {
            CFArrayAppendValue(array, name);
        } else {
            CFArrayAppendValue(array, @"noname");
        }
    }
    return array;
}

// from IOHIDFamily/IOHIDEventTypes.h
// e.g., https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-701.60.2/IOHIDFamily/IOHIDEventTypes.h.auto.html


#define IOHIDEventFieldBase(type)   (type << 16)
#define kIOHIDEventTypeTemperature  15
#define kIOHIDEventTypePower        25

CFArrayRef getPowerValues(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);
    
    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        IOHIDEventRef event = IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypePower, 0, 0);
        
        CFNumberRef value;
        if (event != 0) {
            double temp = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kIOHIDEventTypePower));
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        } else {
            double temp = 0;
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        }
        CFArrayAppendValue(array, value);
    }
    return array;
}

CFArrayRef getThermalValues(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);
    
    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        IOHIDEventRef event = IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypeTemperature, 0, 0);
        
        CFNumberRef value;
        if (event != 0) {
            double temp = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kIOHIDEventTypeTemperature));
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        } else {
            double temp = 0;
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        }
        CFArrayAppendValue(array, value);
    }
    return array;
}

void dumpValues(CFArrayRef values)
{
    long count = CFArrayGetCount(values);
    for (int i = 0; i < count; i++) {
        CFNumberRef value = CFArrayGetValueAtIndex(values, i);
        double temp = 0.0;
        CFNumberGetValue(value, kCFNumberDoubleType, &temp);
        // NSLog(@"value = %lf\n", temp);
        printf(", %lf", temp);
    }
}

void dumpNames(CFArrayRef names, char *cat)
{
    long count = CFArrayGetCount(names);
    for (int i = 0; i < count; i++) {
        NSString *name = (NSString *)CFArrayGetValueAtIndex(names, i);
        // NSLog(@"value = %lf\n", temp);
        printf(", %s (%s)", [name UTF8String], cat);
    }
}

NSArray* currentArray(void) {
    CFDictionaryRef currentSensors = matching(0xff08, 2);
    return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray* voltageArray(void) {
    CFDictionaryRef currentSensors = matching(0xff08, 3);
    return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray* thermalArray(void) {
    CFDictionaryRef currentSensors = matching(0xff00, 5);
    return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray* returnCurrentValues(void) {
    CFDictionaryRef currentSensors = matching(0xff08, 2);
    return CFBridgingRelease(getPowerValues(currentSensors));
}

NSArray* returnVoltageValues(void) {
    CFDictionaryRef voltageSensors = matching(0xff08, 3);
    return CFBridgingRelease(getPowerValues(voltageSensors));
}

NSArray* returnThermalValues(void) {
    CFDictionaryRef currentSensors = matching(0xff00, 5);
    return CFBridgingRelease(getThermalValues(currentSensors));
}


extern uint64_t my_mhz(void);
extern void mybat(void);

#if 0
int main () {
    //  Primary Usage Page:
    //    kHIDPage_AppleVendor                        = 0xff00,
    //    kHIDPage_AppleVendorTemperatureSensor       = 0xff05,
    //    kHIDPage_AppleVendorPowerSensor             = 0xff08,
    //
    //  Primary Usage:
    //    kHIDUsage_AppleVendor_TemperatureSensor     = 0x0005,
    //    kHIDUsage_AppleVendorPowerSensor_Current    = 0x0002,
    //    kHIDUsage_AppleVendorPowerSensor_Voltage    = 0x0003,
    // See IOHIDFamily/AppleHIDUsageTables.h for more information
    // https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-701.60.2/IOHIDFamily/AppleHIDUsageTables.h.auto.html
    
    CFDictionaryRef currentSensors = matching(0xff08, 2);
    CFDictionaryRef voltageSensors = matching(0xff08, 3);
    CFDictionaryRef thermalSensors = matching(0xff05, 5);
    
    CFArrayRef currentNames = getProductNames(system, currentSensors);
    CFArrayRef voltageNames = getProductNames(system, voltageSensors);
    CFArrayRef thermalNames = getProductNames(system, thermalSensors);
    
    
    printf("freq, v_bat, a_bat, temp_bat");
    dumpNames(voltageNames, "V");
    dumpNames(currentNames, "A");
    dumpNames(thermalNames, "degree C");
    printf("\n");
    
    while (1) {
        CFArrayRef currentValues = getPowerValues(system, currentSensors);
        CFArrayRef voltageValues = getPowerValues(system, voltageSensors);
        CFArrayRef thermalValues = getThermalValues(system, thermalSensors);
        printf("%lld, ", my_mhz());
        mybat();
        
        dumpValues(voltageValues);
        dumpValues(currentValues);
        dumpValues(thermalValues);
        printf("\n");
        usleep(900000);
        CFRelease(currentValues);
        CFRelease(voltageValues);
        CFRelease(thermalValues);
    }
    
#if 0
    NSLog(@"%@\n", CFArrayGetValueAtIndex(currentNames, 0));
    NSLog(@"%@\n", CFArrayGetValueAtIndex(currentNames, 1));
    NSLog(@"%@\n", CFArrayGetValueAtIndex(voltageNames, 0));
    NSLog(@"%@\n", CFArrayGetValueAtIndex(voltageNames, 1));
    NSLog(@"%@\n", CFArrayGetValueAtIndex(thermalNames, 0));
    NSLog(@"%@\n", CFArrayGetValueAtIndex(thermalNames, 1));
#endif
    
    // IOHIDEventRef event = IOHIDServiceClientCopyEvent(alssc, 25, 0, 0);
    
    return 0;
}
#endif
