import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/material.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage(
    this.discovery, {
    super.key,
  });

  final ble_lib.DiscoveredEventArgs discovery;

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  late BluetoothConnectionLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BluetoothLowEnergyConnectionLogic(
      manager: ble_lib.CentralManager(),
      discovery: widget.discovery,
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.discovery.advertisement.name ?? '[No Name]'),
      ),
      body: ValueListenableBuilder<BluetoothConnectionState>(
        valueListenable: _logic.state,
        builder: (_, state, __) => Stack(
          children: <Widget>[
            state.when<Widget>(
              disconnected: () => const Center(
                child: Text('Disconnected'),
              ),
              connected: (services) => services.isEmpty
                  ? const Center(
                      child: Text('No Service'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 88.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      itemCount: services.length,
                      itemBuilder: (_, index) {
                        final service = services[index];
                        return ServiceCard(
                          service,
                          peripheral: widget.discovery.peripheral,
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    state.isConnected
                        ? await _logic.disconnect()
                        : await _logic.connect();
                  },
                  label: Text(state.isConnected ? 'Disconnect' : 'Connect'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard(
    this.service, {
    super.key,
    required this.peripheral,
  });

  final ble_lib.GATTService service;
  final ble_lib.Peripheral peripheral;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uuid = service.uuid.toString();
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(top: 8.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const RoundedRectangleBorder(),
        title: Text(uuid, style: theme.textTheme.bodySmall),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: <Widget>[
          const Divider(height: 1.0),
          ...<Widget>[
            for (final includedService in service.includedServices)
              Text(
                '[S] ${includedService.uuid.toString()}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
          ],
          ...<Widget>[
            for (final characteristic in service.characteristics)
              BluetoothCharacteristicWidget(
                peripheral: peripheral,
                characteristic: characteristic,
              ),
          ],
        ],
      ),
    );
  }
}
