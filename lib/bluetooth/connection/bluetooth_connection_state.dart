import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;

sealed class BluetoothConnectionState {
  const BluetoothConnectionState();
}

final class DisconnectedBluetoothConnectionState
    extends BluetoothConnectionState {
  const DisconnectedBluetoothConnectionState();
}

final class ConnectedBluetoothConnectionState extends BluetoothConnectionState {
  const ConnectedBluetoothConnectionState({
    this.services = const <ble_lib.GATTService>[],
  });

  final List<ble_lib.GATTService> services;

  // No need to override equal method.
}

extension BluetoothConnectionStateExt on BluetoothConnectionState {
  T when<T>({
    required T Function() disconnected,
    required T Function(List<ble_lib.GATTService>) connected,
  }) {
    return switch (this) {
      DisconnectedBluetoothConnectionState() => disconnected(),
      ConnectedBluetoothConnectionState(:final services) => connected(services),
    };
  }

  bool get isConnected {
    return when<bool>(
      disconnected: () => false,
      connected: (_) => true,
    );
  }

  BluetoothConnectionState copyWith({
    List<ble_lib.GATTService>? services,
  }) {
    return when<BluetoothConnectionState>(
      disconnected: () => this,
      connected: (s) => ConnectedBluetoothConnectionState(
        services: services ?? s,
      ),
    );
  }
}
