import SwiftUI
import Foundation

struct AddAlarmView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = AlarmViewModel.shared
    
    @State private var selectedTime = Date()
    @State private var selectedTask: AlarmTask = .brushingTeeth
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacing) {
                    // Time Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alarm Time")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        DatePicker(
                            "",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                    }
                    .padding()
                    .roundedCard()
                    
                    // Task Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Task to Complete")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        ForEach(AlarmTask.allCases, id: \.self) { task in
                            TaskOptionButton(
                                task: task,
                                isSelected: selectedTask == task,
                                action: {
                                    selectedTask = task
                                }
                            )
                        }
                    }
                    .padding()
                    .roundedCard()
                    
                    Spacer()
                    
                    // Create Button
                    RoundedButton(
                        title: "Create Alarm",
                        action: {
                            Task {
                                await viewModel.createAlarm(time: selectedTime, task: selectedTask)
                                dismiss()
                            }
                        }
                    )
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct TaskOptionButton: View {
    let task: AlarmTask
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: task.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .accentPrimary)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.15))
                    .cornerRadius(10)
                
                Text(task.displayName)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding()
            .background(isSelected ? Color.accentPrimary.opacity(0.1) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    AddAlarmView()
}

