# Setup Checklist

Follow these steps to get your Snooze u Looze app running!

## Prerequisites
- [ ] Xcode 15.0+ installed
- [ ] macOS with iOS Simulator or physical iOS device
- [ ] Internet connection

## Step 1: Supabase Setup

### Create Account & Project
- [ ] Go to [supabase.com](https://supabase.com)
- [ ] Sign up for a free account
- [ ] Click "New Project"
- [ ] Name it "snooze-u-looze" (or your choice)
- [ ] Set a strong database password
- [ ] Select a region close to you
- [ ] Wait for project to finish setting up (~2 minutes)

### Get Credentials
- [ ] Go to Project Settings (gear icon)
- [ ] Click on "API" in the left sidebar
- [ ] Copy "Project URL" (starts with https://)
- [ ] Copy "anon public" key (long string starting with eyJ)

### Configure App
- [ ] Open Xcode project
- [ ] Navigate to `Core/Utilities/Constants.swift`
- [ ] Replace `"YOUR_SUPABASE_URL"` with your Project URL
- [ ] Replace `"YOUR_SUPABASE_ANON_KEY"` with your anon key
- [ ] Save the file (⌘S)

## Step 2: Database Setup

### Create Alarms Table
- [ ] In Supabase Dashboard, click "SQL Editor" in sidebar
- [ ] Click "New Query"
- [ ] Copy the SQL from `README.md` (or below)
- [ ] Paste into the SQL editor
- [ ] Click "Run" (▶ button)
- [ ] Verify "Success" message appears

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

### Verify Table Created
- [ ] Click "Table Editor" in Supabase sidebar
- [ ] You should see "alarms" table listed
- [ ] Click on it to see empty table (no data yet)

## Step 3: Enable Authentication

### Enable Email Auth
- [ ] In Supabase Dashboard, click "Authentication"
- [ ] Click "Providers" tab
- [ ] Find "Email" provider
- [ ] Toggle it ON if not already enabled
- [ ] (Optional) Configure email templates under "Email Templates"

### Configure Auth Settings (Optional)
- [ ] Under "Configuration" → "Auth Settings"
- [ ] Set "Site URL" to your app's URL (or leave default for now)
- [ ] Set "Redirect URLs" (not needed for mobile app)

## Step 4: Xcode Setup

### Open Project
- [ ] Open `Snooze u Looze.xcodeproj` in Xcode
- [ ] Wait for packages to resolve (Supabase SDK should already be added)
- [ ] Select your target device in the device dropdown

### Configure Signing
- [ ] Click on project name in left sidebar
- [ ] Select "Snooze u Looze" under TARGETS
- [ ] Go to "Signing & Capabilities" tab
- [ ] Check "Automatically manage signing"
- [ ] Select your Apple ID team
- [ ] Change bundle identifier if needed (make it unique)

### Verify Info.plist
- [ ] Info.plist should be in project (already created)
- [ ] Should contain camera usage description
- [ ] Should contain background audio mode

## Step 5: Build & Run

### First Build
- [ ] Press ⌘B to build
- [ ] Wait for build to complete (should succeed with no errors)
- [ ] Fix any signing issues if they appear

### Run on Simulator (Quick Test)
- [ ] Select iPhone 15 Pro (or any recent iPhone simulator)
- [ ] Press ⌘R to run
- [ ] Wait for app to launch
- [ ] Grant notification permission when prompted
- [ ] Camera won't work in simulator (that's OK for auth testing)

### Run on Physical Device (Recommended)
- [ ] Connect iPhone via USB
- [ ] Select your device in device dropdown
- [ ] Press ⌘R to run
- [ ] Trust developer certificate on device if needed
- [ ] Grant notification permission
- [ ] Grant camera permission
- [ ] Now you can test full functionality!

## Step 6: Test the App

### Test Authentication
- [ ] App should show login screen
- [ ] Click "Don't have an account? Sign Up"
- [ ] Enter email (use real email or test@example.com)
- [ ] Enter password (min 6 characters)
- [ ] Click "Sign Up"
- [ ] Should navigate to empty alarm list

### Test Alarm Creation
- [ ] Click "+" button in top right
- [ ] Select a time (try 2 minutes from now for testing)
- [ ] Select a task (Brushing Teeth or Opening Laptop)
- [ ] Click "Create Alarm"
- [ ] Should see alarm in list
- [ ] Toggle should be ON (blue)

### Test Alarm Ringing
- [ ] Wait for alarm to trigger (2 minutes)
- [ ] App should show full-screen alarm view
- [ ] Alarm sound should play
- [ ] Try to swipe away (should be blocked)
- [ ] Click "Take Photo to Stop Alarm"

### Test Camera & Verification
- [ ] Camera preview should appear
- [ ] Point camera at laptop (if you selected Opening Laptop)
- [ ] Or point at toothbrush (if you selected Brushing Teeth)
- [ ] Click capture button (white circle)
- [ ] Wait for verification (~2 seconds)
- [ ] If verified, alarm stops and view dismisses
- [ ] If not verified, returns to alarm screen (try again)

## Step 7: Final Verification

### Feature Checklist
- [ ] User can sign up
- [ ] User can sign in
- [ ] User can sign out
- [ ] Can create alarms
- [ ] Can toggle alarms on/off
- [ ] Can delete alarms (swipe left)
- [ ] Notifications appear at alarm time
- [ ] Alarm rings continuously
- [ ] Camera opens and captures photos
- [ ] ML verification works (at least sometimes)
- [ ] Alarm stops after successful verification
- [ ] Data syncs to Supabase

### Troubleshooting
If something doesn't work, check:
- [ ] Supabase credentials are correct in Constants.swift
- [ ] Database table was created successfully
- [ ] Email auth is enabled in Supabase
- [ ] Notification permissions granted
- [ ] Camera permissions granted
- [ ] Device volume is up
- [ ] Good lighting for ML verification
- [ ] Object (laptop/toothbrush) is clearly visible

## Optional Enhancements

### Add Custom Alarm Sound
- [ ] Find or create alarm sound file (MP3 or WAV)
- [ ] Name it `alarm.mp3`
- [ ] In Xcode, right-click project folder
- [ ] Select "Add Files to Snooze u Looze..."
- [ ] Select your alarm sound file
- [ ] Check "Copy items if needed"
- [ ] Check "Add to targets: Snooze u Looze"
- [ ] Build and run again
- [ ] Custom sound should now play

### Customize Colors
- [ ] Open `Core/Utilities/Extensions.swift`
- [ ] Modify color values in the Color extension
- [ ] Build and run to see changes

### Add App Icon
- [ ] Create app icon (1024x1024 PNG)
- [ ] In Xcode, open Assets.xcassets
- [ ] Click on AppIcon
- [ ] Drag your icon into the 1024x1024 slot
- [ ] Xcode will generate all sizes

## 🎉 Success!

If you've checked all the boxes above, your Snooze u Looze app is fully functional!

### Next Steps
- [ ] Test with real morning alarm
- [ ] Show friends and get feedback
- [ ] Consider adding more task types
- [ ] Implement recurring alarms
- [ ] Add statistics/streak tracking
- [ ] Submit to App Store? 🚀

---

**Having Issues?** 
- Check `README.md` for detailed docs
- Check `QUICKSTART.md` for concise setup
- Check `IMPLEMENTATION_SUMMARY.md` for technical details
- Check `ALARM_SOUND_SETUP.md` for audio configuration

**Need Help?**
- Double-check Supabase credentials
- Verify database table exists
- Check Xcode console for error messages
- Make sure all permissions are granted
- Try restarting the app





