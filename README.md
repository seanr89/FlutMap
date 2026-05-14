# FlutMap
App designed to support working with google maps in an androoid flutter applicatio

## Setting up Google Maps

To use Google Maps in this Flutter app, you need to obtain API keys from the Google Cloud Console and insert them into the project.

### 1. Get an API Key
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one.
3. Enable the required APIs for your target platforms:
   - **Maps SDK for Android** (for Android)
   - **Maps SDK for iOS** (for iOS)
   - **Maps JavaScript API** (for Web)
4. Go to **APIs & Services > Credentials**.
5. Click **Create Credentials > API key**. Copy the generated key.

### 2. Add API Key to the App

You will need to replace the placeholder `YOUR_API_KEY_HERE` with your actual API key in the following files:

**Android**
Open `maprunner/android/app/src/main/AndroidManifest.xml` and replace `YOUR_API_KEY_HERE`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**Web**
Open `maprunner/web/index.html` and replace `YOUR_API_KEY_HERE`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
```

**iOS (if applicable)**
Open `maprunner/ios/Runner/AppDelegate.swift` and add/replace your key:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
