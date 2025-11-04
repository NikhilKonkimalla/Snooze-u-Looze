# Alarm Audio Setup

This directory contains audio resources for the Snooze u Looze alarm system.

## Current Status

The app is configured to use a **custom alarm sound file** if available, with **system sounds as fallback**.

## How It Works

1. **Custom Sound**: If `alarm.wav` or `alarm.mp3` is found in the app bundle, it will be used
2. **System Sounds**: If no custom file is found, the app uses iOS system sounds (1005, 1013)
3. **Continuous Playback**: Both methods play continuously until the user completes their task

## Adding a Custom Alarm Sound

### Option 1: Use the Generated Sound (Recommended)
The app will automatically use system sounds that are loud and continuous.

### Option 2: Add Your Own Custom Sound
1. **Create an alarm sound file**:
   - Duration: 1-2 seconds
   - Format: WAV or MP3
   - Sample Rate: 44.1 kHz
   - Volume: Loud but not distorted
   - Frequency: 800-1000 Hz (typical alarm frequency)

2. **Add to Xcode**:
   - Name the file `alarm.wav` or `alarm.mp3`
   - Drag into your Xcode project
   - Ensure "Add to target" is checked
   - The file will be included in your app bundle

3. **Test**: The AlarmSoundService will automatically detect and use your custom file

## Background Audio Requirements

For alarms to work when the app is backgrounded:

1. **Enable Background Audio** in Xcode:
   - Select your project → Target → Capabilities
   - Enable "Background Modes"
   - Check "Audio, AirPlay, and Picture in Picture"

2. **User Settings**:
   - The app will prompt users to enable Background App Refresh
   - Users need to enable it in Settings → General → Background App Refresh

## Technical Details

- **Audio Session**: Configured for `.playback` category
- **Background Tasks**: Used to maintain audio playback
- **Volume**: Maximum volume for alarm sounds
- **Looping**: Custom sounds loop indefinitely
- **Fallback**: System sounds if custom file fails

## Testing

To test the alarm system:
1. Create an alarm for 1 minute from now
2. Lock your device
3. Wait for the alarm to trigger
4. Verify continuous audio playback
5. Test task verification to stop the alarm




