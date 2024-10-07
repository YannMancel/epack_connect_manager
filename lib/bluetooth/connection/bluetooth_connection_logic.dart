import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/foundation.dart';

abstract interface class BluetoothConnectionLogic {
  ValueNotifier<BluetoothConnectionState> get state;
  Future<void> connect();
  Future<void> disconnect();
  Future<void> dispose();
}

final class BluetoothLowEnergyConnectionLogic
    implements BluetoothConnectionLogic {
  BluetoothLowEnergyConnectionLogic({
    required ble_lib.CentralManager manager,
    required ble_lib.DiscoveredEventArgs discovery,
  })  : _manager = manager,
        _discovery = discovery {
    setupConnectionStream();
    setupMtuStream();
  }

  final ble_lib.CentralManager _manager;
  final ble_lib.DiscoveredEventArgs _discovery;
  late final StreamSubscription _connectionStateStream;
  late final StreamSubscription _mtuStream;

  @visibleForTesting
  void setupMtuStream() {
    _mtuStream = _manager.mtuChanged.listen((event) {
      if (event.peripheral != _discovery.peripheral) return;
      if (kDebugMode) print('MTU changed: ${event.mtu}');
    });
  }

  @visibleForTesting
  void setupConnectionStream() {
    _connectionStateStream = _manager.connectionStateChanged.listen(
      (event) async {
        if (event.peripheral != _discovery.peripheral) return;
        state.value = (event.state == ble_lib.ConnectionState.connected)
            ? const ConnectedBluetoothConnectionState()
            : const DisconnectedBluetoothConnectionState();
        if (state.value.isConnected) await discoverGATT();
      },
    );
  }

  @visibleForTesting
  Future<void> discoverGATT() async {
    final services = await _manager.discoverGATT(_discovery.peripheral);
    state.value = state.value.copyWith(services: services);
  }

  @override
  final ValueNotifier<BluetoothConnectionState> state =
      ValueNotifier<BluetoothConnectionState>(
    const DisconnectedBluetoothConnectionState(),
  );

  @override
  Future<void> connect() async {
    if (state.value.isConnected) return;
    await _manager.connect(_discovery.peripheral);
  }

  @override
  Future<void> disconnect() async {
    if (!state.value.isConnected) return;
    await _manager.disconnect(_discovery.peripheral);
  }

  @override
  Future<void> dispose() async {
    await _connectionStateStream.cancel();
    await _mtuStream.cancel();
  }
}
