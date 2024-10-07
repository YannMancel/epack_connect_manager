import 'dart:async';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/foundation.dart';

abstract interface class BluetoothDiscoveryLogic {
  ValueNotifier<BluetoothDiscoveryState> get state;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}

final class BluetoothLowEnergyDiscoveryLogic
    implements BluetoothDiscoveryLogic {
  BluetoothLowEnergyDiscoveryLogic({
    required ble_lib.CentralManager manager,
  }) : _manager = manager {
    setupStateStream();
    setupDiscoveryStream();
  }

  final ble_lib.CentralManager _manager;
  late final StreamSubscription _stateStream;
  late final StreamSubscription _discoveryStream;

  @visibleForTesting
  void setupStateStream() {
    _stateStream = _manager.stateChanged.listen(
      (event) async {
        if (event.state == ble_lib.BluetoothLowEnergyState.unauthorized &&
            Platform.isAndroid) {
          await _manager.authorize();
        }

        if (event.state == ble_lib.BluetoothLowEnergyState.poweredOn) {
          state.value = const AuthorizedBluetoothDiscoveryState();
        }
      },
    );
  }

  @visibleForTesting
  void setupDiscoveryStream() {
    _discoveryStream = _manager.discovered.listen(
      (event) {
        if (!state.value.isAuthorized) return;

        if (!(event.advertisement.name?.contains('EPACK-CONNECT') ?? false)) {
          return;
        }

        final discoveries = state.value.when<List<ble_lib.DiscoveredEventArgs>>(
          unAuthorized: () => const <ble_lib.DiscoveredEventArgs>[],
          authorized: (_, discoveries) => <ble_lib.DiscoveredEventArgs>{
            for (final discovery in discoveries)
              discovery.peripheral == event.peripheral ? event : discovery,
            event,
          }.toList(),
        );
        state.value = state.value.copyWith(
          discoveries: discoveries,
        );
      },
    );
  }

  @override
  final ValueNotifier<BluetoothDiscoveryState> state =
      ValueNotifier<BluetoothDiscoveryState>(
    const UnAuthorizedBluetoothDiscoveryState(),
  );

  @override
  Future<void> start() async {
    if (!state.value.isAuthorized) return;
    final isDiscovering = state.value.when<bool>(
      unAuthorized: () => false,
      authorized: (isDiscovering, __) => isDiscovering,
    );
    if (isDiscovering) return;
    state.value = state.value.copyWith(
      discoveries: const <ble_lib.DiscoveredEventArgs>[],
    );
    await _manager.startDiscovery();
    state.value = state.value.copyWith(
      isDiscovering: true,
    );
  }

  @override
  Future<void> stop() async {
    if (!state.value.isAuthorized) return;
    final isDiscovering = state.value.when<bool>(
      unAuthorized: () => false,
      authorized: (isDiscovering, __) => isDiscovering,
    );
    if (!isDiscovering) return;
    await _manager.stopDiscovery();
    state.value = state.value.copyWith(
      isDiscovering: false,
    );
  }

  @override
  Future<void> dispose() async {
    await _stateStream.cancel();
    await _discoveryStream.cancel();
  }
}
