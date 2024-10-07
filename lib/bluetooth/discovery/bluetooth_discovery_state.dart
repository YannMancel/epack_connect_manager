import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;

sealed class BluetoothDiscoveryState {
  const BluetoothDiscoveryState();
}

final class UnAuthorizedBluetoothDiscoveryState
    extends BluetoothDiscoveryState {
  const UnAuthorizedBluetoothDiscoveryState();
}

final class AuthorizedBluetoothDiscoveryState extends BluetoothDiscoveryState {
  const AuthorizedBluetoothDiscoveryState({
    this.isDiscovering = false,
    this.discoveries = const <ble_lib.DiscoveredEventArgs>[],
  });

  final bool isDiscovering;
  final List<ble_lib.DiscoveredEventArgs> discoveries;

  // No need to override equal method.
}

extension BluetoothDiscoveryStateExt on BluetoothDiscoveryState {
  T when<T>({
    required T Function() unAuthorized,
    required T Function(bool, List<ble_lib.DiscoveredEventArgs>) authorized,
  }) {
    return switch (this) {
      UnAuthorizedBluetoothDiscoveryState() => unAuthorized(),
      AuthorizedBluetoothDiscoveryState(
        :final isDiscovering,
        :final discoveries,
      ) =>
        authorized(isDiscovering, discoveries),
    };
  }

  bool get isAuthorized {
    return when<bool>(
      unAuthorized: () => false,
      authorized: (_, __) => true,
    );
  }

  BluetoothDiscoveryState copyWith({
    bool? isDiscovering,
    List<ble_lib.DiscoveredEventArgs>? discoveries,
  }) {
    return when<BluetoothDiscoveryState>(
      unAuthorized: () => this,
      authorized: (i, d) => AuthorizedBluetoothDiscoveryState(
        isDiscovering: isDiscovering ?? i,
        discoveries: discoveries ?? d,
      ),
    );
  }
}
