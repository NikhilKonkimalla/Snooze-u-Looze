# Quick Start Guide

Get your Snooze u Looze app running in 5 minutes!

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Supabase account (free tier works great)

## Setup Steps

### 1. Configure Supabase (2 minutes)

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Go to **Project Settings** → **API**
4. Copy your:
   - Project URL (looks like: `https://xxxxx.supabase.co`)
   - Anon/public key (long string starting with `eyJ...`)

5. Open `Core/Utilities/Constants.swift` and replace:
   ```swift
   static let supabaseURL = "YOUR_SUPABASE_URL"
   static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
   ```

### 2. Setup Database (1 minute)

1. In Supabase Dashboard, go to **SQL Editor**
2. Click **New Query**
3. Paste this SQL:

```sql
create table alarms (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  alarm_time timestamp with time zone not null,
  task text not null,
  is_active boolean default true,
  repeat_days jsonb,
  created_at timestamp with time zone default now()
);

alter table alarms enable row level security;

create policy "Users can access their own alarms"
  on alarms for all using (auth.uid() = user_id);
```

4. Click **Run** (▶)

### 3. Enable Authentication (30 seconds)

1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Enable **Email** provider
3. That's it!

### 4. Run the App (1 minute)

1. Open `Snooze u Looze.xcodeproj` in Xcode
2. Select your target device (physical device recommended for best alarm experience)
3. Press **⌘R** to build and run
4. Allow camera and notification permissions when prompted

## First Use

1. **Sign Up**: Create an account with email/password
2. **Create Alarm**: 
   - Tap the **+** button
   - Set a time (try 1 minute from now for testing)
   - Choose a task (Brushing Teeth or Opening Laptop)
   - Tap **Create Alarm**
3. **Wait for Alarm**: When it triggers, the alarm will ring continuously
4. **Take Photo**: Capture a photo showing you doing the task
5. **Verification**: ML will verify your task - alarm stops when verified!

## Testing Tips

- **Test Alarm**: Set for 1-2 minutes from now to test quickly
- **Camera Test**: Make sure your camera can see a laptop or toothbrush clearly
- **Volume**: Turn up device volume to hear the alarm
- **Notifications**: Ensure notifications are enabled in Settings

## Troubleshooting

### "No Supabase URL" or Auth Errors
- Double-check you copied the correct URL and key
- Make sure there are no extra spaces or quotes
- URL should start with `https://`

### Alarm Doesn't Ring
- Check notification permissions: Settings → Notifications → Snooze u Looze
- Make sure alarm toggle is ON (blue)
- Device shouldn't be in Do Not Disturb mode

### Camera Issues
- Grant camera permission: Settings → Privacy → Camera → Snooze u Looze
- Try restarting the app
- Test with good lighting for better ML detection

### Verification Fails
- Make sure the object (laptop/toothbrush) is clearly visible
- Good lighting helps ML detection
- Try different angles
- Object should be the main focus of the photo

## Next Steps

- Add multiple alarms for different times
- Try both task types
- Invite friends to try the app
- Check out the README.md for more features

## Support

For detailed documentation, see `README.md`

For alarm sound setup, see `ALARM_SOUND_SETUP.md`

---

**Enjoy waking up with purpose! 🎯**



