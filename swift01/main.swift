//
//  main.swift
//  swift01
//
//  Created by Jimmy on 2021/9/22.
//

import Foundation

func sysmetrics(_ page: Int, _ usage: Int, _ attr: Int32) -> Dictionary<NSString, NSNumber> {
    var ret = Dictionary<NSString, NSNumber>.init()
    let dic = [
        "PrimaryUsagePage" as CFString: page as CFNumber,
        "PrimaryUsage" as CFString: usage as CFNumber
    ] as CFDictionary

    let iosc = IOHIDEventSystemClientCreate(kCFAllocatorDefault).takeRetainedValue()
    IOHIDEventSystemClientSetMatching(iosc, dic)
    let matchingsrvs = IOHIDEventSystemClientCopyServices(iosc)

    for i in 0...CFArrayGetCount(matchingsrvs)-1 {
        let sc = unsafeBitCast(CFArrayGetValueAtIndex(matchingsrvs, i), to: IOHIDServiceClientRef.self
        )
        let label = IOHIDServiceClientCopyProperty(sc, "Product" as CFString)
        let val = IOHIDServiceClientCopyEvent(sc, Int64(attr), 0, 0)
            
        if label == nil || val == nil {
            continue
        }
         
        let tmp = IOHIDEventGetFloatValue(val, (attr<<16))

        ret[label!.takeRetainedValue() as CFString as NSString] = NSNumber.init(value: tmp)
    }
    return ret
}

// thermal
for item in sysmetrics(0xff00, 5, kIOHIDEventTypeTemperature) {
    print(item.key, "|", item.value)
}
// current
for item in sysmetrics(0xff08, 2, kIOHIDEventTypePower) {
    print(item.key, "|", item.value)
}
// voltage
for item in sysmetrics(0xff08, 3, kIOHIDEventTypePower) {
    print(item.key, "|", item.value)
}

