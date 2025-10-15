//
//  SupabaseService.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    @Published var currentUser: User?
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Constants.supabaseURL)!,
            supabaseKey: Constants.supabaseAnonKey
        )
        
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Authentication
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.currentUser = session.user
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        await MainActor.run {
            self.currentUser = response.user
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        await MainActor.run {
            self.currentUser = response.user
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
        }
    }
    
    // MARK: - Alarms CRUD
    
    func fetchAlarms() async throws -> [Alarm] {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "SupabaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let response: [Alarm] = try await client
            .from("alarms")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        return response
    }
    
    func createAlarm(_ alarm: Alarm) async throws -> Alarm {
        print("💾 Creating alarm in Supabase: \(alarm.id)")
        do {
            let response: Alarm = try await client
                .from("alarms")
                .insert(alarm)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ Alarm created successfully in Supabase")
            return response
        } catch {
            print("❌ Failed to create alarm in Supabase: \(error)")
            throw error
        }
    }
    
    func updateAlarm(_ alarm: Alarm) async throws {
        try await client
            .from("alarms")
            .update(alarm)
            .eq("id", value: alarm.id.uuidString)
            .execute()
    }
    
    func deleteAlarm(id: UUID) async throws {
        try await client
            .from("alarms")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

