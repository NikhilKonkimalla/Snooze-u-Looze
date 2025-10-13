//
//  Task.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation

enum AlarmTask: String, Codable, CaseIterable {
    case brushingTeeth = "brushing_teeth"
    case openingLaptop = "opening_laptop"
    
    var displayName: String {
        switch self {
        case .brushingTeeth:
            return "Brushing Teeth"
        case .openingLaptop:
            return "Opening Laptop"
        }
    }
    
    var icon: String {
        switch self {
        case .brushingTeeth:
            return "sparkles"
        case .openingLaptop:
            return "laptopcomputer"
        }
    }
    
    var verificationObjects: [String] {
        switch self {
        case .brushingTeeth:
            return ["toothbrush", "brush", "bathroom"]
        case .openingLaptop:
            return ["laptop", "computer", "notebook computer", "portable computer"]
        }
    }
}

