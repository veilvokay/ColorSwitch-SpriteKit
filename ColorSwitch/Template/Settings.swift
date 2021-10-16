//
//  Settings.swift
//  ColorSwitch
//
//  Created by Roman Yakovliev on 14.10.2021.
//

import SpriteKit

// Physics Categories in Swift are always declared as UInt32
enum PhysicsCategories {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1 // 1
    static let switchCategory: UInt32 = 0x1 << 1 // bitwise shift operator <-- number is going to be 10
}


enum ZPositions {
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}
