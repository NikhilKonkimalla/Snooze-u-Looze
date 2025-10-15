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
    @State private var alarmToEdit: Alarm?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack {
                    // Show error message if present
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    // Show notification permission warning
                    if !NotificationService.shared.isAuthorized {
                        VStack(spacing: 8) {
                            Text("⚠️ Notifications Disabled")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("Alarms won't ring without notification permissions")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Enable Notifications") {
                                Task {
                                    try? await NotificationService.shared.requestAuthorization()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.accentPrimary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
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
            .sheet(item: $alarmToEdit) { alarm in
                EditAlarmView(alarm: alarm)
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
                        },
                        onEdit: {
                            alarmToEdit = alarm
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

