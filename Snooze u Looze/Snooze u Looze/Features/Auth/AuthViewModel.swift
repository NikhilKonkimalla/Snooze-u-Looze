//
//  AuthViewModel.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        supabaseService.$currentUser
            .map { $0 != nil }
            .assign(to: &$isAuthenticated)
    }
    
    func signIn() async {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabaseService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func validate() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
}



