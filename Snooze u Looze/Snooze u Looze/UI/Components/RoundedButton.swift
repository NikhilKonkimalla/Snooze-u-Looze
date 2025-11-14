import SwiftUI

struct RoundedButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing)
                .background(backgroundColor)
                .cornerRadius(AppTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .accentPrimary
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? .accentPrimary : .gray
        case .secondary:
            return .clear
        case .destructive:
            return isEnabled ? .red : .gray
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return .clear
        case .secondary:
            return .accentPrimary
        case .destructive:
            return .clear
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        RoundedButton(title: "Primary Button") { }
        
        RoundedButton(title: "Secondary Button", action: { }, style: .secondary)
        
        RoundedButton(title: "Destructive Button", action: { }, style: .destructive)
        
        RoundedButton(title: "Disabled Button", action: { }, isEnabled: false)
    }
    .padding()
    .preferredColorScheme(.dark)
}
