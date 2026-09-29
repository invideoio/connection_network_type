# 2.1.0

* Add macOS and Windows transport detection through `connectivity_plus` and Dart plugin registration.
* Preserve the 2.0.0 iOS Swift Package Manager integration and SDK requirements; native iOS/Android implementations are unchanged.
* Append Ethernet, VPN, Bluetooth, other and unknown network statuses without changing existing enum indexes. Consumers with exhaustive switches must handle the added values.
* Cover transport mapping, multiple-interface ordering, stream cancellation/resubscription and error propagation; dispose the example subscription.

# 2.0.0

* **Breaking:** the iOS implementation now ships only as a Swift package (`ios/connection_network_type/Package.swift`); the CocoaPods podspec was removed. The plugin requires Flutter 3.44 or later, where Swift Package Manager is enabled by default. Apps that have Swift Package Manager turned off cannot use this version. Add-to-app projects cannot use it either, because `flutter build ios-framework` still forces CocoaPods on current Flutter versions.
* The iOS implementation is now a single Swift class, `ConnectionNetworkTypePlugin`; the Objective-C shim was removed. No behavior changes.
* Raised the minimum iOS deployment target to 13.0, matching Flutter's minimum.
* Added a privacy manifest (`PrivacyInfo.xcprivacy`) to the iOS plugin.
* Migrated the example app to Swift Package Manager and removed its CocoaPods integration.

# 1.0.1

* Added TD-SCDMA network type check for 3G connection detection on Android

# 1.0.0

* Added compatibility with Gradle 8 Android

# 0.0.1

* Added `currentNetworkStatus()` to get the current Network Status
* Added Stream `onNetworkStateChanged` to listen Network changes
