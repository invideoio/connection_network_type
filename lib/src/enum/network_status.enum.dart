enum NetworkStatus {
  unreachable,
  wifi,
  mobile2G,
  mobile3G,
  mobile4G,
  mobile5G,
  otherMobile,
  ethernet,
  vpn,
  bluetooth,

  /// A connected interface whose transport cannot be represented more precisely.
  other,

  /// The platform did not report any interface information.
  ///
  /// This is different from an explicit disconnected result, [unreachable].
  unknown,
}
