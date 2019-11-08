//
//  main.swift
//  Unobfuscate
//
//  Created by Philip Mcmahon on 11/8/19.
//  Copyright © 2019 Philip Mcmahon. All rights reserved.
//

import Foundation

let Header = "!VCSK"

public extension Data {
    func header() -> String? {
        let bytes = self.bytes(count: Header.count)
        return String(bytes: bytes, encoding: .utf8)
    }
    
    func bytes(count: Int) -> Data {
        let array = [UInt8](self)
        return Data(bytes: array, count: count)
    }
    
    func key(position: Int) -> UInt8 {
        let pair: (UInt8, UInt8) = (self[position], self[position + 1])
        return unhex(pair.0) << 4 | unhex(pair.1)
    }
    
    func read(position: Int, key: UInt8) -> UInt8 {
        let pair: (UInt8, UInt8) = (self[position], self[position + 1])
        return (((unhex(pair.0) << 4) | unhex(pair.1)) ^ key) & 0xFF;
    }
    
    func unhex(_ i: UInt8) -> UInt8 {
        switch (i) {
        // digits 0-9
        case 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39:
            return i - 0x30;
        // digits A-F
        case 0x41, 0x42, 0x43, 0x44, 0x45, 0x46:
            return i - 0x37;
        // digits a-f
        case 0x61, 0x62, 0x63, 0x64, 0x65, 0x66:
            return i - 0x57;
        default:
            assert(false)
            return 0
        }
    }
    
    func deObfuscate() -> String? {
        
        guard let header = self.header(), header == Header else {
            return nil
        }
        
        let key = self.key(position: Header.count)
        var decoded = [UInt8]()
        var position = Header.count + 2
        let size = self.count - position / 2
        
        while position < size {
        let a = self.read(position: position, key: key)
            decoded.append(a)
            position += 2
        }
        
        return String(bytes: decoded, encoding: .utf8)
    }
}

let args = CommandLine.arguments

if args.count == 2 {
    let url = URL(fileURLWithPath: args[1])
    do {
        let data = try Data(contentsOf: url)
        
        if let result = data.deObfuscate() {
            print(result)
        }
        else {
            print("error: Failed to decode file")
        }
    }
        
    catch (let error) {
        print("error: \(error.localizedDescription)")
    }
}
else {
    let url = URL(fileURLWithPath: args[0])
    print("usage: \(url.lastPathComponent) savedFile")
}
