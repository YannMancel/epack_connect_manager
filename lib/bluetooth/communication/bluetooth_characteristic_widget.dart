import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/material.dart';

class BluetoothCharacteristicWidget extends StatefulWidget {
  const BluetoothCharacteristicWidget({
    super.key,
    required this.peripheral,
    required this.characteristic,
  });

  final ble_lib.Peripheral peripheral;
  final ble_lib.GATTCharacteristic characteristic;

  @override
  State<BluetoothCharacteristicWidget> createState() =>
      _BluetoothCharacteristicWidgetState();
}

class _BluetoothCharacteristicWidgetState
    extends State<BluetoothCharacteristicWidget> {
  late BluetoothCommunicationLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BluetoothLowEnergyCommunicationLogic(
      manager: ble_lib.CentralManager(),
      peripheral: widget.peripheral,
      characteristic: widget.characteristic,
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BluetoothCommunicationState>(
      valueListenable: _logic.state,
      builder: (_, state, __) => ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: const RoundedRectangleBorder(),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Text('[C]'),
          title: Text(
            '${widget.characteristic.uuid}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (state.canRead) const Text('[R]'),
              if (state.canWrite) const Text('[W]'),
              if (state.canNotify) const Text('[N]'),
            ],
          ),
        ),
        children: <Widget>[
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: state.when<Widget>(
              unknown: () => const SizedBox.shrink(),
              read: (message, canNotify, isNotifyActive) =>
                  BluetoothCharacteristicReadingWidget(
                message,
                canNotify: canNotify,
                onReadPressed: () async => _logic.read(),
                hasNotifyActive: isNotifyActive,
                onNotifyPressed: (isActive) => _logic.setNotifyState(isActive),
              ),
              write: () => BluetoothCharacteristicWritingWidget(
                onSendPressed: (command) => _logic.write(command),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
