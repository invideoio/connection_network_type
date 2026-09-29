import 'package:connectivity_plus/connectivity_plus.dart';

import 'abstract/connection_network_type_platform_interface.dart';
import 'enum/network_status.enum.dart';

/// macOS and Windows transport detection using connectivity_plus.
///
/// This reports interface availability, not Internet access or the default route.
/// The native iOS and Android implementations remain unchanged.
class ConnectionNetworkTypeDesktop extends ConnectionNetworkTypePlatform {
  ConnectionNetworkTypeDesktop({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  // map/distinct preserve the upstream broadcast stream and cancel their source
  // subscription when a listener cancels. No permanent native listener is held.
  late final Stream<NetworkStatus> _changes = _connectivity
      .onConnectivityChanged
      .map(_networkStatus)
      .distinct();

  static void registerWith() {
    ConnectionNetworkTypePlatform.instance = ConnectionNetworkTypeDesktop();
  }

  @override
  Stream<NetworkStatus> get onNetworkStateChanged => _changes;

  @override
  Future<NetworkStatus> currentNetworkStatus() async {
    return _networkStatus(await _connectivity.checkConnectivity());
  }

  // The existing API returns a single value. Prefer a concrete transport over
  // a virtual/unknown interface, using a stable order regardless of OS ordering.
  // This is a summary policy, not a claim about route priority or link speed.
  static NetworkStatus _networkStatus(List<ConnectivityResult> interfaces) {
    if (interfaces.isEmpty) return NetworkStatus.unknown;
    if (interfaces.contains(ConnectivityResult.ethernet)) {
      return NetworkStatus.ethernet;
    }
    if (interfaces.contains(ConnectivityResult.wifi)) return NetworkStatus.wifi;
    if (interfaces.contains(ConnectivityResult.mobile)) {
      // Desktop connectivity does not reveal the cellular generation.
      return NetworkStatus.otherMobile;
    }
    if (interfaces.contains(ConnectivityResult.bluetooth)) {
      return NetworkStatus.bluetooth;
    }
    if (interfaces.contains(ConnectivityResult.vpn)) return NetworkStatus.vpn;
    if (interfaces.any((result) => result != ConnectivityResult.none)) {
      // Includes satellite/other and future transport types. Never label a
      // connected but unfamiliar transport as disconnected.
      return NetworkStatus.other;
    }
    return NetworkStatus.unreachable;
  }
}
