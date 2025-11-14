import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    
    func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.signIn(email: email, password: password)
            print("Sign in successful")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign in failed: \(error)")
        }
        
        isLoading = false
    }
    
    func signUp() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseService.signUp(email: email, password: password)
            print("Sign up successful")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign up failed: \(error)")
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabaseService.signOut()
            print("Sign out successful")
        } catch {
            print("Sign out failed: \(error)")
        }
    }
}

