import 'dart:async';

import 'package:connection_network_type/connection_network_type.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> interfaces = [];
  Object? failure;
  int listens = 0;
  int cancels = 0;
  late final changes = StreamController<List<ConnectivityResult>>.broadcast(
    onListen: () => listens++,
    onCancel: () => cancels++,
  );

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (failure != null) throw failure!;
    return interfaces;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;
}

void main() {
  late FakeConnectivity connectivity;
  late ConnectionNetworkTypeDesktop platform;

  setUp(() {
    connectivity = FakeConnectivity();
    platform = ConnectionNetworkTypeDesktop(connectivity: connectivity);
  });

  tearDown(() => connectivity.changes.close());

  test(
    'connected transports are not mislabeled as disconnected or cellular',
    () async {
      final cases = {
        ConnectivityResult.none: NetworkStatus.unreachable,
        ConnectivityResult.ethernet: NetworkStatus.ethernet,
        ConnectivityResult.wifi: NetworkStatus.wifi,
        ConnectivityResult.mobile: NetworkStatus.otherMobile,
        ConnectivityResult.bluetooth: NetworkStatus.bluetooth,
        ConnectivityResult.vpn: NetworkStatus.vpn,
        ConnectivityResult.other: NetworkStatus.other,
        ConnectivityResult.satellite: NetworkStatus.other,
      };
      for (final entry in cases.entries) {
        connectivity.interfaces = [entry.key];
        expect(await platform.currentNetworkStatus(), entry.value);
      }
      connectivity.interfaces = [];
      expect(await platform.currentNetworkStatus(), NetworkStatus.unknown);
    },
  );

  test(
    'multiple interfaces use a stable summary regardless of platform order',
    () async {
      for (final interfaces in [
        [ConnectivityResult.vpn, ConnectivityResult.wifi],
        [ConnectivityResult.wifi, ConnectivityResult.vpn],
        [ConnectivityResult.none, ConnectivityResult.wifi],
      ]) {
        connectivity.interfaces = interfaces;
        expect(await platform.currentNetworkStatus(), NetworkStatus.wifi);
      }
      connectivity.interfaces = [
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
        ConnectivityResult.mobile,
      ];
      expect(await platform.currentNetworkStatus(), NetworkStatus.ethernet);
    },
  );

  test(
    'listeners release the upstream stream and can subscribe again',
    () async {
      final firstEvents = <NetworkStatus>[];
      final secondEvents = <NetworkStatus>[];
      final first = platform.onNetworkStateChanged.listen(firstEvents.add);
      final second = platform.onNetworkStateChanged.listen(secondEvents.add);
      expect(platform.onNetworkStateChanged.isBroadcast, isTrue);
      expect(connectivity.listens, 1);

      connectivity.changes.add([ConnectivityResult.wifi]);
      connectivity.changes.add([
        ConnectivityResult.wifi,
        ConnectivityResult.vpn,
      ]);
      connectivity.changes.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(firstEvents, [NetworkStatus.wifi, NetworkStatus.unreachable]);
      expect(secondEvents, firstEvents);

      await first.cancel();
      expect(connectivity.cancels, 0);
      await second.cancel();
      expect(connectivity.cancels, 1);

      final next = platform.onNetworkStateChanged.first;
      connectivity.changes.add([ConnectivityResult.ethernet]);
      expect(await next, NetworkStatus.ethernet);
      expect(connectivity.listens, 2);
      expect(connectivity.cancels, 2);
    },
  );

  test(
    'platform errors remain errors rather than invented offline status',
    () async {
      final failure = PlatformException(code: 'connectivity_unavailable');
      connectivity.failure = failure;
      await expectLater(
        platform.currentNetworkStatus(),
        throwsA(same(failure)),
      );

      final next = platform.onNetworkStateChanged.first;
      connectivity.changes.addError(failure);
      await expectLater(next, throwsA(same(failure)));
    },
  );
}
