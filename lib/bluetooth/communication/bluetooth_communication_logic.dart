import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/foundation.dart';

abstract interface class BluetoothCommunicationLogic {
  ValueNotifier<BluetoothCommunicationState> get state;
  Future<void> read();
  Future<void> setNotifyState(bool isNotifyActive);
  Future<void> write(String command);
  Future<void> dispose();
}

final class BluetoothLowEnergyCommunicationLogic
    implements BluetoothCommunicationLogic {
  BluetoothLowEnergyCommunicationLogic({
    required ble_lib.CentralManager manager,
    required ble_lib.Peripheral peripheral,
    required ble_lib.GATTCharacteristic characteristic,
  })  : _manager = manager,
        _peripheral = peripheral,
        _characteristic = characteristic {
    setupState();
    setupCharacteristicStream();
  }

  final ble_lib.CentralManager _manager;
  final ble_lib.Peripheral _peripheral;
  final ble_lib.GATTCharacteristic _characteristic;
  late final StreamSubscription _characteristicStream;

  @visibleForTesting
  void setupState() {
    state.value = _characteristic.canRead
        ? ReadBluetoothCommunicationState(canNotify: _characteristic.canNotify)
        : _characteristic.canWrite || _characteristic.canWriteWithoutResponse
            ? const WriteBluetoothCommunicationState()
            : const UnknownBluetoothCommunicationState();
  }

  @visibleForTesting
  void setupCharacteristicStream() {
    _characteristicStream = _manager.characteristicNotified.listen(
      (event) {
        if (event.characteristic != _characteristic) return;
        if (!state.value.canNotify) return;
        state.value = state.value.copyWith(
          message: '[N] ${String.fromCharCodes(event.value)}',
        );
      },
    );
  }

  @override
  final ValueNotifier<BluetoothCommunicationState> state =
      ValueNotifier<BluetoothCommunicationState>(
    const UnknownBluetoothCommunicationState(),
  );

  @override
  Future<void> read() async {
    if (!state.value.canRead) return;
    final bytes = await _manager.readCharacteristic(
      _peripheral,
      _characteristic,
    );
    state.value = state.value.copyWith(
      message: '[R] ${String.fromCharCodes(bytes)}',
    );
  }

  @override
  Future<void> setNotifyState(bool isNotifyActive) async {
    await _manager.setCharacteristicNotifyState(
      _peripheral,
      _characteristic,
      state: isNotifyActive,
    );
    state.value = state.value.copyWith(
      isNotifyActive: isNotifyActive,
    );
  }

  @override
  Future<void> write(String command) async {
    final bytes = const Utf8Codec().encode(command);
    const kWriteType = ble_lib.GATTCharacteristicWriteType.withResponse;
    final fragmentSize = await _manager.getMaximumWriteLength(
      _peripheral,
      type: kWriteType,
    );
    var start = 0;
    while (start < bytes.length) {
      final end = start + fragmentSize;
      final fragmentedValue = (end < bytes.length)
          ? bytes.sublist(start, end)
          : bytes.sublist(start);
      await _manager.writeCharacteristic(
        _peripheral,
        _characteristic,
        value: fragmentedValue,
        type: kWriteType,
      );
      start = end;
    }
  }

  @override
  Future<void> dispose() async {
    await _characteristicStream.cancel();
  }
}

extension GATTCharacteristicExt on ble_lib.GATTCharacteristic {
  bool get canRead {
    return properties.contains(ble_lib.GATTCharacteristicProperty.read);
  }

  bool get canWrite {
    return properties.contains(ble_lib.GATTCharacteristicProperty.write);
  }

  bool get canWriteWithoutResponse {
    return properties.contains(
      ble_lib.GATTCharacteristicProperty.writeWithoutResponse,
    );
  }

  bool get canNotify {
    return properties.contains(ble_lib.GATTCharacteristicProperty.notify) ||
        properties.contains(ble_lib.GATTCharacteristicProperty.indicate);
  }
}
