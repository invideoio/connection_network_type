# connection_network_type

This plugin allows Flutter apps to detect network changes. The existing iOS and
Android implementations report detailed mobile network types such as 2G, 3G, 4G
and 5G. This fork adds macOS and Windows transport detection using
`connectivity_plus`, registered automatically through Flutter's Dart plugin
registration.

An available interface does not prove that Internet access works. Handle network
request failures independently; a Wi-Fi connection can have a captive portal or
no Internet access.

This library is based on and inspired by the library "[network_type_reachability](https://pub.dev/packages/network_type_reachability)", which in turn is based on and inspired by the library "[flutter_reachability](https://pub.dev/packages/flutter_reachability)"

The main difference is that the code has been refactored to remove the need to manage permissions and typing issues have been fixed. In this way, this library contains fewer functions, but maintains greater compatibility of use in different versions.

## Examples

1. To detect the current Network Type:

```dart
    // If this plugin is used on Android, request the READ_PHONE_STATE permission.
    if(Platform.isAndroid) {
        await Permission.phone.request();
    }

    NetworkStatus networkStatus = await ConnectionNetworkType().currentNetworkStatus();
    
    switch(networkStatus) {
      case NetworkStatus.unreachable:
        // unreachable
      case NetworkStatus.wifi:
        // wifi
      case NetworkStatus.mobile2G:
        // 2G
      case NetworkStatus.mobile3G:
        // 3G
      case NetworkStatus.mobile4G:
        // 4G
      case NetworkStatus.mobile5G:
        // 5G
      case NetworkStatus.otherMobile:
        // cellular connection with unknown generation
      case NetworkStatus.ethernet:
        // wired connection
      case NetworkStatus.vpn:
        // VPN interface
      case NetworkStatus.bluetooth:
        // Bluetooth network interface
      case NetworkStatus.other:
        // other connected transport
      case NetworkStatus.unknown:
        // no interface information supplied by the platform
    }
```

2. To listen changes on Network Type:

```dart
    final subscription = ConnectionNetworkType().onNetworkStateChanged
        .listen((NetworkStatus networkStatus) {
        // Trigger one function or manage state from here
    });

    // When the consumer is disposed:
    await subscription.cancel();
```

## Desktop behavior and compatibility

- Requires Dart 3.12+, Flutter 3.44+ and `connectivity_plus ^7.3.1`. The SDK
  floor and iOS Swift Package Manager implementation are retained from the
  InVideo 2.0.0 plugin; desktop registration does not replace its iOS package.
- Native requirements also follow the dependency: iOS 13+, macOS 10.15+,
  Xcode 26.1.1+, Java 17, Android Gradle Plugin 8.12.1+ and Gradle 8.13+ where
  applicable. Check those requirements before upgrading a mobile consumer.
- iOS/Android native code and method-channel registration are unchanged. The
  added dependency can still impose newer build requirements on consumers.
- `ethernet`, `vpn`, `bluetooth`, `other` and `unknown` are appended to
  `NetworkStatus`, preserving all previous values and indexes. Applications with
  exhaustive switches must handle the new cases.
- The API returns one status. When multiple interfaces exist it uses this stable
  summary order: Ethernet, Wi-Fi, cellular, Bluetooth, VPN, other. This does not
  identify the OS default route or rank link quality. A reported connected
  interface wins over a contradictory `none` result.
- Desktop cellular is `otherMobile`; this adapter never guesses 2G/3G/4G/5G.
  Satellite-only connectivity maps to `other`.
- Explicit `none` maps to `unreachable`; an empty platform result maps to
  `unknown`. Platform errors propagate rather than being relabeled as offline.
- macOS does not expose VPN as a separate interface type through
  `connectivity_plus`; it can appear as `other` or alongside a physical transport.
- The change stream remains broadcast, deduplicates the summarized status per
  listener, and releases its upstream subscription when listeners cancel. OS
  transitions can still be transient; applications should not treat one event as
  an Internet health test.

Registration follows [Flutter's Dart-only plugin documentation](https://docs.flutter.dev/packages-and-plugins/developing-packages#dart-only-platform-implementations).
Transport limitations follow [connectivity_plus](https://pub.dev/packages/connectivity_plus/versions/7.3.1).

## Fork provenance and validation

This integration starts from InVideo's Swift Package Manager revision
`d8905377cd07d4330ee5dcf6df0ffd02aaa0fbe6` (version 2.0.0) in
[invideoio/connection_network_type](https://github.com/invideoio/connection_network_type).
The desktop adapter and its tests are ported from
`ee5c513640d594e1aaeb9bb8cfbfbb89e468db12`; the iOS/Android implementation
and Swift package remain identical to the InVideo base. The original BSD
3-Clause `LICENSE` is retained unchanged.

Package analyzer/unit tests validate the adapter's mapping, concurrent listeners,
resubscription and error propagation. They do not replace native app checks.
Validate generated plugin registration, one live status read, event subscription
and cancellation in a macOS app; repeat on a Windows host before claiming Windows
runtime support. The included example shows correct subscription disposal.

## iOS: Swift Package Manager

Starting with version 2.0.0 the iOS implementation is distributed only as a Swift package; CocoaPods is no longer supported. Your app needs Flutter 3.44 or later, where Swift Package Manager is enabled by default. If it has been disabled in your Flutter config, re-enable it with:

```bash
flutter config --enable-swift-package-manager
```

The minimum iOS deployment target is 13.0. Apps that have Swift Package Manager turned off (`flutter config --no-enable-swift-package-manager`) must stay on version 1.x. Apps with Swift Package Manager enabled can keep using other CocoaPods-only plugins alongside this one; Flutter falls back to CocoaPods for those.

One caveat for such mixed apps: this plugin pulls [Reachability.swift](https://github.com/ashleymills/Reachability.swift) through Swift Package Manager. If another CocoaPods-only plugin in your app depends on the `ReachabilitySwift` pod, the app ends up with two copies of the `Reachability` module and iOS logs a duplicate-class warning at launch. It built and ran correctly in our tests, but prefer plugins that also use Swift Package Manager so both resolve to one package.

Add-to-app projects are not supported either: `flutter build ios-framework` still forces CocoaPods on current Flutter versions, so it cannot consume a Swift-package-only plugin. Those projects must stay on version 1.x.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
