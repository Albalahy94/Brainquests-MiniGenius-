# AdMob Setup Instructions

## 1. Create AdMob Account

1. Go to [AdMob](https://admob.google.com/)
2. Sign in with your Google account
3. Accept the AdMob Terms of Service
4. Complete account setup

## 2. Add Your App

1. In AdMob Console, click "Apps" → "Add app"
2. Select platform (Android or iOS)
3. Enter app details:
   - **App name**: MiniGenius
   - **Package name** (Android): `com.minigenius.app`
   - **Bundle ID** (iOS): `com.minigenius.app`
4. Click "Add app"

## 3. Create Ad Units

1. After adding your app, click "Add ad unit"
2. Select "Banner" ad format
3. Enter ad unit name: "MiniGenius Banner"
4. Click "Create ad unit"
5. **Copy the Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`)

## 4. Update Ad Unit IDs in Code

### Option 1: Update in ads_service.dart

Open `lib/core/services/ads_service.dart` and replace the test ad unit ID:

```dart
// Replace this line:
static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID

// With your actual ad unit ID:
static const String _bannerAdUnitId = 'ca-app-pub-YOUR-PUBLISHER-ID/YOUR-AD-UNIT-ID';
```

### Option 2: Use Environment Variables (Recommended for Production)

Create a config file or use environment variables to store ad unit IDs.

## 5. Android Configuration

### android/app/src/main/AndroidManifest.xml

Add the AdMob App ID inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR-PUBLISHER-ID~YOUR-APP-ID"/>
```

**Note**: Replace with your actual AdMob App ID (found in AdMob Console → Apps → App settings)

### android/app/build.gradle

Ensure you have the Google Mobile Ads SDK dependency (already included via `google_mobile_ads` package).

## 6. iOS Configuration

### ios/Runner/Info.plist

Add the AdMob App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR-PUBLISHER-ID~YOUR-APP-ID</string>
```

**Note**: Replace with your actual AdMob App ID

## 7. Test Ads

During development, use test ad unit IDs:
- **Banner Test ID**: `ca-app-pub-3940256099942544/6300978111`

The app is currently configured with test IDs. Replace them with your actual ad unit IDs before publishing.

## 8. Ad Placement

Banner ads are automatically shown on:
- Home screen (bottom, above navigation)

Ads are automatically hidden for premium users.

## 9. Ad Policies Compliance

Ensure your app complies with AdMob policies:
- ✅ No pop-up ads (only banner ads)
- ✅ No forced video ads
- ✅ Ads don't interfere with gameplay
- ✅ Appropriate content for children (COPPA compliance)

## 10. Testing

1. Use test ad unit IDs during development
2. Test on real devices (ads may not show in emulators)
3. Verify ads don't show for premium users
4. Check ad performance in AdMob Console

## Troubleshooting

### Ads not showing
- Check internet connection
- Verify ad unit IDs are correct
- Ensure app is not in test mode (use test IDs for testing)
- Check AdMob Console for any policy violations

### Ads showing for premium users
- Verify `shouldShowAds()` method in `AdsService`
- Check that premium status is properly saved in `UserProgress`

### Build errors
- Ensure `google_mobile_ads` package is in `pubspec.yaml`
- Run `flutter pub get`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

## Production Checklist

- [ ] Replace test ad unit IDs with production IDs
- [ ] Add AdMob App ID to AndroidManifest.xml
- [ ] Add AdMob App ID to Info.plist
- [ ] Test ads on real devices
- [ ] Verify premium users don't see ads
- [ ] Review AdMob policies compliance
- [ ] Set up ad revenue tracking in AdMob Console

