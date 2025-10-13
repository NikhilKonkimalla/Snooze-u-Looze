//
//  RoundedButton.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI
import Foundation

struct RoundedButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isEnabled: Bool = true
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return .accentPrimary
            case .secondary:
                return .cardBackground
            case .destructive:
                return .red.opacity(0.8)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .textPrimary
            case .destructive:
                return .white
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(isEnabled ? style.backgroundColor : Color.gray.opacity(0.3))
                .cornerRadius(AppTheme.cornerRadius)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        RoundedButton(title: "Primary Button", action: {})
        RoundedButton(title: "Secondary Button", action: {}, style: .secondary)
        RoundedButton(title: "Destructive Button", action: {}, style: .destructive)
        RoundedButton(title: "Disabled Button", action: {}, isEnabled: false)
    }
    .padding()
    .background(Color.appBackground)
}

