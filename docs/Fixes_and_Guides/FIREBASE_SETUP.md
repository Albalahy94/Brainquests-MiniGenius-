# Firebase Setup Instructions

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: "MiniGenius"
   - Enable/disable Google Analytics (recommended: Enable)
   - Complete project creation

## 2. Add Android App

1. In Firebase Console, click the Android icon or "Add app" → Android
2. Register your app:
   - **Android package name**: `com.minigenius.app` (or your package name)
   - **App nickname**: MiniGenius Android (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Click "Register app"
4. Download `google-services.json`
5. Place the file in: `android/app/google-services.json`

## 3. Add iOS App

1. In Firebase Console, click the iOS icon or "Add app" → iOS
2. Register your app:
   - **iOS bundle ID**: `com.minigenius.app` (or your bundle ID)
   - **App nickname**: MiniGenius iOS (optional)
3. Click "Register app"
4. Download `GoogleService-Info.plist`
5. Place the file in: `ios/Runner/GoogleService-Info.plist`

## 4. Enable Firebase Services

### Analytics
- Already enabled when you create the project
- No additional setup needed

### Crashlytics
1. In Firebase Console, go to "Crashlytics" in the left menu
2. Click "Get started" if not already enabled
3. Follow the setup instructions for your platform

## 5. Update Android Configuration

### android/build.gradle
Add to the `buildscript` dependencies:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

### android/app/build.gradle
Add at the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

## 6. Update iOS Configuration

### ios/Podfile
Ensure Firebase pods are included (they should be added automatically when you run `pod install`)

### ios/Runner/Info.plist
No changes needed - Firebase SDK handles configuration automatically

## 7. Verify Setup

1. Run `flutter pub get`
2. Run `flutter run`
3. Check Firebase Console → Analytics → Events to see if events are being logged
4. Check Crashlytics dashboard for any crash reports

## 8. Test Firebase Integration

The app will automatically:
- Log screen views
- Log game events (start, complete, level unlock)
- Log premium purchases
- Record crashes and errors

You can test by:
1. Opening the app
2. Playing a game
3. Completing a level
4. Checking Firebase Console for events

## Troubleshooting

### Android
- Ensure `google-services.json` is in `android/app/` directory
- Check that `apply plugin: 'com.google.gms.google-services'` is at the bottom of `android/app/build.gradle`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

### iOS
- Ensure `GoogleService-Info.plist` is in `ios/Runner/` directory
- Run `cd ios && pod install && cd ..`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

### Common Issues
- **"Default FirebaseApp is not initialized"**: Ensure Firebase.initializeApp() is called in main.dart
- **Analytics not working**: Check that Analytics is enabled in Firebase Console
- **Crashlytics not working**: Ensure Crashlytics is enabled and configured in Firebase Console

