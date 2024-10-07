import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble_lib;
import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/material.dart';

class BluetoothDiscoveryPage extends StatefulWidget {
  const BluetoothDiscoveryPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<BluetoothDiscoveryPage> createState() => _BluetoothDiscoveryPageState();
}

class _BluetoothDiscoveryPageState extends State<BluetoothDiscoveryPage> {
  late BluetoothDiscoveryLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BluetoothLowEnergyDiscoveryLogic(
      manager: ble_lib.CentralManager(),
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder<BluetoothDiscoveryState>(
        valueListenable: _logic.state,
        builder: (_, state, __) => state.when<Widget>(
          unAuthorized: () => const Center(
            child: Text('No permission granted.'),
          ),
          authorized: (isDiscovering, discoveries) => Stack(
            children: <Widget>[
              discoveries.isEmpty
                  ? const Center(
                      child: Text('No discovery'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 88.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      itemCount: discoveries.length,
                      itemBuilder: (context, index) {
                        final discovery = discoveries[index];
                        final rssi = discovery.rssi;
                        return Card(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            onTap: () async {
                              await _logic.stop();
                              if (context.mounted) {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => BluetoothConnectionPage(
                                      discovery,
                                    ),
                                  ),
                                );
                              }
                              await _logic.start();
                            },
                            title: Text(
                              discovery.advertisement.name ?? '[No Name]',
                            ),
                            subtitle: Text(
                              '${discovery.peripheral.uuid}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RSSIIndicator(rssi),
                                Text('$rssi'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton.extended(
                    onPressed: state.isAuthorized
                        ? () async {
                            isDiscovering
                                ? await _logic.stop()
                                : await _logic.start();
                          }
                        : null,
                    label: Text(isDiscovering ? 'Stop' : 'Search'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
