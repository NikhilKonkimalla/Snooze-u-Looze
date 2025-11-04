//
//  LoginView.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isSignUpMode = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacing) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentPrimary)
                    
                    Text("Snooze u Looze")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Wake up with purpose")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, 40)
                
                // Input Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Action Button
                RoundedButton(
                    title: isSignUpMode ? "Sign Up" : "Sign In",
                    action: {
                        Task {
                            if isSignUpMode {
                                await viewModel.signUp()
                            } else {
                                await viewModel.signIn()
                            }
                        }
                    },
                    isEnabled: !viewModel.isLoading
                )
                .padding(.top, 8)
                
                // Toggle Mode
                Button(action: {
                    isSignUpMode.toggle()
                    viewModel.errorMessage = nil
                }) {
                    Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(.accentPrimary)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.cardPadding)
            
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentPrimary)
            }
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .foregroundColor(.textPrimary)
    }
}

#Preview {
    LoginView()
}









