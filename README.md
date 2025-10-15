# Snooze u Looze

A unique alarm app that requires you to complete a task (like brushing your teeth or opening your laptop) by taking a verified photo to stop the alarm from ringing.

## Features

- ✅ Multi-user authentication with Supabase
- ⏰ Create alarms with specific wake-up tasks
- 📸 Camera-based task verification using ML
- 🔊 Continuous alarm sound until task is verified
- 🌙 Beautiful dark-mode UI with minimalist design
- 🎯 Two initial tasks: Brushing Teeth & Opening Laptop
- 🌐 Web-based password reset with automatic app redirect

## Setup Instructions

### 1. Supabase Configuration

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Project Settings > API
3. Copy your project URL and anon/public key
4. Update `Core/Utilities/Constants.swift`:
   ```swift
   static let supabaseURL = "YOUR_SUPABASE_URL"
   static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
   ```

### 2. Database Schema

Run this SQL in your Supabase SQL Editor:

```sql
-- Create alarms table
create table alarms (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  alarm_time timestamp with time zone not null,
  task text not null,
  is_active boolean default true,
  repeat_days jsonb,
  created_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table alarms enable row level security;

-- Create policy for users to access their own alarms
create policy "Users can access their own alarms"
  on alarms
  for all
  using (auth.uid() = user_id);

-- Create index for faster queries
create index alarms_user_id_idx on alarms(user_id);
create index alarms_alarm_time_idx on alarms(alarm_time);
```

### 3. Enable Authentication

1. In Supabase Dashboard, go to Authentication > Providers
2. Enable Email provider
3. Configure email templates if desired

### 4. Build & Run

1. Open `Snooze u Looze.xcodeproj` in Xcode
2. Select a target device (iOS 17.0+)
3. Build and run (⌘R)

## Project Structure

```
Snooze u Looze/
├── Core/
│   ├── Models/           # Data models (Alarm, Task)
│   ├── Services/         # Business logic services
│   │   ├── SupabaseService.swift
│   │   ├── MLVerificationService.swift
│   │   ├── NotificationService.swift
│   │   └── AlarmSoundService.swift
│   └── Utilities/        # Extensions, Constants
├── Features/
│   ├── Auth/            # Login/Signup views
│   ├── Alarms/          # Alarm management views
│   └── Camera/          # Camera & verification
├── UI/
│   ├── Components/      # Reusable UI components
│   └── Theme/          # Design system
└── web/                # Web components
    ├── password-reset.html  # Password reset page
    └── README.md           # Web documentation
```

## How It Works

1. **Sign Up/Login**: Create an account to sync your alarms
2. **Create Alarm**: Set a time and choose a task to complete
3. **Alarm Rings**: At the scheduled time, the alarm starts ringing
4. **Take Photo**: Capture a photo of yourself doing the task
5. **ML Verification**: The app uses Vision framework to verify the task
6. **Alarm Stops**: Only stops when verification succeeds!

## Web Components

The `web/` folder contains web-based components that complement the iOS app:

### Password Reset Page
- **Beautiful, responsive design** matching the iOS app theme
- **Automatic app redirect** with reset tokens
- **Fallback handling** for users without the app installed
- **Professional UI** with loading states and error handling

**Deployment Options:**
- GitHub Pages (free)
- Netlify (free)
- Vercel (free)
- Any web hosting service

See `web/README.md` for detailed setup instructions.

## Technical Stack

- **Swift & SwiftUI**: Modern iOS development
- **MVVM Architecture**: Clean separation of concerns
- **Supabase**: Authentication & cloud database
- **Vision Framework**: ML-based object detection
- **AVFoundation**: Camera capture & audio playback
- **UserNotifications**: Local alarm scheduling

## Permissions Required

- **Camera**: To capture task verification photos
- **Notifications**: To trigger alarms at scheduled times
- **Background Audio**: To keep alarm ringing even in background

## Future Enhancements

- [ ] Add more task types (exercise, meditation, etc.)
- [ ] Recurring alarms (daily, weekdays, custom)
- [ ] Snooze with increasing difficulty
- [ ] Statistics & streak tracking
- [ ] Social features (accountability partners)
- [ ] Custom alarm sounds

## Troubleshooting

### Alarm doesn't ring
- Check notification permissions in Settings > Notifications
- Ensure the alarm is set to active (toggle is on)
- Make sure device isn't in Do Not Disturb mode

### Camera not working
- Check camera permissions in Settings > Privacy > Camera
- Restart the app if camera preview is black

### Supabase errors
- Verify your URL and anon key in Constants.swift
- Check network connectivity
- Ensure database table and policies are created

## License

Created by Nikhil Konkimalla - October 2025





