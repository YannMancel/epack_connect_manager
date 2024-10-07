import 'package:flutter/material.dart';

class RSSIIndicator extends StatelessWidget {
  const RSSIIndicator(
    this.rssi, {
    super.key,
  });

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final iconData = (rssi > -70)
        ? Icons.wifi_rounded
        : (rssi > -100)
            ? Icons.wifi_2_bar_rounded
            : Icons.wifi_1_bar_rounded;
    return Icon(iconData);
  }
}
