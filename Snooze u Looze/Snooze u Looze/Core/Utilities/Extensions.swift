//
//  Extensions.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let accentPrimary = Color(red: 0.4, green: 0.6, blue: 1.0)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
}

extension View {
    func roundedCard() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(20)
    }
}









