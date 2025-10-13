//
//  AlarmListView.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

struct AlarmListView: View {
    @StateObject private var viewModel = AlarmViewModel.shared
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showAddAlarm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.alarms.isEmpty {
                        emptyState
                    } else {
                        alarmsList
                    }
                }
            }
            .navigationTitle("My Alarms")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task { await authViewModel.signOut() }
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddAlarm = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddAlarm) {
                AddAlarmView()
            }
            .task {
                await viewModel.fetchAlarms()
            }
            .refreshable {
                await viewModel.fetchAlarms()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "alarm")
                .font(.system(size: 80))
                .foregroundColor(.textSecondary)
            
            Text("No Alarms Set")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Tap the + button to create your first alarm")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var alarmsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.alarms) { alarm in
                    AlarmCard(
                        alarm: alarm,
                        onToggle: {
                            Task {
                                await viewModel.toggleAlarm(alarm)
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteAlarm(alarm)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    AlarmListView()
}

