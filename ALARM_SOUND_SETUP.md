# Alarm Sound Setup

The app uses an alarm sound file to create the continuous ringing effect. Here's how to add it:

## Option 1: Add Your Own Alarm Sound (Recommended)

1. Find or create an alarm sound file (MP3 or WAV format)
2. Name it `alarm.mp3` (or `alarm.wav`)
3. In Xcode:
   - Right-click on `Snooze u Looze` folder
   - Select "Add Files to Snooze u Looze..."
   - Select your alarm sound file
   - ✅ Make sure "Copy items if needed" is checked
   - ✅ Make sure "Add to targets: Snooze u Looze" is checked
   - Click "Add"

## Option 2: Use System Sound (Current Fallback)

The app is currently configured to use system alarm sounds as a fallback. This will work but may not be as loud or customizable.

## Recommended Alarm Sound Properties

- **Duration**: 5-10 seconds (will loop automatically)
- **Volume**: Loud and clear
- **Format**: MP3 or WAV
- **Sample Rate**: 44.1kHz or 48kHz
- **Bit Rate**: 128kbps or higher

## Free Alarm Sound Resources

- [freesound.org](https://freesound.org) - Search for "alarm clock"
- [zapsplat.com](https://zapsplat.com) - Free sound effects
- [mixkit.co](https://mixkit.co/free-sound-effects/alarm/) - Free alarm sounds

## Testing the Alarm Sound

1. Set an alarm for 1 minute from now
2. Wait for it to trigger
3. The alarm should play continuously
4. Take a photo of the required task to stop it

## Technical Details

The alarm sound is played using `AVAudioPlayer` with:
- `numberOfLoops = -1` (infinite loop)
- `volume = 1.0` (maximum volume)
- Background audio mode enabled for continuous playback

